#include "runner.h"

/*****************************************************************************/
/**
*
* This function send commands to MasterController to assert auto_start signal.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void auto_start(){
	xil_printf("Auto Start...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b1001));
}

/*****************************************************************************/
/**
*
* This function send commands to MasterController to deassert auto_start signal.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void auto_stop(){
	xil_printf("Auto Stop...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0000));
}

/*****************************************************************************/
/**
*
* This function send commands to MasterController to assert reset signal.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void reset_enable(){
	xil_printf("Reset Enable...\r\n");
  	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0010));
}

/*****************************************************************************/
/**
*
* This function send commands to MasterController to deassert reset signal.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void reset_disable(){
	xil_printf("Reset Disable...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0000));
}