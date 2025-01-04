/*
 * Copyright (C) 2009 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */
#include "zcu104clinktest.h"
#include "xparameters.h"
#include "sleep.h"

static int wait_transfer_callback = 0;

int transfer_data() {
	return 0;
}

void print_app_header()
{
	xil_printf("\n\r\n\r-----lwIP TCP server ------\n\r");
}

#define STAGE1   			(0)
#define STAGE2				(1)

void send_uart(uint64_t data){
	volatile __uint128_t uart_busy = 0;
	volatile uint64_t busy = 1;

	while(busy != 0){
		uart_busy = Xil_In128(
			XPAR_CLINK_INTF_BASEADDR | AXI_READ_UART_BUSY
		);
		busy = LOWER(uart_busy) & 0x1;
	}

	Xil_Out128(
		XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
		MAKE128CONST(0,data & 0xff)
	);
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	char image_data[2048];
	char * cmd_str;
	uint64_t exposure_state = 0;
	static char action_str[1024];
	static uint8_t uart_data[1024 * 8] = {0};
	static int tcp_stage = STAGE1;
	static uint64_t uart_addr = 0;
	static uint64_t uart_addr_len = 0;
	static uint64_t uart_data_len = 0;

	uint64_t cc_channel = 0;
	uint64_t cc_value = 0;
	uint64_t axi_write_lower = 0;

	uint64_t dram_addr = 0;
	uint64_t dram_size = 0;
	__uint128_t dram_data = 0;
	uint64_t dram_data_upper = 0;
	uint64_t dram_data_lower = 0;

	__uint128_t uart_read_data = 0;
	__uint128_t uart_valid = 0;

	/*
	 * do not read the packet if we are not in ESTABLISHED state
	 */
	if (!p) {
		tcp_close(tpcb);
		tcp_recv(tpcb, NULL);
		return ERR_OK;
	}

	/*
	 * indicate that the packet has been received
	 */
	tcp_recved(tpcb, p->len);

	/*
	 * Command processing
	 */
	substring_by_chr(action_str, p->payload,1,2);
	xil_printf("ACTION : %s \r\n",action_str);
	

	switch (tcp_stage){
		case STAGE1:
			if (strcmp(action_str,"CC_CTRL") == 0) {
				xil_printf("ACQUISITION ");
				exposure_state = get_param(p->payload, 2, 3);
				cc_channel = exposure_state & 0xff;
				cc_value   = (exposure_state >> 8) & 0xff;
				switch(cc_channel){
					case 1:
						axi_write_lower = 0b0001;
						break;
					case 2:
						axi_write_lower = 0b0010;
						break;
					case 3:
						axi_write_lower = 0b0100;
						break;
					case 4:
						axi_write_lower = 0b1000;
						break;
					default:
						xil_printf("Unknown CC channel %d \r\n", cc_channel);
						break;
				}
				if( cc_value == 0b1 ){
					axi_write_lower = axi_write_lower & 0b1111;
				}
				else if(cc_value == 0b0 ){
					axi_write_lower = 0;
				}
				else{
					xil_printf("Unknown cc_val %d \r\n",cc_value);
				}
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_CC,
					MAKE128CONST(0,axi_write_lower&0xffff)
				);
				sleep(0.000030);
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_CC,
					MAKE128CONST(0,0)
				);
				xil_printf("CC_CTRL : %d %d \r\n",cc_channel,cc_value);
			}
			else if (strcmp(action_str,"UART_SEND") == 0) {
				/*
				* #UART#{uart_addr}#{addr_len}#{data_len}#!EOL#
				* after this send bytes of data
				*/
				uart_addr 		= get_param(p->payload, 2, 3);
				uart_addr_len 	= get_param(p->payload, 3, 4);
				uart_data_len 	= get_param(p->payload, 4, 5);
				/* BFS */
				send_uart(0b00000001 & 0xff);
				/* FTF & DATALEN & ADDR */
				switch (uart_addr_len){
					case 0b00:
						/* 2 bytes */
						send_uart(0b00000000 & 0xff);
						send_uart(uart_data_len & 0xff);
						send_uart(uart_addr&0xff);
						send_uart((uart_addr>>8)&0xff);
						break;
					case 0b01:
						/* 4 bytes */
						send_uart(0b00000001 & 0xff);
						send_uart(uart_data_len & 0xff);;
						send_uart(uart_addr&0xff);
						send_uart((uart_addr>>8)&0xff);
						send_uart((uart_addr>>16)&0xff);
						send_uart((uart_addr>>24) & 0xff);
						xil_printf("ADDR LEN : 4bytes \r\n");
						break;
					case 0b10:
						/* 6 bytes */
						send_uart(0b00000010 & 0xff);
						send_uart(uart_data_len & 0xff);
						send_uart(uart_addr&0xff);
						send_uart((uart_addr>>8)&0xff);
						send_uart((uart_addr>>16)&0xff);
						send_uart((uart_addr>>24)&0xff);
						send_uart((uart_addr>>32)&0xff);
						send_uart((uart_addr>>40)&0xff);
						break;
					case 0b11:
						/* 8 bytes */
						send_uart(0b00000011 & 0xff);
						send_uart(uart_data_len & 0xff);
						send_uart(uart_addr&0xff);
						send_uart((uart_addr>>8)&0xff);
						send_uart((uart_addr>>16)&0xff);
						send_uart((uart_addr>>24)&0xff);
						send_uart((uart_addr>>32)&0xff);
						send_uart((uart_addr>>40)&0xff);
						send_uart((uart_addr>>48)&0xff);
						send_uart((uart_addr>>56)&0xff);
						break;
					default:
						xil_printf("UNKNOWN ADDR LEN : %d\r\n",uart_addr_len);
						break;
				}
				tcp_stage = STAGE2;
			}
			else if (strcmp(action_str,"READ_DRAM") == 0) {
				dram_addr = get_param(p->payload, 2, 3);
				dram_size = get_param(p->payload, 3, 4);
				xil_printf("<%d th data>\r\n",dram_size);
				for( int i = 0 ; i < 128 ; i ++ ){
					dram_data = Xil_In128(XPAR_MIG_0_BASEADDR | dram_addr + i * 16 + dram_size * 2048);
					image_data[i * 16 + 0 ]  = (LOWER(dram_data) >> 0) & 0xff;
					image_data[i * 16 + 1 ]  = (LOWER(dram_data) >> 8) & 0xff;
					image_data[i * 16 + 2 ]  = (LOWER(dram_data) >> 16) & 0xff;
					image_data[i * 16 + 3 ]  = (LOWER(dram_data) >> 24) & 0xff;
					image_data[i * 16 + 4 ]  = (LOWER(dram_data) >> 32) & 0xff;
					image_data[i * 16 + 5 ]  = (LOWER(dram_data) >> 40) & 0xff;
					image_data[i * 16 + 6 ]  = (LOWER(dram_data) >> 48) & 0xff;
					image_data[i * 16 + 7 ]  = (LOWER(dram_data) >> 56) & 0xff;
					image_data[i * 16 + 8 ]  = (UPPER(dram_data) >> 0) & 0xff;
					image_data[i * 16 + 9 ]  = (UPPER(dram_data) >> 8) & 0xff;
					image_data[i * 16 + 10] = (UPPER(dram_data) >> 16) & 0xff;
					image_data[i * 16 + 11] = (UPPER(dram_data) >> 24) & 0xff;
					image_data[i * 16 + 12] = (UPPER(dram_data) >> 32) & 0xff;
					image_data[i * 16 + 13] = (UPPER(dram_data) >> 40) & 0xff;
					image_data[i * 16 + 14] = (UPPER(dram_data) >> 48) & 0xff;
					image_data[i * 16 + 15] = (UPPER(dram_data) >> 56) & 0xff;

				}
			}
			else if (strcmp(action_str,"WRITE_DRAM") == 0) {
				dram_addr = get_param(p->payload, 2, 3);
				dram_data_upper = get_param(p->payload, 3, 4);
				dram_data_lower = get_param(p->payload, 4, 5);
				Xil_Out128(
					XPAR_MIG_0_BASEADDR | dram_addr,
					MAKE128CONST(dram_data_upper,dram_data_lower)
				);
			}
			else if (strcmp(action_str,"RESET_CLINK") == 0) {
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_CLINK_RESETN,
					MAKE128CONST(0,(uint64_t)1)
				);
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_CLINK_RESETN,
					MAKE128CONST(0,(uint64_t)0)
				);
				xil_printf("CLINK is reseted\r\n");
			}
			else if (strcmp(action_str,"RESET_DRAM") == 0) {
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_DRAM_RESETN,
					MAKE128CONST(0,(uint64_t)1)
				);
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_DRAM_RESETN,
					MAKE128CONST(0,(uint64_t)0)
				);
				xil_printf("DRAM is reseted\r\n");
			}
			else if (strcmp(action_str, "READ_UART_VAL") == 0) {
				uart_valid = Xil_In128(
					XPAR_CLINK_INTF_BASEADDR | AXI_READ_UART_VALID
				);
				xil_printf("UART VALID : %d\r\n", LOWER(uart_valid));
			}
			else if (strcmp(action_str, "READ_UART_DATA") == 0) {
				uart_read_data = Xil_In128(
					XPAR_CLINK_INTF_BASEADDR | AXI_READ_UART
				);
				xil_printf("UART DATA : %d\r\n", LOWER(uart_read_data));
			}
			else if (strcmp(action_str, "AUTO_START") == 0) {
				Xil_Out128(
					XPAR_MASTERCONTROLLER_0_BASEADDR | 0b0000,
					MAKE128CONST(0,0b1000)
				);
				xil_printf("AUTO START \r\n");
			}
			else if (strcmp(action_str, "READ_IMG_NUM") == 0) {
				uart_read_data = Xil_In128(
					XPAR_CLINK_INTF_BASEADDR | 0x10
				);
				xil_printf("IMAGE NUM : %d\r\n", LOWER(uart_read_data));
			}
			else{
				xil_printf("UNKNOWN COMMAND : %s\r\n",p->payload);
			}
			break;
		case STAGE2:
			/* write actual data */
			memcpy((void *)uart_data, p->payload, uart_data_len);
			for (int i = 0 ; i < uart_data_len ; i++){
				send_uart(uart_data[i] & 0xff);
				xil_printf("SENT DATA : %d\r\n",uart_data[i]);
			}
			/* END of UART */
			send_uart((uint64_t)0x03 & 0xff);
			tcp_stage = STAGE1;
			while(1) {
				uart_valid = Xil_In128(
					XPAR_CLINK_INTF_BASEADDR | AXI_READ_UART_VALID
				);
				if (uart_valid == 1) break;
			}
			uart_read_data = Xil_In128(
				XPAR_CLINK_INTF_BASEADDR | AXI_READ_UART
			);
			xil_printf("Received ACK : %x\r\n", LOWER(uart_read_data));
			break;
	}

	/*
	 * echo back the payload
	 * in this case, we assume that the payload is < TCP_SND_BUF
	 */
	if (tcp_sndbuf(tpcb) > p->len) {
		if (strcmp(action_str,"READ_DRAM") == 0) err = tcp_write(tpcb, image_data, 2048, 1);
		else err = tcp_write(tpcb, p->payload, p->len, 1);
	}
	else {
		xil_printf("no space in tcp_sndbuf\n\r");
	}

	/*
	 * free the received pbuf
	 */
	pbuf_free(p);


	return ERR_OK;
}

