#include "runner.h"

uint64_t k = 0;
/*****************************************************************************/
/**
*
* This function send commands to ImageController to deassert irq signal.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void deassert_irq(){
	Xil_Out128(DEASSERT_IRQ_ADDR,MAKE128CONST(0,0b1));
}

/*****************************************************************************/
/**
*
* This function send commands to ImageController to set new image.
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_new_image(){
    Xil_Out128(SET_NEW_IMAGE_ADDR,MAKE128CONST(0,0b1));
}

/*****************************************************************************/
/**
*
* This function send acknowledge signal to ImageController
*
* @param	None.
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void data_write_done(){
    Xil_Out128(IMAGE_DATA_DONE_ADDR,MAKE128CONST(0,0b1));
}

/*****************************************************************************/
/**
*
* This function send image size data to ImageController
*
* @param	width : width of image
*           height : height of image
*
* @return	None.
*
* @note		None.
*
******************************************************************************/
void set_image_size(uint64_t width, uint64_t height){
    Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x20,
    		MAKE128CONST( 0, (((uint64_t) width ) << 32) | (uint64_t) height ));
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
		uint64_t value = (  (uint64_t) ( k << 56 ) | (uint64_t) ( k << 48 ) |
							(uint64_t) ( k << 40 ) | (uint64_t) ( k << 32 ) |
							(uint64_t) ( k << 24 ) | (uint64_t) ( k << 16 ) |
							(uint64_t) ( k <<  8 ) | (uint64_t)   k);

		for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
			Xil_DCacheFlush();
			Xil_Out128(IMAGE_DATA_WRITE_ADDR, MAKE128CONST(value,value) );
		}
		k = (k+10)%256;
	}
	else{
		volatile uint8_t * data_addr;
		data_addr = (volatile uint8_t *) data_source_addr;
		uint64_t data_lower;
		uint64_t data_uppper;

		for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
			Xil_DCacheFlush();
			xil_printf("%d\r\n",i);
			data_lower = ( (uint64_t) ( *(data_addr + 7) << 56 ) |
						   (uint64_t) ( *(data_addr + 6) << 48 ) |
						   (uint64_t) ( *(data_addr + 5) << 40 ) |
						   (uint64_t) ( *(data_addr + 4) << 32 ) |
						   (uint64_t) ( *(data_addr + 3) << 24 ) |
						   (uint64_t) ( *(data_addr + 2) << 16 ) |
						   (uint64_t) ( *(data_addr + 1) <<  8 ) |
						   (uint64_t)   *(data_addr) );
			data_addr = data_addr + 8;
			data_uppper = ( (uint64_t) ( *(data_addr + 7) << 56 ) |
							(uint64_t) ( *(data_addr + 6) << 48 ) |
							(uint64_t) ( *(data_addr + 5) << 40 ) |
							(uint64_t) ( *(data_addr + 4) << 32 ) |
							(uint64_t) ( *(data_addr + 3) << 24 ) |
							(uint64_t) ( *(data_addr + 2) << 16 ) |
							(uint64_t) ( *(data_addr + 1) <<  8 ) |
							(uint64_t)   *(data_addr) );
			data_addr = data_addr + 8;
			Xil_Out128(IMAGE_DATA_WRITE_ADDR, MAKE128CONST(data_uppper, data_lower) );
		}
	}
	return;
}
