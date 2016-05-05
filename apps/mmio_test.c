#include "ase_common.h"

#define NUM_THREADS 4

/*
 * MMIO Thrasher thread
 */
void *mmio_thrasher()
{
  uint64_t data64;

  // Mark as thread that can be cancelled anytime
  pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);

  // Send out a lot of mmioread
  while(1)
    {
      mmio_read64 (0x0, &data64);
      if (data64 != 0x1000000010001071)
	{
	  printf("Wrong readback data found !... forcing exit\n");
	  exit(1);
	}
      mmio_read64 (0x8, &data64);
      if (data64 != 0x9aeffe5f84570612)
	{
	  printf("Wrong readback data found !... forcing exit\n");
	  exit(1);
	}
      mmio_read64 (0x10, &data64);
      if (data64 != 0xc000c9660d824272)
	{
	  printf("Wrong readback data found !... forcing exit\n");
	  exit(1);
	}
      mmio_read64 (0x18, &data64);
      if (data64 != 0x0000000000000000)
	{
	  printf("Wrong readback data found !... forcing exit\n");
	  exit(1);
	}
    }
}


int main()
{
  session_init();

  int err[NUM_THREADS];
  pthread_t tid[NUM_THREADS];
  int ii;

  for(ii = 0; ii < NUM_THREADS; ii++)
    {
      err[ii] = pthread_create(&tid[ii], NULL, &mmio_thrasher, NULL);
      if (err[ii] != 0) 
	{
	  perror("pthread_create");
	  exit(1);
	}
    }
  
  // Sleep 
  sleep(60);

  // Cancel all pthreads
  for(ii = 0; ii < NUM_THREADS; ii++)
    {
      pthread_cancel (tid[ii]);
    }
  
  session_deinit();

  return 0;
}
