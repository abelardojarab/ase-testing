#include "ase_common.h"

#define NUM_THREADS 4

uint64_t exp_array[4] = {
  0x1000000000001071,
  0x9aeffe5f84570612,
  0xc000c9660d824272,
  0x0
};

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
      if (data64 != exp_array[0])
	{
	  printf("Wrong readback 0x00 (expected %016lx, found %016lx !... forcing exit\n", exp_array[0], data64);
	  exit(1);
	}
      mmio_read64 (0x8, &data64);
      if (data64 != exp_array[1])
	{
	  printf("Wrong readback 0x08 (expected %016lx, found %016lx !... forcing exit\n", exp_array[1], data64);
	  exit(1);
	}
      mmio_read64 (0x10, &data64);
      if (data64 != exp_array[2])
	{
	  printf("Wrong readback 0x10 (expected %016lx, found %016lx !... forcing exit\n", exp_array[2], data64);
	  exit(1);
	}
      mmio_read64 (0x18, &data64);
      if (data64 != exp_array[3])
	{
	  printf("Wrong readback 0x18 (expected %016lx, found %016lx !... forcing exit\n", exp_array[3], data64);
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
  sleep(180);

  // Cancel all pthreads
  for(ii = 0; ii < NUM_THREADS; ii++)
    {
      pthread_cancel (tid[ii]);
    }
  
  session_deinit();

  return 0;
}
