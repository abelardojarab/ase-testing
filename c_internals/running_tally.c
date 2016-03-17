#include "ase_common.h"

int main()
{
  int i;

  printf("Starting running tally\n");
  printf("This line should get wiped out");
  sleep(5);
  for(i = 0; i < 10; i++)
    {
      printf("]\n\033[F\033[J");
      //printf("\r");
      printf("iteration %d         ", i);
      sleep(1);
    }

  return 0;
}

// printf("]\n\033[F\033[J");

