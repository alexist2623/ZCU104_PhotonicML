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
		uint64_t data_00;
		uint64_t data_01;
		uint64_t data_02;
		uint64_t data_03;
		uint64_t data_04;
		uint64_t data_05;
		uint64_t data_06;
		uint64_t data_07;
		uint64_t data_08;
		uint64_t data_09;
		uint64_t data_10;
		uint64_t data_11;
		uint64_t data_12;
		uint64_t data_13;
		uint64_t data_14;
		uint64_t data_15;

		for( int i = 0 ; i < IMAGE_WRITE_TIME; i ++ ){
			Xil_DCacheFlush();
			data_00 = (uint64_t) ( *(data_addr +  0) & 0xff);
			data_01 = (uint64_t) ( *(data_addr +  1) & 0xff);
			data_02 = (uint64_t) ( *(data_addr +  2) & 0xff);
			data_03 = (uint64_t) ( *(data_addr +  3) & 0xff);
			data_04 = (uint64_t) ( *(data_addr +  4) & 0xff);
			data_05 = (uint64_t) ( *(data_addr +  5) & 0xff);
			data_06 = (uint64_t) ( *(data_addr +  6) & 0xff);
			data_07 = (uint64_t) ( *(data_addr +  7) & 0xff);
			data_08 = (uint64_t) ( *(data_addr +  8) & 0xff);
			data_09 = (uint64_t) ( *(data_addr +  9) & 0xff);
			data_10 = (uint64_t) ( *(data_addr + 10) & 0xff);
			data_11 = (uint64_t) ( *(data_addr + 11) & 0xff);
			data_12 = (uint64_t) ( *(data_addr + 12) & 0xff);
			data_13 = (uint64_t) ( *(data_addr + 13) & 0xff);
			data_14 = (uint64_t) ( *(data_addr + 14) & 0xff);
			data_15 = (uint64_t) ( *(data_addr + 15) & 0xff);

			data_lower = ( (uint64_t) ( data_07 << 56 ) |
						   (uint64_t) ( data_06 << 48 ) |
						   (uint64_t) ( data_05 << 40 ) |
						   (uint64_t) ( data_04 << 32 ) |
						   (uint64_t) ( data_03 << 24 ) |
						   (uint64_t) ( data_02 << 16 ) |
						   (uint64_t) ( data_01 <<  8 ) |
						   (uint64_t) ( data_00 ) );
			data_uppper = ((uint64_t) ( data_15 << 56 ) |
						   (uint64_t) ( data_14 << 48 ) |
						   (uint64_t) ( data_13 << 40 ) |
						   (uint64_t) ( data_12 << 32 ) |
						   (uint64_t) ( data_11 << 24 ) |
						   (uint64_t) ( data_10 << 16 ) |
						   (uint64_t) ( data_09 <<  8 ) |
						   (uint64_t) ( data_08 ) );
			data_addr = data_addr + 16;
			Xil_Out128(IMAGE_DATA_WRITE_ADDR, MAKE128CONST(data_uppper, data_lower) );
		}
	}
	return;
}
