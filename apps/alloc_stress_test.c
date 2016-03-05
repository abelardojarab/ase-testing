#include "ase_common.h"


int main()
{
  session_init();
  int i;

  struct buffer_t *buf;
  buf  = (struct buffer_t *)malloc(sizeof(struct buffer_t));
  buf->memsize  = 2*1024*1024;

  for (i = 0; i < 2048 ; i++) 
    {
      printf(" ------- Iteration %d ------- \n", i);
      allocate_buffer(buf, NULL);
      if (buf->fake_paddr == 0) 
	{
	  printf("Physaddr = 0 is unacceptable\n");
	  break;
	}
    }

  session_deinit();

  return 0;
}
