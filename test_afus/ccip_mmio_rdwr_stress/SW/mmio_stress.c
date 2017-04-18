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

#define MMIO_BYTE_SIZE               256*1024
/* Type definitions */
typedef struct {
  uint32_t uint[16];
} cache_line;

/* SKX-P NLB0 AFU_ID */      
   #define SKX_P_NLB0_AFUID "10C1BFF1-88D1-4DFB-96BF-6F5FC4038FAC"

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

void print_err(const char *s, fpga_result res)
{
	fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res));
}


int main(int argc, char *argv[]) {

  uint32_t data32;
  uint64_t data64;
  fpga_properties   filter = NULL;
  fpga_token         afc_token;
  fpga_handle        afc_handle;
  fpga_guid          guid;
  uint32_t           num_matches = 1;

  volatile uint64_t *mmio_ptr   = NULL;
  volatile uint64_t *dsm_ptr    = NULL;
  volatile uint64_t *status_ptr = NULL;
  volatile uint64_t *input_ptr  = NULL;
  volatile uint64_t *output_ptr = NULL;
  fpga_result     res;  
  int				ii;
  uint64_t        dsm_wsid;
  uint64_t        input_wsid;
  uint64_t        output_wsid;
if (uuid_parse(SKX_P_NLB0_AFUID, guid) < 0) {
		fprintf(stderr, "Error parsing guid '%s'\n", SKX_P_NLB0_AFUID);
		goto out_exit;
	}


  /* Look for AFC with MY_AFC_ID */
	res = fpgaCreateProperties(&filter);
	ON_ERR_GOTO(res, out_exit, "creating properties object");

	res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
	ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

	res = fpgaPropertiesSetGuid(filter, guid);
	ON_ERR_GOTO(res, out_destroy_prop, "setting GUID");

	/* TODO: Add selection via BDF / device ID */

	res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
	ON_ERR_GOTO(res, out_destroy_prop, "enumerating AFCs");

	if (num_matches < 1) {
		fprintf(stderr, "AFC not found.\n");
		res = fpgaDestroyProperties(&filter);
		return FPGA_INVALID_PARAM;
	}

	/* Open AFC and map MMIO */
	res = fpgaOpen(afc_token, &afc_handle, 0);
	ON_ERR_GOTO(res, out_destroy_tok, "opening AFC");
  res = fpgaMapMMIO(afc_handle, 0, (uint64_t **)&mmio_ptr);
	//ON_ERR_GOTO(res, out_close, "mapping MMIO space");

  printf("Running Test\n");

  res = fpgaReset(afc_handle);
	//ON_ERR_GOTO(res, out_free_output, "resetting AFC");

	
  /*
   * Step 1: MMIOWrite32 through range
   */
  printf(" Step 1: MMIOWrite32 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4) 
    {
      res = fpgaWriteMMIO32(afc_handle, 0,ii, ii);
	//ON_ERR_GOTO(res, out_free_output, "MMIO writes 32 bit");
    
    }
  printf(" DONE !\n");
	 
	 
  /*
   * Step 2: MMIORead32 through range
   */
  printf(" Step 2: MMIORead32 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4) 
    {
      res = fpgaReadMMIO32(afc_handle, 0, ii, &data32);
      // ON_ERR_GOTO(res, out_free_output, "MMIO writes 32 bit");
      if (data32 != (uint64_t)ii)
	{
	  printf("Error => Found unexpected MMIO readback ");

	}
    }
  printf(" DONE !\n");

  /*
   * Step 3: MMIOWrite64 through range
   */
  printf(" Step 3: MMIOWrite64 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 8) 
    {
      res = fpgaWriteMMIO64(afc_handle, 0, ii, (uint64_t)ii);
	//ON_ERR_GOTO(res, out_free_output, "writing 64 bit MMIO");
   
    }
  printf(" DONE !\n");


  /*
   * Step 4: MMIORead64 through range
   */
  printf(" Step 4: MMIORead64 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 8) 
    {
       res = fpgaReadMMIO64(afc_handle, 0, ii, &data64);
    //   ON_ERR_GOTO(res, out_free_output, "reading 64 bit MMIO");
      if (data64 != ii)
	{
	  printf("Error => Found unexpected MMIO readback ");
	}
    }
  printf(" DONE !\n");

	
  printf("Done Running Test\n");
  /* Release accelerator */

	res = fpgaClose(afc_handle);
	//ON_ERR_GOTO(res, out_exit, "closing AFC");
 out_exit:
	return res;
}


