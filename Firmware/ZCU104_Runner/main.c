#include "runner.h"
/**************************** Global Variables *******************************/
/*
 * image_irq_ack variable should be declared as a volatile type to prevent
 * compile optimization.
 */
volatile int image_irq_ack = 0;

/*****************************************************************************/
/**
*
* This function clears pending state of interrupt signal.
*
* @param	DistBaseAddress : address of GICD in Armv8
* 			Int_Id			: Interrupt ID which you want to clear pending
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void XScuGic_ClearPending (u32 DistBaseAddress, u32 Int_Id)
{
	u8 Cpu_Id = (u8)XScuGic_GetCpuID();
	XScuGic_WriteReg((DistBaseAddress), XSCUGIC_PENDING_CLR_OFFSET +
			(((Int_Id) / 32U) * 4U), (0x00000001U << ((Int_Id) % 32U)));
}

/*****************************************************************************/
/**
*
* This function connects the interrupt handler of the interrupt controller to
* the processor.  This function is separate to allow it to be customized for
* each application.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void LowInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;

	/*
	 * CallbackRef is defined at calling function Xil_ExceptionRegisterHandler
	 * as a CPU_BASEADDR
	 */
	BaseAddress = CallbackRef;

	/*
	 * Set Interrupt Acknowledge resgister (GICC_IAR) -> Make interrupt machine
	 * state to active from pending
	 * In addition get interrupt ID of interrupt
	 */
	IntID = XScuGic_ReadReg(BaseAddress,
			XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;

	/*
	 * Stop interrupt handler when INTID is bigger than maximum number of
	 *  interrupt signals defined in ZynqMP
	 */
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
		xil_printf("INTID exceeds maximum number of interrupts "
					"defined in ZynqMP\r\n");
		xil_printf("IndID : %d\r\n",IntID);
		return;
	}

	/*
	 * Set End Of Inerrupt register (GICC_EOI)
	 */
	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);

	switch(IntID){
		case INT_ID_STOP_DISPLAY:
			xil_printf("STOP DISPLAY INT\r\n");
			auto_stop();
			break;
		case INT_ID_RUN_DISPLAY:
			xil_printf("RUN DISPLAY INT\r\n");
			auto_start();
			break;
		case INT_ID_LOAD_SD_CARD:
			xil_printf("LOAD SD CARD INT\r\n");
			read_sd_card();
			break;
		case PL_INTID:
			image_irq_ack = 1;
			write_80000_data(NULL);
			break;
		default:
			break;
	}
	return;
}

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
	xil_printf("Reset Controllers...\r\n");
	/*
	 * Assert Reset signal from MasterController
	 */
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0010));
	usleep(1);

	xil_printf("Reset Controllers Done...\r\n");
	/*
	 * Deassert reset signal from MasterController
	 */
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0000));


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
	Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x20,
			MAKE128CONST( 0, (((uint64_t)SCREEN_WIDTH) << 32) | SCREEN_HEIGHT ));

	return;
}

/*****************************************************************************/
/**
*
* This function initialize the Generic Interrupt Controller of ARMv8(GICv2).
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void initialize_interrupt(){
	/*
	 * Clear Pending
	 */
	XScuGic_ClearPending(DIST_BASEADDR,PL_INTID);


	/*
	 * Set Ineterrupt handler function which will be run at IRQ interrupt
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
								 (Xil_ExceptionHandler) LowInterruptHandler,
								 (void *)CPU_BASEADDR);

	/*
	 * Set Interrupt Priority Mask resgister (GICC_PMR)
	 */
	XScuGic_WriteReg(CPU_BASEADDR,
			XSCUGIC_CPU_PRIOR_OFFSET, 0xF0);

	/*
	 * Set CPU Interface Controller Register (GICC_CTLR)
	 */
	XScuGic_WriteReg(CPU_BASEADDR,
			XSCUGIC_CONTROL_OFFSET, 0x01);

	/*
	 * Set INTID priority (GICD_IPRIORITYR)
	 */
	XScuGic_WriteReg(DIST_BASEADDR,
			XSCUGIC_PRIORITY_OFFSET_CALC(PL_INTID), 0xFF);

	/*
	 * Set target processor of INTID (GICD_ITARGETSR<n>)
	 */
	XScuGic_WriteReg(DIST_BASEADDR,
			XSCUGIC_SPI_TARGET_OFFSET_CALC(PL_INTID), 0x02);

	/*
	 * Set Interrupt to Level Sensitive (GICD_ICFGR<n>)
	 */
	XScuGic_WriteReg(DIST_BASEADDR,
			XSCUGIC_INT_CFG_OFFSET_CALC(PL_INTID), 0x0);

	/*
	 * Set INTID enable (GICD_ISENABLER)
	 */
	XScuGic_EnableIntr(DIST_BASEADDR, PL_INTID);

	/*
	 * Exception Enable
	 */
	Xil_ExceptionEnable();

	/*
	 * Disable Nested Interrupts. It is disabled now, since it makes
	 * interrupt donnot work
	 */
	//Xil_DisableNestedInterrupts();

	xil_printf("GIC Controller initialized\r\n");

	return;
}

/*****************************************************************************/
/**
*
* This function writes 80000 bit data(100x100 image) to ImageController.
*
* @param	data_source_addr : Start address of data which you want to write.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void write_80000_data(void * data_source_addr){
	/*
	 * Send test image data to ImageController if data_source_addr == NULL
	 */
	if( data_source_addr == NULL ){
		for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
			Xil_DCacheFlush();
			xil_printf("%d\r\n",i);
			Xil_Out128(IMAGE_DATA_WRITE_ADDR,
					MAKE128CONST((uint64_t) 0xffff,(uint64_t) i) );
		}
	}
	else{
		volatile uint64_t * data_addr;
		data_addr = (volatile uint64_t *) data_source_addr;
		for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
			Xil_DCacheFlush();
			xil_printf("%d\r\n",i);
			Xil_Out128(IMAGE_DATA_WRITE_ADDR,
					MAKE128CONST((uint64_t) (data_addr + 2 * i + 1),
							(uint64_t) (data_addr + 2 * i )) );
		}
	}
	return;
}

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
