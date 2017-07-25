#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <uuid/uuid.h>
#include <opae/fpga.h>
#include <pthread.h>
#include <stdbool.h>
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

// #define SERIAL

/*
 * macro to check return codes, print error message, and goto cleanup label
 * NOTE: this changes the program flow (uses goto)!
 */
/* #define ON_ERR_GOTO(res, label, desc)			\ */
/*     do {							\ */
/* 	if ((res) != FPGA_OK) {					\ */
/* 	    print_err((desc), (res));				\ */
/* 	    goto label;						\ */
/* 	}							\ */
/*     } while (0) */

/* void print_err(const char *s, fpga_result res) fprintf(stderr, "Error %s: %s\n", s, fpgaErrStr(res)); */

#define CACHELINE_ALIGNED_ADDR(p) ((p) >> LOG2_CL)

#define LPBK1_BUFFER_SIZE            MB(1)
#define LPBK1_BUFFER_ALLOCATION_SIZE MB(2)
#define LPBK1_DSM_SIZE               MB(4)
#define CSR_SRC_ADDR                 0x0120
#define CSR_DST_ADDR                 0x0128
#define CSR_CTL                      0x0138
#define CSR_CFG                      0x0140
#define CSR_NUM_LINES                0x0130
#define DSM_STATUS_TEST_COMPLETE     0x40
#define CSR_AFU_DSM_BASEL            0x0110
#define CSR_AFU_DSM_BASEH            0x0114

#define MMIO_BYTE_SIZE               256*1024

#define NUM_MMIO_WORKERS 16
pthread_t tid [NUM_MMIO_WORKERS];
uint32_t start_offset[NUM_MMIO_WORKERS];
uint32_t end_offset[NUM_MMIO_WORKERS];


/* SKX-P NLB0 AFU_ID */
#define MMIO_STRESS_AFUID "10C1BFF1-88D1-4DFB-96BF-6F5FC4038FAC"


struct MMIOThreadParams {
    fpga_handle  handle;
    int          id;
    bool         write_not_read;
    bool         enable_64bit;
    uint64_t     start_offset;
    uint64_t     end_offset;
};

uint64_t err_cnt;
pthread_mutex_t errcnt_mutex;

void *MMIOWorkerThread(void *context)
{
    struct MMIOThreadParams *mmio = context;

    uint64_t data64;
    uint32_t data32;
    
    uint64_t offset;

    pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
    
    for(offset = mmio->start_offset; offset < mmio->end_offset; )
	{
	    if (mmio->enable_64bit)
		{
		    if (mmio->write_not_read)
			{
			    fpgaWriteMMIO64(mmio->handle, 0, offset, offset);
			}
		    else
			{
			    fpgaReadMMIO64(mmio->handle, 0, offset, &data64);
			    if (data64 != offset)
				{
				    printf("Error => Unexpected MMIO readback @%lx found %lx\n", offset, data64 );
				}
			}
		    offset+=8;
		}
	    else
		{
		    if (mmio->write_not_read)
			{
			    fpgaWriteMMIO32(mmio->handle, 0, offset, offset);
			}
		    else
			{
			    fpgaReadMMIO32(mmio->handle, 0, offset, &data32);
			    if ((uint64_t)data32 != offset)
				{
				    printf("Error => Unexpected MMIO readback @%lx found %x\n", offset, data32 );
				}
			}
		    offset+=4;
		}
	    //	    printf("\tTID = %d\tMMIOAddr = %x\n", mmio->id, offset);
	}
}

#define JOIN_ALL_WORKERS			\
    for(ii = 0; ii < NUM_MMIO_WORKERS; ii++)	\
	{					\
	    pthread_join(tid[ii], NULL);	\
	}					\



