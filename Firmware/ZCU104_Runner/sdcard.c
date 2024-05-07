#include "runner.h"

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

int read_sd_card() {
    XSdPs SdInstance;
    FATFS FS_Instance;
    FIL fil;
    FRESULT f_res;
    UINT br;

    /*
     * Initialize SD card and mount file system
     */
    if (init_sd_card(&SdInstance, &FS_Instance) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    /*
     * Open file to read
     */
    f_res = f_open(&fil, "test.txt", FA_READ);
    if (f_res) {
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
    char buffer[100];
    f_res = f_read(&fil, buffer, sizeof(buffer), &br);
    if (f_res || br == 0) {
        f_close(&fil);
        return XST_FAILURE;
    }
    for(int i = 0 ; i < 100 ; i++ ){
    	xil_printf("%d\r\n",buffer[i]);
    }

    /*
     * Close the file
     */
    f_close(&fil);

    /*
     *  Unmount the file system
     */
    f_mount(NULL, "", 0);

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

    // Initialize SD card controller driver
    SD_Config = XSdPs_LookupConfig(XPAR_XSDPS_0_DEVICE_ID);
    if (SD_Config == NULL) {
        return XST_FAILURE;
    }

    XSdPs_CfgInitialize(SdInstance, SD_Config, SD_Config->BaseAddress);

    // Use the Hc_Mode for high-capacity SD cards
    SdInstance->Config.BusWidth = XSDPS_WIDTH_4;
    SdInstance->Config.CardDetect = 1;

    // Initialize the card and set appropriate block size
    if (XSdPs_SdCardInitialize(SdInstance) != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Mount the FAT file system
    f_res = f_mount(FS_Instance, "", 0);
    if (f_res != FR_OK) {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}
