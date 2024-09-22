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

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	char * cmd_str;
	uint64_t exposure_state = 0;
	static char action_str[1024];
	static uint8_t uart_data[1024 * 8] = {0};
	static int tcp_stage = STAGE1;
	static uint64_t uart_addr = 0;
	static uint64_t uart_addr_len = 0;
	static uint64_t uart_data_len = 0;

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
			if (strcmp(action_str,"EXPOSURE") == 0) {
				xil_printf("EXPOSURE ");
				exposure_state = get_param(p->payload, 2, 3);
				if (exposure_state == 0) {
					xil_printf("ON \r\n");
				}
				else{
					xil_printf("OFF \r\n");
				}
				/*
				* Make AXI command to Clink Interface module
				*/
				Xil_Out128(XPAR_CLINK_INTF_BASEADDR, exposure_state);
			}
			if (strcmp(action_str,"UART_SEND") == 0) {
				/*
				* #UART#{uart_addr}#{addr_len}#{data_len}#!EOL#
				* after this send bytes of data
				*/
				xil_printf("UART SEND \r\n");
				uart_addr 		= get_param(p->payload, 2, 3);
				uart_addr_len 	= get_param(p->payload, 3, 4);
				uart_data_len 	= get_param(p->payload, 4, 5);
				xil_printf("UART ADDR : %x \r\n", uart_addr);
				xil_printf("UART ADDR LEN : %d \r\n", uart_addr_len);
				xil_printf("UART DATA LEN : %d \r\n", uart_data_len);
				/*
				* Make AXI command to Clink Interface module
				*/
				xil_printf("Write AXI Command\r\n");
				switch (uart_addr_len){
					case 0b00:
						/* 2 bytes */
						xil_printf("AXI ADDR is 2Bytes \r\n");
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,uart_addr&0xff)
						);
						xil_printf("Write 1 st Byte\r\n");
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>8)&0xff)
						);
						xil_printf("Write 2 nd Byte\r\n");
						break;
					case 0b01:
						/* 4 bytes */
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,uart_addr&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>8)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>16)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>24)&0xff)
						);
						break;
					case 0b10:
						/* 6 bytes */
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,uart_addr&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>8)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>16)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>24)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>32)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>40)&0xff)
						);
						break;
					case 0b11:
						/* 8 bytes */
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,uart_addr&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>8)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>16)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>24)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>32)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>40)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>48)&0xff)
						);
						sleep(1/9600.0*10);
						Xil_Out128(
							XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
							MAKE128CONST(0,(uart_addr>>56)&0xff)
						);
						break;
					default:
						xil_printf("UNKNOWN ADDR LEN : %d\r\n",uart_addr_len);
						break;
				}
				xil_printf("ADDR : %d \r\n", uart_addr);
				tcp_stage = STAGE2;
			}
			else{
				xil_printf("UNKNOWN COMMAND : %s\r\n",p->payload);
			}
		case STAGE2:
			memcpy((void *)uart_data, p->payload, uart_data_len);
			for (int i = 0 ; i < uart_data_len ; i++){
				Xil_Out128(
					XPAR_CLINK_INTF_BASEADDR | AXI_WRITE_UART,
					MAKE128CONST(0,uart_data[i] & 0xff)
				);
				sleep(1/9600.0*10);
			}
			tcp_stage = STAGE1;
			break;
	}

	/*
	 * echo back the payload
	 * in this case, we assume that the payload is < TCP_SND_BUF
	 */
	if (tcp_sndbuf(tpcb) > p->len) {
		err = tcp_write(tpcb, p->payload, p->len, 1);
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
