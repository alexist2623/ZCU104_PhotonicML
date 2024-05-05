#ifndef _ZCU104IRQ_
#define _ZCU104IRQ_

#include <string.h>
#include <malloc.h>
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_cache.h"
#include "lwip/err.h"
#include "lwip/tcp.h"
#include "xil_exception.h"
#include "netif/xadapter.h"
#include "platform.h"
#include "platform_config.h"

#ifndef __BAREMETAL__
#define __BAREMETAL__
#endif

//AXI address
#define AXI_LEN 0x10;
#define M_AXI_HPM0_FPD_ADDR 	XPAR_AXI_HPM0_FPD_0_S_AXI_BASEADDR
#define M_AXI_HPM1_FPD_ADDR 	XPAR_AXI_HPM1_FPD_0_S_AXI_BASEADDR
#define CPU_BASEADDR			XPAR_SCUGIC_0_CPU_BASEADDR
#define DIST_BASEADDR			XPAR_SCUGIC_0_DIST_BASEADDR
#define GIC_DEVICE_INT_MASK     0x00020000

#define MAKE128CONST(hi,lo) ((((__uint128_t)hi << 64) | (lo)))

struct tcp_pcb * start_application();
err_t 	accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err);
err_t 	recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);
void 	print_app_header();
int 	transfer_data();
void 	trans_callback();
/*
 * Main
 */

/* defined by each RAW mode application */
void print_app_header();
int transfer_data();
void tcp_fasttmr(void);
void tcp_slowtmr(void);

/* missing declaration in lwIP */
void lwip_init();

#endif
