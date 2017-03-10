#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fpga/enum.h>
#include <fpga/access.h>

int main(int argc, char *argv[]) {

	fpga_properties   *filterp = NULL;
	fpga_token         afc_token;
	fpga_handle        afc_handle;
	fpga_guid          guid = { 0xA1, 0x2E, 0xBB, 0x32, 0x8F, 0x7D, 0xD3,
		0x5C, 0xA4, 0x55, 0x78, 0x3A, 0x3E, 0x90, 0x43, 0xB9 };
	uint32_t           num_matches = 1;
	uint32_t	   x;

	/* Look for AFC with MY_AFC_ID */
	printf("Looking for AFC\n");
	fpgaCreateProperties(&filterp);
	fpgaPropertiesSetObjectType(filterp, FPGA_AFC);
	fpgaPropertiesSetGuid(filterp, guid);
	/* TODO: Add selection via BDF / device ID */

	// fpgaEnumerate(filterp, 1, &afc_token, &num_matches);

	fpgaDestroyProperties(&filterp); /* not needed anymore */

	if (num_matches < 1) {
		fprintf(stderr, "AFC not found.\n");
		return 1;
	}

	/* Open AFC and map MMIO */
	printf("Opening AFC\n");
	fpgaOpen(afc_token, &afc_handle, 0);
	fpgaMapMMIO(afc_handle, 0, NULL);

	printf("Running Test\n");

	/* Reset AFC */
	fpgaReset(afc_handle);

	x = 0x00001000;
	printf("Write x = 0x%08x\n", x);
	fpgaWriteMMIO32(afc_handle, 0, 0x104, x);

	usleep(1000);

	printf("Count up.\n");
	fpgaWriteMMIO32(afc_handle, 0, 0x100, 1);

	usleep(3000);

	x = 0;
	fpgaReadMMIO32(afc_handle, 0, 0x104, &x);
	printf("Read x = 0x%08x\n", x);

	printf("Count down.\n");
	fpgaWriteMMIO32(afc_handle, 0, 0x100, 2);

	usleep(4000);

	fpgaReadMMIO32(afc_handle, 0, 0x104, &x);
	printf("Read x = 0x%08x\n", x);

	usleep(500000);

	printf("Done Running Test\n");

	/* Release accelerator */
	fpgaClose(afc_handle);

	return 0;
}


