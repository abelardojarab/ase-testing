#include "ase_common.h"

#define SEED 0xCAFE
#define MAX  8

int out[MAX];
int ii;

int main()
{
  srand(SEED);
  
  for(ii = 0; ii < MAX; ii++)
    out[ii] = rand();

  for(ii = 0; ii < MAX; ii++)
    printf("%x ", out[ii]);
  
  return 0;
}
