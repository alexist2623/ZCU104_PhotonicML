#include <stdio.h>
#include "xparameters.h"
#include "xil_exception.h"
#include "xscugic_hw.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"
#include "xtime_l.h"

/* Define Interrupt ID for each function*/
#define INT_ID_STOP_DISPLAY 		0x0
#define INT_ID_RUN_DISPLAY 			0x1
#define INT_ID_LOAD_SD_CARD			0x2
#define SCREEN_WIDTH				100
#define SCREEN_HEIGHT				100

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
#define DATA_SAVE_MEM_ADDR			0x2000000U
#define IMAGE_WRITE_TIME			625
#define S_AXI_WDATA_SIZE			16

// image_irq_ack variable should be declared as a volatile type to prevent
// compile optimization.
volatile int image_irq_ack = 0;
XScuGic InterruptController;

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
void XScuGic_ClearPending (u32 DistBaseAddress, u32 Int_Id)
{
	u8 Cpu_Id = (u8)XScuGic_GetCpuID();
	XScuGic_WriteReg((DistBaseAddress), XSCUGIC_PENDING_CLR_OFFSET +
			(((Int_Id) / 32U) * 4U), (0x00000001U << ((Int_Id) % 32U)));
}

void LowInterruptHandler(u32 CallbackRef)
{
	u32 BaseAddress;
	u32 IntID;
    u32 IntIDFull;
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
	//xil_printf("INT : %d\r\n",IntID);
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
			image_irq_ack = 1;
			for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
				Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x30, MAKE128CONST(MASK64BIT,MASK64BIT));
			}
			break;
		default:
			break;
	}
	//xil_printf("IRQ END\r\n");
	return;
}

int main(void)
{
	xil_printf("CPU 1 turned on\r\n");

	/////////////////////////////////////////////////////////////////////
	// Initialize Device
	/////////////////////////////////////////////////////////////////////

	xil_printf("Waiting for command...\r\n");
	xil_printf("Reset Controllers...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0010));
	usleep(1);
	xil_printf("Reset Controllers Done...\r\n");
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b0000));


	xil_printf("Write ADDR FIFO...\r\n");
	Xil_Out128(IMAGE_CONTROLLER_ADDR,MAKE128CONST(
			(uint64_t)(0x0000004000U) + (uint64_t)(SCREEN_WIDTH * SCREEN_HEIGHT * 8),
			(uint64_t)0x0000004000U ) );

	xil_printf("Write Display Resolution...\r\n");
	Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x20,MAKE128CONST( 0, (((uint64_t)SCREEN_WIDTH) << 32) | SCREEN_HEIGHT ));

	//Clear Pending
	XScuGic_ClearPending(DIST_BASEADDR,PL_INTID);
	/////////////////////////////////////////////////////////////////////
	// Set Interrupt
	/////////////////////////////////////////////////////////////////////

	// Set Ineterrupt handler function which will be run at IRQ interrupt
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
								 (Xil_ExceptionHandler) LowInterruptHandler,
								 (void *)CPU_BASEADDR);
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
	// Exception Enable
	Xil_ExceptionEnable();
	// Disable Nested Interrupts
	//Xil_DisableNestedInterrupts();

	xil_printf("GIC Controller initialized\r\n");

	xil_printf("Read Resolution\r\n");
	__uint128_t a;
	a = Xil_In128(IMAGE_CONTROLLER_ADDR + 0x10);
	int x;
	int y;
	x = 0xffff & (LOWER(a) >> 32);
	y = 0xffff & LOWER(a);
	xil_printf("X : %d, Y : %d\r\n",x,y);

	sleep(5);

	xil_printf("memory armed...\r\n");

	xil_printf("Auto Start...\r\n");
	sleep(1);
	Xil_Out128(MASTER_CONTROLLER_ADDR,MAKE128CONST(0,0b1001));

	int k = 0;
	while(1){
		if( image_irq_ack == 1 ){
			image_irq_ack = 0;
			Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x40, MAKE128CONST(0,1) );
			//xil_printf("PL WRITE\r\n");
			k++;
		}
		if( k == 60 ){
			k = 0;
			xil_printf("DONE\r\n");
		}
	}
}
