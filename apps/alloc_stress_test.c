#include "ase_common.h"


int main()
{
  session_init();
  int i;

  struct buffer_t *buf;
  buf  = (struct buffer_t *)malloc(sizeof(struct buffer_t));
  buf->memsize  = 2*1024;

  i = 0;
  while(1)
  //  for (i = 0; i < 32000 ; i++)
    {
      printf(" ------- Iteration %d ------- \n", i);
      allocate_buffer(buf, NULL);
      if (buf->fake_paddr == 0) 
	{
	  printf("Physaddr = 0 is unacceptable\n");
	  goto cruel_world;
	}
      i++;
    }

 cruel_world:
  session_deinit();

  return 0;
}
