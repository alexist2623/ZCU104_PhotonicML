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
void set_camera_exposure_start_polarity(uint64_t input_polarity_value, uint64_t output_polarity_value, uint64_t timer_value){
	if(input_polarity_value == 1){
		xil_printf("Setting camera exposure_start input_polarity_value Negative...\r\n");
	}
	else if(input_polarity_value == 0){
		xil_printf("Setting camera exposure_start input_polarity_value Positive...\r\n");
	}
	else{
		xil_printf("Setting camera exposure_start input_polarity_value default Positive...\r\n");
	}
	if(output_polarity_value == 1){
		xil_printf("Setting camera exposure_start output_polarity_value Negative...\r\n");
	}
	else if(output_polarity_value == 0){
		xil_printf("Setting camera exposure_start output_polarity_value Positive...\r\n");
	}
	else{
		xil_printf("Setting camera exposure_start output_polarity_value default Positive...\r\n");
	}
	xil_printf("Setting camera exposure_start_timer %d..\r\n",timer_value);
	Xil_Out128(CAMERAEXPOSURESTART_POLARITY,
			MAKE128CONST(0,(uint64_t)(input_polarity_value & 0x1) << 63
					| (uint64_t)(output_polarity_value & 0x1) << 62)
					| (uint64_t)(timer_value & 0x3fffffffffffffff));
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
void set_camera_exposure_end_polarity(uint64_t input_polarity_value, uint64_t output_polarity_value, uint64_t timer_value){
	if(input_polarity_value == 1){
		xil_printf("Setting camera exposure_end input_polarity_value Negative...\r\n");
	}
	else if(input_polarity_value == 0){
		xil_printf("Setting camera exposure_end input_polarity_value Positive...\r\n");
	}
	else{
		xil_printf("Setting camera exposure_end input_polarity_value default Positive...\r\n");
	}
	if(output_polarity_value == 1){
		xil_printf("Setting camera exposure_end output_polarity_value Negative...\r\n");
	}
	else if(output_polarity_value == 0){
		xil_printf("Setting camera exposure_end output_polarity_value Positive...\r\n");
	}
	else{
		xil_printf("Setting camera exposure_end output_polarity_value default Positive...\r\n");
	}
	xil_printf("Setting camera exposure_end_timer %d..\r\n",timer_value);
	Xil_Out128(CAMERAEXPOSUREEND_POLARITY,
			MAKE128CONST(0,(uint64_t)(input_polarity_value & 0x1) << 63
					| (uint64_t)(output_polarity_value & 0x1) << 62)
					| (uint64_t)(timer_value & 0x3fffffffffffffff));
}
/*****************************************************************************/
/**
*
* This function send commands to CameraExposureStart module
*
* @param	uint64_t polarity_value
* 			0 -> Positive sensitive, 1 -> Negative sensitve
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_start(){
	volatile uint64_t * temp_addr = (volatile uint64_t *) DATA_SAVE_MEM_ADDR;
	uint64_t data = *(temp_addr);
	set_camera_exposure_start_delay(data  & 0xfffffffffffffff);
	set_camera_exposure_start_event((data >> 56) & 0x7 );
	//set_camera_exposure_start_polarity((data >> 63) & 0x1 );
}

/*****************************************************************************/
/**
*
* This function send commands to CameraExposureEnd module
*
* @param	uint64_t polarity_value
* 			0 -> Positive sensitive, 1 -> Negative sensitve
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_camera_exposure_end(){
	volatile uint64_t * temp_addr = (volatile uint64_t *) DATA_SAVE_MEM_ADDR;
	uint64_t data = *(temp_addr);
	set_camera_exposure_end_delay(data  & 0xfffffffffffffff);
	set_camera_exposure_end_event((data >> 56) & 0x7 );
	//set_camera_exposure_end_polarity((data >> 63) & 0x1 );
}
