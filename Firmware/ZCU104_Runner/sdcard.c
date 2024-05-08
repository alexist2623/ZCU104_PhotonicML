#include "runner.h"
#define SD_CARD_INITIALIZED				0x1U
#define SD_CARD_NOT_INITIALIZED 		0x0U
#define SD_CARD_READ_UNIT				10000

/*****************************************************************************/
/**
*
* This function reads data from SD Card
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
static int sd_card_initialized = SD_CARD_NOT_INITIALIZED;

int read_sd_card() {
	static XSdPs SdInstance;
    static FATFS FS_Instance;
    static FIL fil;
    static FRESULT f_res;
    static UINT br;

    /*
     * Initialize SD card and mount file system
     */
    if( sd_card_initialized == SD_CARD_NOT_INITIALIZED){
		xil_printf("Initializing SD CARD... DONNOT MAKE INTERRUPT...\r\n");
		if (init_sd_card(&SdInstance, &FS_Instance) != XST_SUCCESS) {
			xil_printf("FATAL ERROR : SD Card initialization failed\r\n");
			return XST_FAILURE;
		}
		sd_card_initialized = SD_CARD_INITIALIZED;
    }

    /*
     * Open file to read
     */
    f_res = f_open(&fil, "test0000.bin", FA_READ);
    xil_printf("f_res : fil\r\n");
    if (f_res) {
    	xil_printf("FATAL ERROR : File dones not exist\r\n");
        return XST_FAILURE;
    }

    /*
     * Read data from file
     * Note that
     * FRESULT f_read (
	 * FIL*  fp, 	Pointer to the file object
	 * void* buff,	Pointer to data buffer
	 * UINT  btr,	Number of bytes to read
	 * UINT* br		Pointer to number of bytes read
	 * )
     */
    uint8_t buffer[SD_CARD_READ_UNIT];
    f_res = f_read(&fil, buffer, sizeof(buffer), &br);

    if (f_res || br == 0) {
        f_close(&fil);
        xil_printf("FATAL ERROR : File read failed\r\n");
        return XST_FAILURE;
    }

    int j = 0;

    for(int i = 0 ; i < SD_CARD_READ_UNIT ; i++ ){
    	xil_printf("%d",buffer[i]);
    	j++;
    	if(j % 100 == 0 ){
    		xil_printf("\r\n");
    	}
    }

    /*
     * Close the file
     */
    f_close(&fil);

    xil_printf("\r\nSD CARD READ DONE\r\n");

    return XST_SUCCESS;
}

int umount_sd_card(){
	f_mount(NULL, "", 0);
	return XST_SUCCESS;
}

int load_sd_card_data(char * file_name){
	static XSdPs SdInstance;
	static FATFS FS_Instance;
	static FIL fil;
	static FRESULT f_res;
	static UINT br;

	/*
	 * Initialize SD card and mount file system
	 */
	if( sd_card_initialized == SD_CARD_NOT_INITIALIZED){
		xil_printf("Initializing SD CARD... DONNOT MAKE INTERRUPT...\r\n");
		if (init_sd_card(&SdInstance, &FS_Instance) != XST_SUCCESS) {
			xil_printf("FATAL ERROR : SD Card initialization failed\r\n");
			return XST_FAILURE;
		}
		sd_card_initialized = SD_CARD_INITIALIZED;
	}

	/*
	 * Open file to read
	 */
	f_res = f_open(&fil, file_name, FA_READ);
	if (f_res) {
		xil_printf("FATAL ERROR : File dones not exist\r\n");
		return XST_FAILURE;
	}

	/*
	 * Read data from file
	 * Note that
	 * FRESULT f_read (
	 * FIL*  fp, 	Pointer to the file object
	 * void* buff,	Pointer to data buffer
	 * UINT  btr,	Number of bytes to read
	 * UINT* br		Pointer to number of bytes read
	 * )
	 */
	uint8_t buffer[SD_CARD_READ_UNIT];
	f_res = f_read(&fil, buffer, sizeof(buffer), &br);

	if (f_res || br == 0) {
		f_close(&fil);
		xil_printf("FATAL ERROR : File read failed\r\n");
		return XST_FAILURE;
	}

	int j = 0;

	for(int i = 0 ; i < SD_CARD_READ_UNIT ; i++ ){
		xil_printf("%d",buffer[i]);
		j++;
		if(j % 100 == 0 ){
			xil_printf("\r\n");
		}
	}

	/*
	 * Close the file
	 */
	f_close(&fil);
	write_80000_data(buffer);

	xil_printf("\r\nSD CARD READ DONE\r\n");

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function initialize SD Card instance
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
int init_sd_card(XSdPs *SdInstance, FATFS *FS_Instance) {
    XSdPs_Config *SD_Config;
    FRESULT f_res;

    xil_printf("Check SD CARD exist...\r\n");
    u32 StatusReg = XSdPs_GetPresentStatusReg(XPAR_XSDPS_0_BASEADDR);
    if ((StatusReg & XSDPS_PSR_CARD_INSRT_MASK) == 0)
    {
		// No disk
    	xil_printf("FATAL ERROR : No DISK\r\n");
		return XST_FAILURE;
    }
    else
    {
		if (StatusReg & XSDPS_PSR_WPS_PL_MASK)
		{
			// Not write protected
		}
		else
		{
			// Write protected
		}
    }
    xil_printf("Checked SD CARD exist...\r\n");

    xil_printf("Initialize SD CARD driver...\r\n");
    // Initialize SD card controller driver
    SD_Config = XSdPs_LookupConfig(XPAR_XSDPS_0_DEVICE_ID);
    if (SD_Config == NULL) {
    	xil_printf("FATAL ERROR : SD_Config is NULL\r\n");
        return XST_FAILURE;
    }
    xil_printf("Initialized SD CARD driver...\r\n");

    XSdPs_CfgInitialize(SdInstance, SD_Config, SD_Config->BaseAddress);

    // Use the Hc_Mode for high-capacity SD cards
    SdInstance->Config.BusWidth = XSDPS_WIDTH_4;
    SdInstance->Config.CardDetect = 1;

    xil_printf("Initialize SD CARD blocks...\r\n");
    // Initialize the card and set appropriate block size
    if (XSdPs_SdCardInitialize(SdInstance) != XST_SUCCESS){
    	xil_printf("WARNING : SD Card initialization with block size failed\r\n");
    	xil_printf("WARNING : SD Card seems to be already initialized\r\n");
    }
    xil_printf("Initialized SD CARD blocks...\r\n");

    xil_printf("Mount SD CARD...\r\n");
    // Mount the FAT file system
    f_res = f_mount(FS_Instance, "", 0);
    if (f_res != FR_OK) {
    	xil_printf("FATAL ERROR : FAT Mount failed\r\n");
        return XST_FAILURE;
    }
    xil_printf("Mounted SD CARD...\r\n");

    xil_printf("SD CARD Initialization Done...\r\n");
    return XST_SUCCESS;
}
