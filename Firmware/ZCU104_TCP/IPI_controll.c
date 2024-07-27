#include <stdio.h>
#include "zcu104irq.h"

/*****************************************************************************/
/**
*
* This function makes other processor to deassert MasterController 
* auto_start signal
* @param	None
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_stop_display(){
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET, 
            GIC_DEVICE_INT_MASK | INT_ID_STOP_DISPLAY );
}

/*****************************************************************************/
/**
*
* This function makes other processor to assert MasterController
* auto_start signal
* @param	None
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_run_display(){
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET, 
            GIC_DEVICE_INT_MASK| INT_ID_RUN_DISPLAY );
}

/*****************************************************************************/
/**
*
* This function makes other processor to load data from sd card
* @param	None
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_load_sdcard(){
    XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET, 
            GIC_DEVICE_INT_MASK| INT_ID_LOAD_SD_CARD );
}

/*****************************************************************************/
/**
*
* This function makes other processor to load new image
* @param	None
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_set_new_image(){
    XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET,
            GIC_DEVICE_INT_MASK| INT_ID_SET_NEW_IMAGE );
}

/*****************************************************************************/
/**
*
* This function sets test parameters of FPGA
* @param	None
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_set_test(uint64_t test_mode, uint64_t test_data, uint64_t start_X,
							uint64_t start_Y, uint64_t end_X, uint64_t end_Y){
	volatile uint64_t * data_addr = (volatile uint64_t *) DATA_SAVE_MEM_ADDR;

	/*
	 * Flush cache to make sure to transfer data
	 */
	Xil_DCacheFlush();
	Xil_ICacheInvalidate();

	* data_addr = (	(test_mode & 0x1) << 63 | ( test_data & 0xff ) << 48
					| (start_X & 0xfff) << 36 | (start_Y & 0xfff) << 24
					| (end_X & 0xfff) << 12 | (end_Y & 0xfff) );
    XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET,
            GIC_DEVICE_INT_MASK| INT_ID_SET_TEST );
}


/*****************************************************************************/
/**
*
* This function sets camera exposure start option of FPGA
* @param	polarity : 1bit, event : 7bit, delay : 56 bit
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_set_cam_exp_start(uint64_t polarity, uint64_t event, uint64_t delay){
	volatile uint64_t * data_addr = (volatile uint64_t *) DATA_SAVE_MEM_ADDR;
	/*
	 * Flush cache to make sure to transfer data
	 */
	Xil_DCacheFlush();
	Xil_ICacheInvalidate();

	* data_addr = (	(polarity & 0x1) << 63
					| ( event & 0x7 ) << 56
					| (delay & 0xfffffffffffffff ) );
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET,
			GIC_DEVICE_INT_MASK| INT_ID_SET_CAM_EXP_SATRT );
}

/*****************************************************************************/
/**
*
* This function sets camera exposure end option of FPGA
* @param	polarity : 1bit, event : 7bit, delay : 56 bit
*
* @return	None
*
* @note		None.
*
******************************************************************************/
void IPI_set_cam_exp_end(uint64_t polarity, uint64_t event, uint64_t delay){
	volatile uint64_t * data_addr = (volatile uint64_t *) DATA_SAVE_MEM_ADDR;
	/*
	 * Flush cache to make sure to transfer data
	 */
	Xil_DCacheFlush();
	Xil_ICacheInvalidate();

	* data_addr = ( (polarity & 0x1) << 63
					| ( event & 0x7 ) << 56
					| (delay & 0xfffffffffffffff ) );
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SFI_TRIG_OFFSET,
			GIC_DEVICE_INT_MASK| INT_ID_SET_CAM_EXP_END );
}
