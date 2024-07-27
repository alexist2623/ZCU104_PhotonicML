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
#include "zcu104irq.h"

static int wait_transfer_callback = 0;

int transfer_data() {
	return 0;
}

void print_app_header()
{
	xil_printf("\n\r\n\r-----lwIP TCP server ------\n\r");
}

err_t recv_callback(void *arg, struct tcp_pcb *tpcb,
                               struct pbuf *p, err_t err)
{
	char * cmd_str;

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
	substring(
		cmd_str,
		p->payload,
		string_count(p->payload,1,'#')+1,
		string_count(p->payload,2,'#')
	);

	if(strcmp(cmd_str,"START_DISPLAY") == 0 ){
		xil_printf("#START DISPLAY\r\n");
		IPI_run_display();
	}
	else if(strcmp(cmd_str,"STOP_DISPLAY") == 0 ){
		xil_printf("STOP DISPLAY\r\n");
		IPI_stop_display();
	}
	else if(strcmp(cmd_str,"LOAD_SD_CARD") == 0 ){
		xil_printf("LOAD SD CARD\r\n");
		IPI_load_sdcard();
	}
	else if(strcmp(cmd_str,"SET_NEW_IMAGE") == 0 ){
		xil_printf("SET NEW IMAGE\r\n");
		IPI_set_new_image();
	}
	else if(strcmp(cmd_str,"SET_TEST") == 0 ){
		xil_printf("SET TEST\r\n");
		IPI_set_test(
			get_param(p->payload, 2, 3),
			get_param(p->payload, 3, 4),
			get_param(p->payload, 4, 5),
			get_param(p->payload, 5, 6),
			get_param(p->payload, 6, 7),
			get_param(p->payload, 7, 8));
	}
	else if(strcmp(cmd_str,"SET_CAM_EXP_START") == 0 ){
		xil_printf("SET_CAM_EXP_START\r\n");
		IPI_set_cam_exp_start(
			get_param(p->payload, 2, 3),
			get_param(p->payload, 3, 4),
			get_param(p->payload, 4, 5));
	}
	else if(strcmp(cmd_str,"SET_CAM_EXP_END") == 0 ){
		xil_printf("SET_CAM_EXP_END\r\n");
		IPI_set_cam_exp_end(
			get_param(p->payload, 2, 3),
			get_param(p->payload, 3, 4),
			get_param(p->payload, 4, 5));
		}
	else{
		xil_printf("UNKNOWN COMMAND : %s\r\n",p->payload);
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
