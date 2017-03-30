#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fpga/enum.h>
#include <fpga/access.h>


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

int main(int argc, char *argv[]) {

  uint32_t data32;
  uint64_t data64;
  fpga_properties   *filterp = NULL;
  fpga_token         afc_token;
  fpga_handle        afc_handle;
  fpga_guid          guid = { 0xac, 0x8f, 0x03, 0xc4, 0x5f, 0x6f, 0xbf, 0x96,
			      0xfb, 0x4d, 0xd1, 0x88, 0xf1, 0xbf, 0xc1, 0x10};
  uint32_t           num_matches = 1;

  volatile uint64_t *mmio_ptr   = NULL;
  volatile uint64_t *dsm_ptr    = NULL;
  volatile uint64_t *status_ptr = NULL;
  volatile uint64_t *input_ptr  = NULL;
  volatile uint64_t *output_ptr = NULL;
    
  int				ii;
  uint64_t        dsm_wsid;
  uint64_t        input_wsid;
  uint64_t        output_wsid;

  /* Look for AFC with MY_AFC_ID */
  fpgaCreateProperties(&filterp);
  fpgaPropertiesSetObjectType(filterp, FPGA_AFC);
  fpgaPropertiesSetGuid(filterp, guid);
  /* TODO: Add selection via BDF / device ID */

  fpgaEnumerate(filterp, 1, &afc_token, &num_matches);

  fpgaDestroyProperties(&filterp); /* not needed anymore */

  if (num_matches < 1) {
    fprintf(stderr, "AFC not found.\n");
    return 1;
  }

  /* Open AFC and map MMIO */
  fpgaOpen(afc_token, &afc_handle, 0);
  fpgaMapMMIO(afc_handle, 0, (uint64_t **)&mmio_ptr);

  printf("Running Test\n");

  /* Reset AFC */
  fpgaReset(afc_handle);
	
  /*
   * Step 1: MMIOWrite32 through range
   */
  printf(" Step 1: MMIOWrite32 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4) 
    {
      fpgaWriteMMIO32(afc_handle, 0, ii, ii);
    }
  printf(" DONE !\n");
	 
	 
  /*
   * Step 2: MMIORead32 through range
   */
  printf(" Step 2: MMIORead32 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4) 
    {
      fpgaReadMMIO32(afc_handle, 0, ii, &data32);
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
      fpgaWriteMMIO64(afc_handle, 0, ii, (uint64_t)ii);
    }
  printf(" DONE !\n");


  /*
   * Step 4: MMIORead64 through range
   */
  printf(" Step 4: MMIORead64 through range");
  for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 8) 
    {
      fpgaReadMMIO64(afc_handle, 0, ii, &data64);
      if (data64 != ii)
	{
	  printf("Error => Found unexpected MMIO readback ");
	}
    }
  printf(" DONE !\n");

	
  printf("Done Running Test\n");
  /* Release accelerator */
  fpgaClose(afc_handle);

  return 0;
}


