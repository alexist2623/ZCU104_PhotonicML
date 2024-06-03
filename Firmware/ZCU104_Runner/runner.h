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
#define INT_ID_STOP_DISPLAY 			0x0
#define INT_ID_RUN_DISPLAY 				0x1
#define INT_ID_LOAD_SD_CARD				0x2
#define INT_ID_SET_NEW_IMAGE			0x3
#define INT_ID_SET_TEST					0x4


/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
//0xF9020000U
#define CPU_BASEADDR					XPAR_SCUGIC_0_CPU_BASEADDR
//0xF9010000U
#define DIST_BASEADDR					XPAR_SCUGIC_0_DIST_BASEADDR
#define GIC_DEVICE_INT_MASK        		0x00010000
#define PL_INTID						121

// Note that XPAR_ constants are defined in xparameters.h files which is dependent on xsa file
#define MASTER_CONTROLLER_ADDR			XPAR_MASTERCONTROLLER_0_BASEADDR
#define CAMERAEXPOSUREEND_ADDR 			XPAR_CAMERAEXPOSUREEND_BASEADDR
#define CAMERAEXPOSUREEND_DELAY			(XPAR_CAMERAEXPOSUREEND_BASEADDR | 0x10U)
#define CAMERAEXPOSUREEND_EVENT			(XPAR_CAMERAEXPOSUREEND_BASEADDR | 0x20U)
#define CAMERAEXPOSUREEND_POLARITY		(XPAR_CAMERAEXPOSUREEND_BASEADDR | 0x30U)
#define CAMERAEXPOSURESTART_ADDR 		XPAR_CAMERAEXPOSURESTART_BASEADDR
#define CAMERAEXPOSURESTART_DELAY		(XPAR_CAMERAEXPOSURESTART_BASEADDR | 0x10U)
#define CAMERAEXPOSURESTART_EVENT 		(XPAR_CAMERAEXPOSURESTART_BASEADDR | 0x20U)
#define CAMERAEXPOSURESTART_POLARITY 	(XPAR_CAMERAEXPOSURESTART_BASEADDR | 0x30U)
#define IMAGE_CONTROLLER_ADDR			XPAR_IMAGECONTROLLER_0_BASEADDR
#define SET_IMAGE_SIZE              	(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x20U)
#define IMAGE_DATA_DONE_ADDR			(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x30U)
#define IMAGE_DATA_WRITE_ADDR			(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x40U)
#define SET_NEW_IMAGE_ADDR				(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x50U)
#define DEASSERT_IRQ_ADDR				(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x60U)
#define SET_TEST_ADDR					(XPAR_IMAGECONTROLLER_0_BASEADDR | 0x70U)

#define DATA_SAVE_MEM_ADDR				0x2000000U
#define IMAGE_WRITE_TIME				625
#define S_AXI_WDATA_SIZE				16
#define SCREEN_WIDTH					100
#define SCREEN_HEIGHT					100
#define IMAGE_SIZE						10000 // 100 x 100 size image

/************************** 128 bit make macro *******************************/
#define MAKE128CONST(hi,lo) 			((((__uint128_t)hi << 64) | (lo)))
#define UPPER(x) 						(uint64_t)( ( (x) >> 64 ) & MASK64BIT)
#define LOWER(x) 						(uint64_t)( (x) & MASK64BIT )
#define MASK64BIT 						((uint64_t) 0xffffffffffffffff)

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
void initialize_modules();

/********************* InterruptControll Prototypes ****************************/
void LowInterruptHandler(u32 CallbackRef);
void XScuGic_ClearPending (u32 DistBaseAddress, u32 Int_Id);
void initialize_interrupt();

/**************** ImageControllerDriver Function Prototypes ******************/
void deassert_irq();
void write_80000_data(void * data_source_addr);
void set_new_image();
void data_write_done();
void set_image_size(uint64_t width, uint64_t height);

/**************** MasterControllerDriver Function Prototypes *****************/
void auto_start();
void auto_stop();
void reset_enable();
void reset_disable();

/***************** IOControllerDriver Function Prototypes ********************/
void set_camera_exposure_start_delay(uint64_t delay_value);
void set_camera_exposure_start_event(uint64_t event_value);
void set_camera_exposure_start_polarity(uint64_t polarity_value);
void set_camera_exposure_end_delay(uint64_t delay_value);
void set_camera_exposure_end_event(uint64_t event_value);
void set_camera_exposure_end_polarity(uint64_t polarity_value);

/********************* sdcard.c Function Prototypes **************************/
int init_sd_card(XSdPs *SdInstance, FATFS *FS_Instance);
int load_sd_card_data();
int umount_sd_card();
int read_sd_card(char * file_name);

#endif
