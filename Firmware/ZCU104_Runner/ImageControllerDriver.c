#include "runner.h"

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
	xil_printf("Deassert IRQ...\r\n");
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
	xil_printf("Set New Image...\r\n");
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
	xil_printf("Send acknowledge signal...\r\n");
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
	xil_printf("Set image size to %d, %d...\r\n",width, height);
    Xil_Out128(IMAGE_CONTROLLER_ADDR + 0x20,
			MAKE128CONST( 0, (((uint64_t) width, ) << 32) | (uint64_t) height ));
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
			/*Xil_Out128(IMAGE_DATA_WRITE_ADDR,
					MAKE128CONST(
							(uint64_t) ( k << 56 ) | (uint64_t) ( k << 48 ) |
							(uint64_t) ( k << 40 ) | (uint64_t) ( k << 32 ) |
							(uint64_t) ( k << 24 ) | (uint64_t) ( k << 16 ) |
							(uint64_t) ( k <<  8 ) | (uint64_t)   k,
							(uint64_t) ( k << 56 ) | (uint64_t) ( k << 48 ) |
							(uint64_t) ( k << 40 ) | (uint64_t) ( k << 32 ) |
							(uint64_t) ( k << 24 ) | (uint64_t) ( k << 16 ) |
							(uint64_t) ( k <<  8 ) | (uint64_t)   k ) );*/
			Xil_Out128(IMAGE_DATA_WRITE_ADDR,
								MAKE128CONST((uint64_t) k * MASK64BIT, (uint64_t) k * MASK64BIT ));
		}
		k = (k+1)%2;
		xil_printf("k : %d\r\n",k);
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
