#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <fpga/enum.h>
#include <fpga/access.h>
#include <fpga/common.h>

int usleep(unsigned);

#ifndef CL
# define CL(x)                       ((x) * 64)
#endif // CL
#ifndef LOG2_CL
# define LOG2_CL                     6
#endif // LOG2_CL
#ifndef MB
# define MB(x)                       ((x) * 1024 * 1024)
#endif // MB

#define CACHELINE_ALIGNED_ADDR(p) ((p) >> LOG2_CL)

#define LPBK1_BUFFER_SIZE            MB(1)
#define LPBK1_BUFFER_ALLOCATION_SIZE MB(2)
#define LPBK1_DSM_SIZE               MB(4)
#define CSR_SRC_ADDR                 0x0120
#define CSR_DST_ADDR                 0x0128
#define CSR_CTL                      0x0138
#define CSR_CFG                      0x0140
#define CSR_NUM_LINES                0x0130
#define DSM_STATUS_TEST_COMPLETE     0x40
#define CSR_AFU_DSM_BASEL            0x0110
#define CSR_AFU_DSM_BASEH            0x0114

/* SKX-P NLB0 AFU_ID */
#define SKX_P_NLB0_AFUID "D8424DC4-A4A3-C413-F89E-433683F9040B"

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ON_ERR_GOTO(res, label, desc)                    \
	do {                                       \
		if ((res) != FPGA_OK) {            \
			print_err((desc), (res));  \
			goto label;                \
		}                                  \
	} while (0)

/* Type definitions */
typedef struct {
	uint32_t uint[16];
} cache_line;

void print_err(const char *s, fpga_result res)
{
	fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res));
}

