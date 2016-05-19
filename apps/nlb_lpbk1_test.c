#include "ase_common.h"

/* #define MCL_SET                  0x1 */
/* #define VC_SET                   0x0 */

/////////////////////////////////////////
#define DFH                      0x0000
#define AFU_ID_L                 0x0008
#define AFU_ID_H                 0x0010
#define CSR_DFH_RSVD0            0x0018
#define CSR_DFH_RSVD1            0x0020

#define CSR_SCRATCHPAD0          0x100
#define CSR_SCRATCHPAD1          0x104
#define CSR_SCRATCHPAD2          0x108

#define CSR_AFU_DSM_BASEL        0x110
#define CSR_AFU_DSM_BASEH        0x114
#define CSR_SRC_ADDR             0x120
#define CSR_DST_ADDR             0x128
#define CSR_NUM_LINES            0x130
#define CSR_CTL                  0x138
#define CSR_CFG                  0x140
#define CSR_INACT_THRESH         0x148
#define CSR_INTERRUPT0           0x150
#define DSM_STATUS_TEST_COMPLETE 0x40
/////////////////////////////////////////
#define  ORIG_ALLOC_BUFFER

#define ENABLE_UMSG

int main(int argc, char *argv[])
{
  int num_cl;
  int vc_set;
  int mcl_set;
  int app_ret;

  if (argc > 1) 
    {
      num_cl  = atoi( argv[1] );
      vc_set  = atoi( argv[2] );
      mcl_set = atoi( argv[3] );      
    }
  else
    {
      num_cl = 16;
      vc_set = 0;
      mcl_set = 0;
    }

  session_init();
  int i;  
  
  int vc_arr[4] = {0, 1, 2, 3};
  int mcl_arr[3] = {0, 1, 3};

  printf("num_cl = %d, vc_set = %d, mcl_set = %d\n", num_cl, vc_set, mcl_set);


  // Port control
  ase_portctrl("AFU_RESET 1");
#ifdef ENABLE_UMSG
  ase_portctrl("UMSG_MODE 255");
#endif
  ase_portctrl("AFU_RESET 0");

  // usleep(100);
  // sleep(2);
  // Send umsg
#ifdef ENABLE_UMSG
  volatile uint64_t *umsg_1;  
  volatile uint64_t *umsg_7;
  umsg_1 = umsg_get_address(1);
  umsg_7 = umsg_get_address(7);
  for(i= 0; i < 1000; i++)
    {
      *umsg_1 = 0x1111111100000000 + i;
      // usleep(1);
      *umsg_7 = 0x7777777700000000 + i;
      // usleep(1);
      /* umsgdata = 0x1111111100000000 + i; */
      /* umsg_send (1, &umsgdata); */
      /* umsgdata = 0x7777777700000000 + i; */
      /* umsg_send (7, &umsgdata); */
    }
#endif
  struct buffer_t *dsm, *src, *dst;
  
  dsm = (struct buffer_t *)malloc(sizeof(struct buffer_t));
  src = (struct buffer_t *)malloc(sizeof(struct buffer_t));
  dst = (struct buffer_t *)malloc(sizeof(struct buffer_t));
  
  memset(dsm, '0', sizeof(struct buffer_t));  
  memset(src, '0', sizeof(struct buffer_t));  
  memset(dst, '0', sizeof(struct buffer_t));  
  
  //Assign buffer size
  dsm->memsize = 2*1024*1024;
  src->memsize = num_cl*64;
  dst->memsize = num_cl*64;

  dsm->is_mmiomap = 0;
  src->is_mmiomap = 0;
  dst->is_mmiomap = 0;

  dsm->is_umas = 0;
  src->is_umas = 0;
  dst->is_umas = 0;
  
  uint64_t *dsm_sugg_addr;
  
  // Allocate buffer
#ifdef ORIG_ALLOC_BUFFER
  allocate_buffer(dsm, NULL);
  allocate_buffer(src, NULL);
  allocate_buffer(dst, NULL);
#else
  // DSM suggested address
  dsm_sugg_addr = mmap(NULL, 
		       dsm->memsize, 
		       PROT_READ | PROT_WRITE,
		       MAP_SHARED | MAP_ANONYMOUS, -1, 0);
  allocate_buffer(dsm, dsm_sugg_addr);    
  allocate_buffer(src, NULL);
  allocate_buffer(dst, NULL);
#endif
 
  // Print buffer information
  /* ase_buffer_info(dsm); */
  /* ase_buffer_info(src); */
  /* ase_buffer_info(dst); */

  // Write something in src
  // uint64_t *test_data;
  FILE *fp_rand;
  int ret;
  // test_data = (uint64_t*)src->vbase;
  /* *test_data = 0xCAFEBABE; */
  
  fp_rand = fopen("/dev/urandom", "r");
  ret = fread((void *)src->vbase, 1, (size_t)src->memsize, fp_rand);
  if (ret != src->memsize)     
    {
      perror("fread");
      return -1;
    }
  fclose(fp_rand);

  mmio_write32(CSR_AFU_DSM_BASEL, (uint32_t)dsm->fake_paddr);
  mmio_write32(CSR_AFU_DSM_BASEH, (dsm->fake_paddr >> 32));
 
  mmio_write32(CSR_CTL, 0);
  
  mmio_write32(CSR_CTL, 1);

  /* for(i= 0; i < 10000; i++) */
  /*   { */
  mmio_write64(CSR_SRC_ADDR, (src->fake_paddr >> 6));      
  mmio_write64(CSR_DST_ADDR, (dst->fake_paddr >> 6));
  /* } */
  
  uint64_t data64;
  uint32_t data32;
  /* for(i= 0; i < 10000; i++) */
  
  mmio_read64(AFU_ID_L, &data64 );
  printf("data64 = %llx\n", (unsigned long long)data64);
  mmio_read64(AFU_ID_H, &data64 );
  printf("data64 = %llx\n", (unsigned long long)data64);
  
  mmio_read32(AFU_ID_L, &data32 );
  printf("data32 = %08x\n", (uint32_t)data32);
  mmio_read32(AFU_ID_L + 4, &data32 );
  printf("data32 = %08x\n", (uint32_t)data32);
  mmio_read32(AFU_ID_H, &data32 );
  printf("data32 = %08x\n", (uint32_t)data32);
  mmio_read32(AFU_ID_H + 4, &data32 );
  printf("data32 = %08x\n", (uint32_t)data32);

#if 0
  mmio_read32(0x1020, &data32 );
#endif
  
  mmio_write32(CSR_NUM_LINES, num_cl);
  
  mmio_write32(CSR_CFG, (0 | (mcl_set << 5) | (vc_set << 12)) );  
  
  volatile uint32_t *status_addr = (uint32_t *)((uint64_t)dsm->vbase + DSM_STATUS_TEST_COMPLETE);

  mmio_write32(CSR_CTL, 3);

  while(*status_addr == 0)
    {
      // usleep(100);
    }
  
  printf("Test complete\n");

  if (memcmp((char*)src->vbase, (char*)dst->vbase, num_cl*64) == 0)
    {
      printf("Buffers matched\n");
      app_ret = 0;
    }
  else
    {
      printf("*** Buffer mismatch ***\n");
      app_ret = -1;
    }

  /* deallocate_buffer(dsm); */
  /* deallocate_buffer(src); */
  /* deallocate_buffer(dst); */

  send_swreset();

  deallocate_buffer_by_index(4);
  deallocate_buffer_by_index(3);
  deallocate_buffer_by_index(2);

  session_deinit();

  return app_ret;
}
