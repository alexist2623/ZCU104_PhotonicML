#ifndef _ZCU104PCBTEST_
#define _ZCU104PCBTEST_

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
#include "xscugic_hw.h"
#include "xstatus.h"
#include "xscugic.h"
#include "xil_util.h"

#ifndef __BAREMETAL__
#define __BAREMETAL__
#endif
/////////////////////////////////////////////////////////////
// 128 bit write
//
// https://isocpp.org/wiki/faq/inline-functions
// -> why inline function is in header file?
/////////////////////////////////////////////////////////////
static INLINE void Xil_Out128(UINTPTR Addr, __uint128_t Value)
{
	volatile __uint128_t *LocalAddr = (volatile __uint128_t *)Addr;
	*LocalAddr = Value;
}

#define MAKE128CONST(hi,lo) ((((__uint128_t)hi << 64) | (lo)))

struct tcp_pcb * start_application();
err_t 	accept_callback(void *arg, struct tcp_pcb *newpcb, err_t err);
err_t 	recv_callback(void *arg, struct tcp_pcb *tpcb, struct pbuf *p, err_t err);
void 	print_app_header();
int 	transfer_data();
void 	trans_callback();

/***************** defined by each RAW mode application **********************/
void print_app_header();
int transfer_data();
void tcp_fasttmr(void);
void tcp_slowtmr(void);

/****************** missing declaration in lwIP *******************************/
void lwip_init();


/***************************** lexer functions ********************************/
int64_t get_param(char *inst, int64_t start_index, int64_t end_index);

/************************ string process functions ****************************/
int64_t string2int64(char* str);
int64_t string_count(char* str, int64_t pos, char spc);
char * substring(char * str_dest,char * str,int64_t start,int64_t end);
char * int642str(int64_t val, char * str_dest);
int64_t wolc_strcmp(char * str1, char * str2);

#endif
