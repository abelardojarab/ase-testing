#include "ase_common.h"
#include "fpga/types.h"

int main()
{
  unsigned long int afuid[2];

  char afuid_uuid[] = "5037B187-E561-4CA2-AD5B-D6C7816273C2";

  // typedef uint64_t uint128_t[2];

  fpga_guid afuid_bytes = {0x50, 0x37, 0xB1, 0x87, 0xE5, 0x61, 0x4C, 0xA2, 0xAD, 0x5B, 0xD6, 0xC7, 0x81, 0x62, 0x73, 0xC2} ;

  uuid_t  afuid_orig;
  uuid_parse(afuid_bytes, afuid_orig);

  //////////////////////////////////////////////

  afuid[0] = 0x5037B187E5614CA2;
  afuid[1] = 0xAD5BD6C7816273C2;


  
  int cmpval;
  cmpval = memcmp(afuid_copy, afuid_orig, sizeof(uuid_t));
  printf("cmpval = %d\n", cmpval);

  return 0;
}