err_t accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err)
{
	static int connection = 1;

	/*
	 * set the receive callback for this connection
	 */
	tcp_recv(newpcb, recv_callback);

	/*
	 * just use an integer number indicating the connection id as the
	 * callback argument
	 */
	tcp_arg(newpcb, (void*)(UINTPTR)connection);

	/*
	 * increment for subsequent accepted connections
	 */
	connection++;

	return ERR_OK;
}


struct tcp_pcb * start_application()
{
	struct tcp_pcb *pcb;
	struct tcp_pcb *tpcb;
	err_t err;
	unsigned port = 7;

	/* create new TCP PCB structure */
	tpcb = tcp_new_ip_type(IPADDR_TYPE_ANY);
	if (!tpcb) {
		xil_printf("Error creating PCB. Out of Memory\n\r");
		return -1;
	}

	/* bind to specified @port */
	err = tcp_bind(tpcb, IP_ANY_TYPE, port);
	if (err != ERR_OK) {
		xil_printf("Unable to bind to port %d: err = %d\n\r", port, err);
		return -2;
	}

	/* we do not need any arguments to callback functions */
	tcp_arg(tpcb, NULL);

	/* listen for connections */
	pcb = tcp_listen(tpcb);
	if (!pcb) {
		xil_printf("Out of memory while tcp_listen\n\r");
		return -3;
	}

	/* specify callback to use for incoming connections */
	tcp_accept(pcb, accept_callback);

	xil_printf("TCP server started @ port %d\n\r", port);

	return tpcb;
}

void trans_callback(){
	wait_transfer_callback = 0;
}
