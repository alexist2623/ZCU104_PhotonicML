#include <stdio.h>
#include "xparameters.h"
#include "xil_exception.h"
#include "xscugic_hw.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"

/* Define Interrupt ID for each function*/
#define INT_ID_STOP_DISPLAY 		0x0
#define INT_ID_RUN_DISPLAY 			0x1
#define INT_ID_LOAD_SD_CARD			0x2

/*128 bit make macro*/
#define MAKE128CONST(hi,lo) ((((__uint128_t)hi << 64) | (lo)))
#define UPPER(x) (uint64_t)( ( (x) >> 64 ) & MASK64BIT)
#define LOWER(x) (uint64_t)( (x) & MASK64BIT )
#define MASK64BIT ((uint64_t) 0xffffffffffffffff)

static INLINE void Xil_Out128(UINTPTR Addr, __uint128_t Value)
{
	volatile __uint128_t *LocalAddr = (volatile __uint128_t *)Addr;
	*LocalAddr = Value;
}
static INLINE __uint128_t Xil_In128(UINTPTR Addr)
{
	volatile __uint128_t *LocalAddr = (volatile __uint128_t *)Addr;
	return *LocalAddr;
}
/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
//0xF9020000U
#define CPU_BASEADDR				XPAR_SCUGIC_0_CPU_BASEADDR
//0xF9010000U
#define DIST_BASEADDR				XPAR_SCUGIC_0_DIST_BASEADDR
#define GIC_DEVICE_INT_MASK        	0x00010000
#define PL_INTID					121
#define MASTER_CONTROLLER_ADDR		0xA0000000U
#define IMAGE_CONTROLLER_ADDR		0xA0010000U
#define IMAGE_WRITE_TIME			15

static int j = 0;
static int image_irq_ack = 0;

/************************** Function Prototypes ******************************/

void LowInterruptHandler(u32 CallbackRef);


/*****************************************************************************/
/**
*
* This function connects the interrupt handler of the interrupt controller to
* the processor.  This function is separate to allow it to be customized for
* each application.  Each processor or RTOS may require unique processing to
* connect the interrupt handler.
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
	// CallbackRef is defined at calling function Xil_ExceptionRegisterHandler as a CPU_BASEADDR
	BaseAddress = CallbackRef;

	// Set Interrupt Acknowledge resgister (GICC_IAR) -> Make interrupt machine state to active from pending
	// In addition get interrupt ID of interrupt
	IntID = XScuGic_ReadReg(BaseAddress, XSCUGIC_INT_ACK_OFFSET) & XSCUGIC_ACK_INTID_MASK;

	// Stop interrupt handler when INTID is bigger than maximum number of interrupt signals defined in ZynqMP
	if (XSCUGIC_MAX_NUM_INTR_INPUTS < IntID) {
		xil_printf("INTID exceeds maximum number of interrupts defined in ZynqMP\r\n");
		xil_printf("IndID : %d\r\n",IntID);
		return;
	}

	// Set End Of Inerrupt register (GICC_EOI)
	XScuGic_WriteReg(BaseAddress, XSCUGIC_EOI_OFFSET, IntID);
	__uint128_t a;

	switch(IntID){
		case INT_ID_STOP_DISPLAY:
			xil_printf("STOP DISPLAY INT\r\n");
			break;
		case INT_ID_RUN_DISPLAY:
			xil_printf("RUN DISPLAY INT\r\n");
			break;
		case INT_ID_LOAD_SD_CARD:
			xil_printf("LOAD SD CARD INT\r\n");
			break;
		case PL_INTID:
			a = Xil_In128(IMAGE_CONTROLLER_ADDR);
			xil_printf("PL WIRTE\r\n");
			xil_printf("LOW   : %x\r\n",LOWER(a));
			xil_printf("UPPER : %x\r\n",UPPER(a));
			image_irq_ack = 1;
			Xil_DCacheFlush();
			for(int i = 0 ; i < IMAGE_WRITE_TIME; i++){
				Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x30,MAKE128CONST(0x0,0xffffffffffffffff));
			}
			break;
		default:
			break;
	}
}

int main(void)
{
	xil_printf("CPU 1 turned on\r\n");

	// Set Interrupt Priority Mask resgister (GICC_PMR)
	XScuGic_WriteReg(CPU_BASEADDR, XSCUGIC_CPU_PRIOR_OFFSET, 0xF0);
	// Set CPU Interface Controller Register (GICC_CTLR)
	XScuGic_WriteReg(CPU_BASEADDR, XSCUGIC_CONTROL_OFFSET, 0x01);
	// Set INTID priority (GICD_IPRIORITYR)
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_PRIORITY_OFFSET_CALC(PL_INTID), 0xFF);
	// Set target processor of INTID (GICD_ITARGETSR<n>)
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_SPI_TARGET_OFFSET_CALC(PL_INTID), 0x02);
	// Set Interrupt to Level Sensitive (GICD_ICFGR<n>)
	XScuGic_WriteReg(DIST_BASEADDR, XSCUGIC_INT_CFG_OFFSET_CALC(PL_INTID), 0x0);
	// Set INTID enable (GICD_ISENABLER)
	XScuGic_EnableIntr(DIST_BASEADDR, PL_INTID);
	// Set Ineterrupt handler function which will be run at IRQ interrupt
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
								 (Xil_ExceptionHandler) LowInterruptHandler,
								 (void *)CPU_BASEADDR);
	Xil_ExceptionEnable();

	xil_printf("GIC Controller initialized\r\n");
	xil_printf("Waiting for command...\r\n");
	xil_printf("Reset Controllers...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0110));
	usleep(1);
	xil_printf("Reset Controllers Done...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0000));


	xil_printf("Write ADDR FIFO...\r\n");
	Xil_Out128(IMAGE_CONTROLLER_ADDR,MAKE128CONST( (0x0500000000U),  0x0400000000U ) );
	xil_printf("Write Display Resolution...\r\n");
	Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x20,MAKE128CONST( 0, (1920 << 32 | 1080) ) );

	sleep(20);
	xil_printf("Auto Start...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b1001));
	while(1){
		if( image_irq_ack ){
			image_irq_ack = 0;
			Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x40, MAKE128CONST(0,1) );
		}
	}
}
