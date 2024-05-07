#ifndef _ZCU104RUNNER_
#define _ZCU104RUNNER_

#include <stdio.h>
#include "xparameters.h"
#include "xil_exception.h"
#include "xscugic_hw.h"
#include "xil_printf.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"
#include "xtime_l.h"
#include "xsdps.h"       // SD device driver
#include "ff.h"          // FatFs library

/****************** Define Interrupt ID for each function ********************/
#define INT_ID_STOP_DISPLAY 		0x0
#define INT_ID_RUN_DISPLAY 			0x1
#define INT_ID_LOAD_SD_CARD			0x2


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
#define IMAGE_DATA_DONE_ADDR		0xA0010030U
#define IMAGE_DATA_WRITE_ADDR		0xA0010040U
#define DATA_SAVE_MEM_ADDR			0x2000000U
#define IMAGE_WRITE_TIME			625
#define S_AXI_WDATA_SIZE			16
#define SCREEN_WIDTH				100
#define SCREEN_HEIGHT				100

/************************** 128 bit make macro *******************************/
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

/********************* main Function Prototypes ******************************/

void LowInterruptHandler(u32 CallbackRef);
void XScuGic_ClearPending (u32 DistBaseAddress, u32 Int_Id);
void initialize_modules();
void initialize_interrupt();
void write_80000_data(void * data_source_addr);
void auto_start();

/********************* sdcard.c Function Prototypes **************************/
int init_sd_card(XSdPs *SdInstance, FATFS *FS_Instance);
int read_sd_card();

#endif
