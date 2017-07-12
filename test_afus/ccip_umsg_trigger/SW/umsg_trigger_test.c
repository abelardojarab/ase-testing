#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <pthread.h>
#include <stdlib.h>

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

#define NUM_UMSG      8
#define UMSG_DATA_MAX 0x100000000


// Umsg sender thread
int *umsg_thrasher(void *addr)
{
  uint64_t i;
  uint64_t *umsg_addr;
  
  pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
  umsg_addr = (uint64_t*) addr;
  printf("Umsg address = %p\n", umsg_addr);

  for(i = 0 ; i < UMSG_DATA_MAX; i++)
    {
      *umsg_addr = ((uint64_t)umsg_addr & 0xFFFFFFFF00000000) + i;
    }

  return 0;
}

/* SKX-P NLB0 AFU_ID */
#define SKX_P_NLB0_AFUID "D8424DC4-A4A3-C413-F89E-433683F9040B"

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
#define ON_ERR_GOTO(res, label, desc)		\
  do {						\
    if ((res) != FPGA_OK) {			\
      print_err((desc), (res));			\
      goto label;				\
    }						\
  } while (0)

/* Type definitions */
/* typedef struct { */
/* 	uint32_t uint[16]; */
/* } cache_line; */

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
  uint32_t           num_matches;

  fpga_result     res = FPGA_OK;

  if (uuid_parse(SKX_P_NLB0_AFUID, guid) < 0) {
    fprintf(stderr, "Error parsing guid '%s'\n", SKX_P_NLB0_AFUID);
    goto out_exit;
  }

  /* Look for AFC with MY_AFC_ID */
  res = fpgaGetProperties(NULL, &filter);
  ON_ERR_GOTO(res, out_exit, "creating properties object");

  res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
  ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

  res = fpgaPropertiesSetGUID(filter, guid);
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

  res = fpgaMapMMIO(afc_handle, 0, NULL);
  ON_ERR_GOTO(res, out_close, "mapping MMIO space");

  /* Reset AFC */
  res = fpgaReset(afc_handle);
  ON_ERR_GOTO(res, out_close, "resetting AFC");


  int ii;
  pthread_t tid[NUM_UMSG];
  int err[NUM_UMSG];
  uint64_t *umsg_claddr[NUM_UMSG]; 
  void *umsg_baseaddr;

  // Get UMsg address
  fpgaGetUmsgPtr(afc_handle, umsg_baseaddr);

  // Find addresses
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      // umsg_claddr[ii] = umsg_get_address(ii);
      umsg_claddr[ii] = (uint64_t*)((uint64_t)umsg_baseaddr + (uint64_t)(ii*0x1040));
    }

  //////////// No hint test ///////////////////////  
  // Set attribute
  fpgaSetUmsgAttributes(afc_handle, 0x00000000);  
  
  // Multi-threaded umsg send
  printf("Running test with hint disabled\n");
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      err[ii] = pthread_create(&tid[ii], NULL, &umsg_thrasher, umsg_claddr[ii]);
      if (err[ii] != 0) 
	{
	  perror("pthread_create");
	  exit(1);
	}      
    }

  sleep(60);
  
  // Join outstanding threads
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      pthread_join(tid[ii], NULL);
    }

  ///////////// Run with hint test /////////////////
  
  // Set attribute
  fpgaSetUmsgAttributes(afc_handle, 0xFFFFFFFF);

  printf("Running test with hint enabled\n");

    for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      err[ii] = pthread_create(&tid[ii], NULL, &umsg_thrasher, umsg_claddr[ii]);
      if (err[ii] != 0) 
	{
	  perror("pthread_create");
	  exit(1);
	}      
    }

  sleep(60);
  
  // Join outstanding threads
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      pthread_join(tid[ii], NULL);
    }


  ///////////////////// Teardown /////////////////////
  
  /* Unmap MMIO space */
  res = fpgaUnmapMMIO(afc_handle, 0);
  ON_ERR_GOTO(res, out_close, "unmapping MMIO space");

  /* Release accelerator */
 out_close:
  res = fpgaClose(afc_handle);
  ON_ERR_GOTO(res, out_destroy_tok, "closing AFC");

  /* Destroy token */
 out_destroy_tok:
  res = fpgaDestroyToken(&afc_token);
  ON_ERR_GOTO(res, out_destroy_prop, "destroying token");

  /* Destroy properties object */
 out_destroy_prop:
  res = fpgaDestroyProperties(&filter);
  ON_ERR_GOTO(res, out_exit, "destroying properties object");

 out_exit:
  return res;

}