int main(int argc, char *argv[]) {

    uint32_t data32;
    uint64_t data64;
    fpga_properties   filter = NULL;
    fpga_token         afc_token;
    fpga_handle        afc_handle;
    fpga_guid          guid;
    uint32_t           num_matches = 1;

    volatile uint64_t *mmio_ptr   = NULL;
    volatile uint64_t *dsm_ptr    = NULL;
    volatile uint64_t *status_ptr = NULL;
    volatile uint64_t *input_ptr  = NULL;
    volatile uint64_t *output_ptr = NULL;
    fpga_result     res;
    int				ii;
    uint64_t        dsm_wsid;
    uint64_t        input_wsid;
    uint64_t        output_wsid;
    if (uuid_parse(MMIO_STRESS_AFUID, guid) < 0) {
	fprintf(stderr, "Error parsing guid '%s'\n", MMIO_STRESS_AFUID);
	goto out_exit;
    }

    /* Look for AFC with MY_AFC_ID */
    res = fpgaGetProperties(NULL, &filter);
    if (res != FPGA_OK)
	return -1;
	
    res = fpgaPropertiesSetObjectType(filter, FPGA_AFC);
    if (res != FPGA_OK)
	return -1;
    //	ON_ERR_GOTO(res, out_destroy_prop, "setting object type");

    res = fpgaPropertiesSetGUID(filter, guid);
    if (res != FPGA_OK)
	return -1;
    // ON_ERR_GOTO(res, out_destroy_prop, "setting GUID");

    /* TODO: Add selection via BDF / device ID */

    res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
    if (res != FPGA_OK)
	return -1;
    //	ON_ERR_GOTO(res, out_destroy_prop, "enumerating AFCs");

    if (num_matches < 1) {
	fprintf(stderr, "AFC not found.\n");
	res = fpgaDestroyProperties(&filter);
	return FPGA_INVALID_PARAM;
    }

    /* Open AFC and map MMIO */
    res = fpgaOpen(afc_token, &afc_handle, 0);
    if (res != FPGA_OK)
	return -1;

    // ON_ERR_GOTO(res, out_exit, "opening AFC");
    res = fpgaMapMMIO(afc_handle, 0, (uint64_t **)&mmio_ptr);
    //ON_ERR_GOTO(res, out_exit, "mapping MMIO space");

    printf("Running Test\n");

    res = fpgaReset(afc_handle);
    //ON_ERR_GOTO(res, out_exit, "resetting AFC");

    //////////////////////////////////////////////////////////////////////////////////

    /*
     * Prepare offsets
     */
    for(ii = 0; ii < NUM_MMIO_WORKERS ; ii = ii + 1)
	{
	    // Calculate ranges
	    start_offset[ii]   = ii*(MMIO_BYTE_SIZE / NUM_MMIO_WORKERS);
	    end_offset[ii]     = (ii+1)*(MMIO_BYTE_SIZE / NUM_MMIO_WORKERS) - 1;

	    // Print ranges
	    printf("\t%d : %x - %x\n", ii, start_offset[ii], end_offset[ii]);
	}
    
    /*
     * Step 1: MMIOWrite32 through range
     */
    struct MMIOThreadParams mmioParam;
    mmioParam.handle = afc_handle;

    int err;
  
    printf(" Step 1: MMIOWrite32 through range");
#ifdef SERIAL
    for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4)
	{
	    res = fpgaWriteMMIO32(afc_handle, 0,ii, ii);
	    if (res != FPGA_OK)
		return -1;
	}  
#else
    // Start the threads
    for (ii = 0; ii < NUM_MMIO_WORKERS; ii++)
	{
	    mmioParam.id             = ii;
	    mmioParam.write_not_read = true;
	    mmioParam.enable_64bit   = false;
	    mmioParam.start_offset   = start_offset[ii];
	    mmioParam.end_offset     = end_offset[ii];
	    err = pthread_create(&tid[ii], NULL, MMIOWorkerThread, &mmioParam);
	    if (err != 0)
		{
		    perror("pthread_create");
		    exit(-1);
		}
	}
  
    // Join the threads
    JOIN_ALL_WORKERS; 
