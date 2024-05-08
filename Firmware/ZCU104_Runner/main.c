#include "runner.h"
/**************************** Global Variables *******************************/
/*
 * image_irq_ack variable should be declared as a volatile type to prevent
 * compile optimization.
 */
volatile extern int image_irq_ack = 0;

/*****************************************************************************/
/**
*
* This function initialize the ImageController, MasterController modules. It
* makes reset signal for all modules with 1us, and send image size data to
* ImageController.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void initialize_modules(){
	xil_printf("Waiting for command...\r\n");
	/*
	 * Assert Reset signal from MasterController
	 */
    reset_enable();
	usleep(1);

	/*
	 * Deassert reset signal from MasterController
	 */
    reset_disable();


	xil_printf("Write ADDR FIFO...\r\n");
	/*
	 * Send DRAM data address to ImageController FIFO
	 */
	Xil_Out128(IMAGE_CONTROLLER_ADDR,MAKE128CONST(
			(uint64_t)(0x0000004000U) +
			(uint64_t)(SCREEN_WIDTH * SCREEN_HEIGHT * 8),
			(uint64_t)0x0000004000U ) );

	xil_printf("Write Display Resolution...\r\n");
	/*
	 * Set ImageResolution of data discharging from ImageController
	 */
set_image_size((uint64_t)SCREEN_WIDTH, (uint64_t)SCREEN_HEIGHT);

	return;
}

/*****************************************************************************/
/**
*
* Main function.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
int main(void)
{
	xil_printf("CPU 1 turned on\r\n");

	/////////////////////////////////////////////////////////////////////
	// Initialize Modules
	/////////////////////////////////////////////////////////////////////
	initialize_modules();

	/////////////////////////////////////////////////////////////////////
	// Set Interrupt
	/////////////////////////////////////////////////////////////////////
	initialize_interrupt();

	/////////////////////////////////////////////////////////////////////
	// Send 100x100 test image data to ImageController
	/////////////////////////////////////////////////////////////////////
	write_80000_data(NULL);
	write_80000_data(NULL);
	xil_printf("memory armed...\r\n");

	/////////////////////////////////////////////////////////////////////
	// Auto Start
	/////////////////////////////////////////////////////////////////////
	auto_start();

	while(1){
		if( image_irq_ack == 1 ){
			image_irq_ack = 0;
			Xil_Out128(IMAGE_DATA_DONE_ADDR, MAKE128CONST(0,1) );
			xil_printf("PL WRITE\r\n");
		}
	}
}