int main(int argc, char *argv[])
{
	fpga_properties    filter = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid;
	uint32_t           num_matches = 1;

	volatile uint64_t *mmio_ptr   = NULL;
	volatile uint64_t *dsm_ptr    = NULL;
	volatile uint64_t *status_ptr = NULL;
	volatile uint64_t *input_ptr  = NULL;
	volatile uint64_t *output_ptr = NULL;

	uint64_t        dsm_wsid;
	uint64_t        input_wsid;
	uint64_t        output_wsid;
	fpga_result     res;

	if (uuid_parse(SKX_P_NLB0_AFUID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", SKX_P_NLB0_AFUID);
		goto out_exit;
	}

	/* Look for AFC with MY_AFC_ID */
	res = fpgaCreateProperties(&filter);
	ON_ERR_GOTO(res, out_exit, "creating properties object");

	res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
	ON_ERR_GOTO(res, out_exit, "setting object type");

	res = fpgaPropertiesSetGuid(filter, guid);
	ON_ERR_GOTO(res, out_exit, "setting GUID");

	/* TODO: Add selection via BDF / device ID */

	res = fpgaEnumerate(&filter, 1, &afc_token, &num_matches);
	ON_ERR_GOTO(res, out_exit, "enumerating AFCs");

	res = fpgaDestroyProperties(&filter); /* not needed anymore */
	ON_ERR_GOTO(res, out_exit, "destroying properties object");

	if (num_matches < 1) {
		fprintf(stderr, "AFC not found.\n");
		return 1;
	}

	/* Open AFC and map MMIO */
	res = fpgaOpen(afc_token, &afc_handle, 0);
	ON_ERR_GOTO(res, out_exit, "opening AFC");

	res = fpgaMapMMIO(afc_handle, 0, (uint64_t **)&mmio_ptr);
	ON_ERR_GOTO(res, out_close, "mapping MMIO space");

	/* Allocate buffers */
	res = fpgaPrepareBuffer(afc_handle, LPBK1_DSM_SIZE,
				(void **)&dsm_ptr, &dsm_wsid, 0);
	ON_ERR_GOTO(res, out_close, "allocating DSM buffer");

	res = fpgaPrepareBuffer(afc_handle, LPBK1_BUFFER_ALLOCATION_SIZE,
			   (void **)&input_ptr, &input_wsid, 0);
	ON_ERR_GOTO(res, out_free_dsm, "allocating input buffer");

	res = fpgaPrepareBuffer(afc_handle, LPBK1_BUFFER_ALLOCATION_SIZE,
			   (void **)&output_ptr, &output_wsid, 0);
	ON_ERR_GOTO(res, out_free_input, "allocating output buffer");

	printf("Running Test\n");

	/* Initialize buffers */
	memset((void *)dsm_ptr,    0,    LPBK1_DSM_SIZE);
	memset((void *)input_ptr,  0xAF, LPBK1_BUFFER_SIZE);
	memset((void *)output_ptr, 0xBE, LPBK1_BUFFER_SIZE);

	cache_line *cl_ptr = (cache_line *)input_ptr;
	for (uint32_t i = 0; i < LPBK1_BUFFER_SIZE / CL(1); ++i) {
		cl_ptr[i].uint[15] = i+1; /* set the last uint in every cacheline */
	}

	/* Reset AFC */
	res = fpgaReset(afc_handle);
	ON_ERR_GOTO(res, out_free_output, "resetting AFC");

	/* Program DMA addresses */
	uint64_t iova;
	res = fpgaGetIOVA(afc_handle, dsm_wsid, &iova);
	ON_ERR_GOTO(res, out_free_output, "getting DSM IOVA");

	res = fpgaWriteMMIO64(afc_handle, 0, CSR_AFU_DSM_BASEL, iova);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_AFU_DSM_BASEL");

	res = fpgaWriteMMIO32(afc_handle, 0, CSR_CTL, 0);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_CFG");
	res = fpgaWriteMMIO32(afc_handle, 0, CSR_CTL, 1);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_CFG");

	res = fpgaGetIOVA(afc_handle, input_wsid, &iova);
	ON_ERR_GOTO(res, out_free_output, "getting input IOVA");
	res = fpgaWriteMMIO64(afc_handle, 0, CSR_SRC_ADDR, CACHELINE_ALIGNED_ADDR(iova));
	ON_ERR_GOTO(res, out_free_output, "writing CSR_SRC_ADDR");

	res = fpgaGetIOVA(afc_handle, output_wsid, &iova);
	ON_ERR_GOTO(res, out_free_output, "getting output IOVA");
	res = fpgaWriteMMIO64(afc_handle, 0, CSR_DST_ADDR, CACHELINE_ALIGNED_ADDR(iova));
	ON_ERR_GOTO(res, out_free_output, "writing CSR_DST_ADDR");
	//fpgaProgramBufferAddressAndLength(afc_handle, dsm_wsid, 0, LPBK1_DSM_SIZE,
	//				   CSR_AFU_DSM_BASEL);
	//fpgaProgramBufferAddressAndLength(afc_handle, input_wsid, 0, LPBK1_BUFFER_SIZE,
	//				   CSR_SRC_ADDR);
	//fpgaProgramBufferAddressAndLength(afc_handle, output_wsid, 0, LPBK1_BUFFER_SIZE,
	//				   CSR_DST_ADDR);

	res = fpgaWriteMMIO32(afc_handle, 0, CSR_NUM_LINES, LPBK1_BUFFER_SIZE / CL(1));
	ON_ERR_GOTO(res, out_free_output, "writing CSR_NUM_LINES");
	res = fpgaWriteMMIO32(afc_handle, 0, CSR_CFG, 0x42000);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_CFG");

	status_ptr = dsm_ptr + DSM_STATUS_TEST_COMPLETE/8;

	/* Start the test */
	res = fpgaWriteMMIO32(afc_handle, 0, CSR_CTL, 3);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_CFG");

	/* Wait for test completion */
	while (0 == ((*status_ptr) & 0x1)) {
		usleep(100);
	}

	/* Stop the device */
	res = fpgaWriteMMIO32(afc_handle, 0, CSR_CTL, 7);
	ON_ERR_GOTO(res, out_free_output, "writing CSR_CFG");

	/* Check output buffer contents */
	for (uint32_t i = 0; i < LPBK1_BUFFER_SIZE; i++) {
		if (((uint8_t*)output_ptr)[i] != ((uint8_t*)input_ptr)[i]) {
			fprintf(stderr, "Output does NOT match input "
				"at offset %i!\n", i);
			break;
		}
	}

	printf("Done Running Test\n");

	/* Release buffers */
out_free_output:
	res = fpgaReleaseBuffer(afc_handle, output_wsid);
	ON_ERR_GOTO(res, out_free_input, "releasing output buffer");
out_free_input:
	res = fpgaReleaseBuffer(afc_handle, input_wsid);
	ON_ERR_GOTO(res, out_free_dsm, "releasing input buffer");
out_free_dsm:
	res = fpgaReleaseBuffer(afc_handle, dsm_wsid);
	ON_ERR_GOTO(res, out_close, "releasing DSM buffer");

	/* Release accelerator */
out_close:
	res = fpgaClose(afc_handle);
	ON_ERR_GOTO(res, out_exit, "closing AFC");

out_exit:
	return res;

}