#endif
    printf(" DONE !\n");

    ////////////////////////////////////////////////////////////////////////////////////////////

    /*
     * Step 2: MMIORead32 through range
     */
    printf(" Step 2: MMIORead32 through range");
#ifdef SERIAL
    for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 4)
	{
	    res = fpgaReadMMIO32(afc_handle, 0, ii, &data32);
	    if (data32 != (uint64_t)ii)
		{
		    printf("Error => Found unexpected MMIO readback ");

		}
	}
#else
    for (ii = 0; ii < NUM_MMIO_WORKERS; ii++)
	{
	    mmioParam.id             = ii;
	    mmioParam.write_not_read = false;
	    mmioParam.enable_64bit   = false;
	    mmioParam.start_offset   = start_offset[ii];
	    mmioParam.end_offset     = end_offset[ii];
	    err = pthread_create(&tid[ii], NULL, MMIOWorkerThread, &mmioParam);
	    if (err != 0)
		{
		    perror("pthread_create");
		    exit(-1);
		}
	}
  
    // Join the threads
    JOIN_ALL_WORKERS; 
#endif
    printf(" DONE !\n");

    ///////////////////////////////////////////////////////////////////////////////////////
  
    /*
     * Step 3: MMIOWrite64 through range
     */
    printf(" Step 3: MMIOWrite64 through range");
#ifdef SERIAL
    for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 8)
	{
	    res = fpgaWriteMMIO64(afc_handle, 0, ii, (uint64_t)ii);
	    //ON_ERR_GOTO(res, out_exit, "writing 64 bit MMIO");

	}
#else
    for (ii = 0; ii < NUM_MMIO_WORKERS; ii++)
	{
	    mmioParam.id             = ii;
	    mmioParam.write_not_read = true;
	    mmioParam.enable_64bit   = true;
	    mmioParam.start_offset   = start_offset[ii];
	    mmioParam.end_offset     = end_offset[ii];
	    err = pthread_create(&tid[ii], NULL, MMIOWorkerThread, &mmioParam);
	    if (err != 0)
		{
		    perror("pthread_create");
		    exit(-1);
		}
	}
  
    // Join the threads
    JOIN_ALL_WORKERS; 
#endif
    printf(" DONE !\n");

    /////////////////////////////////////////////////////////////////////////////////////

    /*
     * Step 4: MMIORead64 through range
     */
    printf(" Step 4: MMIORead64 through range");
#ifdef SERIAL
    for(ii = 0; ii < MMIO_BYTE_SIZE ; ii = ii + 8)
	{
	    res = fpgaReadMMIO64(afc_handle, 0, ii, &data64);
	    //   ON_ERR_GOTO(res, out_exit, "reading 64 bit MMIO");
	    if (data64 != ii)
		{
		    printf("Error => Found unexpected MMIO readback ");
		}
	}
#else
    for (ii = 0; ii < NUM_MMIO_WORKERS; ii++)
	{
	    mmioParam.id             = ii;
	    mmioParam.write_not_read = false;
	    mmioParam.enable_64bit   = true;
	    mmioParam.start_offset   = start_offset[ii];
	    mmioParam.end_offset     = end_offset[ii];
	    err = pthread_create(&tid[ii], NULL, MMIOWorkerThread, &mmioParam);
	    if (err != 0)
		{
		    perror("pthread_create");
		    exit(-1);
		}
	}
  
    // Join the threads
    JOIN_ALL_WORKERS; 
#endif
    printf(" DONE !\n");

    //////////////////////////////////////////////////////////////////////////////////
    
    printf("Done Running Test\n");
    /* Release accelerator */

    res = fpgaClose(afc_handle);
    //ON_ERR_GOTO(res, out_exit, "closing AFC");

 out_destroy_prop:
    res = fpgaDestroyProperties(&filter);
    if (res != FPGA_OK)
	return -1;

    // ON_ERR_GOTO(res, out_exit, "destroying properties object");
 out_exit:
    return res;
}
