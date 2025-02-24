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

extern volatile int TcpFastTmrFlag;
extern volatile int TcpSlowTmrFlag;
static struct netif server_netif;
struct netif *echo_netif;


void
print_ip(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip),
			ip4_addr3(ip), ip4_addr4(ip));
}

void
print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}

void initialization(){
	ip_addr_t ipaddr, netmask, gw;
	/* the mac address of the board. this should be unique per board { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 }*/
	unsigned char mac_ethernet_address[] =
	{ 0x00, 0x0a, 0x35, 0x07, 0x8B, 0x5E };

	echo_netif = &server_netif;

	init_platform();

	/* initialize IP addresses to be used */
	IP4_ADDR(&ipaddr,  172,  22,  22,236);
	IP4_ADDR(&netmask, 255, 255, 255,  0);
	IP4_ADDR(&gw,      172,  22,  22,  1);
	xil_printf("set manual IP\n\r");

	print_app_header();

	lwip_init();
	xil_printf("lwip initialize \n\r");


	/* Add network interface to the netif_list, and set it as default */
	if (!xemac_add(echo_netif, &ipaddr, &netmask,
						&gw, mac_ethernet_address,
						PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\n\r");
		return -1;
	}
	netif_set_default(echo_netif);

	/* now enable interrupts */
	platform_enable_interrupts();

	/* specify that the network if is up */
	netif_set_up(echo_netif);
	print_ip_settings(&ipaddr, &netmask, &gw);
}

int main()
{
	initialization();

	/* start the application (web server, rxtest, txtest, etc..) */
	struct tcp_pcb *pcb = start_application();

	/* receive and process packets */
	xil_printf("############################################################\r\n");
	xil_printf("###            IWSL ZCU104 Firmware V1_00                ###\r\n");
	xil_printf("############################################################\r\n");

	/* Test code */
	// xil_printf("Write Test\r\n");
	// xil_printf("ADDR 0x00 \r\n");
	// Xil_Out128(AXI_OFFSET|AXI_WRITE_UART, MAKE128CONST(0x00000000, 0x00000000));
	// xil_printf("ADDR 0x10 \r\n");
	// Xil_Out128(AXI_OFFSET|AXI_WRITE_CC, MAKE128CONST(0x00000000, 0x00000000));
	// xil_printf("Write Test passed\r\n");
	// xil_printf("Check Clink is ready\r\n");
	// uint64_t count_clink = 0;
	// __uint128_t clink_ready = 0;
	// clink_ready = Xil_In128(AXI_OFFSET|AXI_READ_UART);
	// xil_printf("Clink ready: %d\r\n", LOWER(clink_ready));
	// while(1){
	// 	clink_ready = Xil_In128(AXI_OFFSET|AXI_READ_CLINK_READY);
	// 	if(LOWER(clink_ready) == 0x0000000000000001){
	// 		xil_printf("Clink is ready\r\n");
	// 		break;
	// 	}
	// 	count_clink++;
	// 	if (count_clink == 100000000){
	// 		xil_printf("Clink is not ready\r\n");
	// 		count_clink = 0;
	// 	}
	// }
	while (1) {
		if (TcpFastTmrFlag) {
			tcp_fasttmr();
			TcpFastTmrFlag = 0;
		}
		if (TcpSlowTmrFlag) {
			tcp_slowtmr();
			TcpSlowTmrFlag = 0;
		}
		xemacif_input(echo_netif);
	}

	/* never reached */
	cleanup_platform();

	return 0;
}
