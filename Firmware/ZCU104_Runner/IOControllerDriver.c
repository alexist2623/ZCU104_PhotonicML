#include "runner.h"
/*****************************************************************************/
/**
*
* This function send commands to CameraExposureStart module (IOController)
* to set delay time from input signal to output signal
*
* @param	uint64_t delay_value
* 			delay cycle from input signal to output signal
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_start_delay(uint64_t delay_value){
	xil_printf("Setting camera exposure_start delay to %d...\r\n", delay_value);
	Xil_Out128(CAMERAEXPOSURESTART_DELAY,
			MAKE128CONST(0,(uint64_t)(delay_value & 0xffffffffffffffff)));
}
/*****************************************************************************/
/**
*
* This function sends commands to the CameraExposureStart module (IOController)
* to set the event time, which triggers the output signal when the input signal
* count matches the specified event time.
*
* @param	uint64_t event_value
* 			event value which starts to make output signal when input signal
* 			is counted as this value
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_start_event(uint64_t event_value){
	xil_printf("Setting camera exposure_start event %d...\r\n", event_value);
	Xil_Out128(CAMERAEXPOSURESTART_EVENT,
			MAKE128CONST(0,(uint64_t)(event_value & 0xffffffffffffffff)));
}
/*****************************************************************************/
/**
*
* This function send commands to CameraExposureStart module (IOController) to
* set polarity of input signal
*
* @param	uint64_t polarity_value
* 			0 -> Positive sensitive, 1 -> Negative sensitve
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_start_polarity(uint64_t polarity_value){
	xil_printf("Setting camera exposure_start polarity %d...\r\n", polarity_value);
	Xil_Out128(CAMERAEXPOSURESTART_POLARITY,
			MAKE128CONST(0,(uint64_t)(polarity_value & 0xffffffffffffffff)));
}
/*****************************************************************************/
/**
*
* This function send commands to CameraExposureEnd module (IOController)
* to set delay time from input signal to output signal
*
* @param	uint64_t delay_value
* 			delay cycle from input signal to output signal
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_end_delay(uint64_t delay_value){
	xil_printf("Setting camera exposure_end delay to %d...\r\n", delay_value);
	Xil_Out128(CAMERAEXPOSUREEND_DELAY,
			MAKE128CONST(0,(uint64_t)(delay_value & 0xffffffffffffffff)));
}
/*****************************************************************************/
/**
*
* This function sends commands to the CameraExposureEnd module (IOController)
* to set the event time, which triggers the output signal when the input signal
* count matches the specified event time.
*
* @param	uint64_t event_value
* 			event value which starts to make output signal when input signal
* 			is counted as this value
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_end_event(uint64_t event_value){
	xil_printf("Setting camera exposure_end event %d...\r\n", event_value);
	Xil_Out128(CAMERAEXPOSUREEND_EVENT,
			MAKE128CONST(0,(uint64_t)(event_value & 0xffffffffffffffff)));
}
/*****************************************************************************/
/**
*
* This function send commands to CameraExposureEnd module (IOController) to
* set polarity of input signal
*
* @param	uint64_t polarity_value
* 			0 -> Positive sensitive, 1 -> Negative sensitve
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_end_polarity(uint64_t polarity_value){
	xil_printf("Setting camera exposure_end polarity %d...\r\n", polarity_value);
	Xil_Out128(CAMERAEXPOSUREEND_POLARITY,
			MAKE128CONST(0,(uint64_t)(polarity_value & 0xffffffffffffffff)));
}
