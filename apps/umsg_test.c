#include "ase_common.h"

#define NUM_UMSG      8
#define UMSG_DATA_MAX 1000000

// Umsg sender thread
void *umsg_thrasher(void *addr)
{
  uint64_t data64, i;
  uint64_t *umsg_addr;
  
  pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
  umsg_addr = (uint64_t*) addr;
  printf("Umsg address = %p\n", umsg_addr);

  for(i = 0 ; i < UMSG_DATA_MAX; i++)
    {
      *umsg_addr = ((uint64_t)umsg_addr & 0xFFFFFFFF00000000) + i;
    }
}


// Main
int main()
{
  session_init();

  int ii;
  pthread_t tid[NUM_UMSG];
  int err[NUM_UMSG];
  uint64_t *umsg_claddr[NUM_UMSG]; 
  
  send_swreset();

  umsg_set_attribute(0xF0F0F0F0);
  
  // Find addresses
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      umsg_claddr[ii] = umsg_get_address(ii);
    }
  
  // Multi-threaded umsg send
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      err[ii] = pthread_create(&tid[ii], NULL, &umsg_thrasher, umsg_claddr[ii]);
      if (err[ii] != 0) 
	{
	  perror("pthread_create");
	  exit(1);
	}      
    }

  sleep(3);
  
  // Join outstanding threads
  for(ii = 0; ii < NUM_UMSG ; ii++)
    {
      pthread_join(tid[ii], NULL);
    }

  session_deinit();

  return 0;
}

