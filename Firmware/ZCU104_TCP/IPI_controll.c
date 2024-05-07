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
