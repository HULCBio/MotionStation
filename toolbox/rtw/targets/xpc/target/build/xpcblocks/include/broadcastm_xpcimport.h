/* $Revision: 1.4.6.1 $ */

/* Abstract: Broadcast Memory functions imported from kernel
*
*  Copyright 1996-2003 The MathWorks, Inc.
*
*/
 
/* 
 * $Log: broadcastm_xpcimport.h,v $
 * Revision 1.4.6.1  2004/04/08 21:02:30  batserve
 * 2004/04/05  1.4.10.1  gweekly
 *   Updated copyright
 * Accepted job 17399a in A
 *
 * Revision 1.4.10.1  2004/04/05 16:41:37  gweekly
 * Updated copyright
 *
 * Revision 1.4  2003/04/24 18:17:33  pkirwin
 * Change xpceGetBroadcastM parameter declarations to remove compiler warnings
 * when called by xpcbroadcastm.c and xpcinitm.c
 * Related Records: 154471
 * Code Reviewer: pkirwin
 *
 * Revision 1.4  2003/01/22 17:47:06  pkirwin
 * Change xpceGetBroadcastM parameter declarations to remove compiler warnings
 * when called by xpcbroadcastm.c and xpcinitm.c
 * Related Records: 154471
 * Code Reviewer: pkirwin
 *
 * Revision 1.3  2002/03/20 20:44:09  ekbas
 * Copyright fix in all the files
 * Related Records: .
 * Code Reviewer: rroy
 *
 * Revision 1.2  2001/04/27 22:52:56  shaishaa
 * Update CopyRights
 * Code Reviewer: Rajiv,Michael
 *
 * Revision 1.1  2000/03/17 20:14:19  mvetsch
 * Initial revision
 *
 *
*/

typedef struct CSR_tag {
	volatile unsigned char *bt_reg_ctrl;
	volatile unsigned char *bt_reg_irq;
	volatile unsigned char *bt_reg_mem_size;
	volatile unsigned char *bt_reg_reset;
	volatile unsigned long *bt_reg_wrirq;
	volatile unsigned char *bt_reg_trans_rx_err;
	volatile unsigned char *bt_reg_link_status;
	volatile unsigned char *bt_reg_trans_tx_err;
	volatile unsigned char *bt_reg_link_id;
} CSR_type;

static long (XPCCALLCONV * xpceInitBroadcastM)(void); 
static long (XPCCALLCONV * xpceGetBroadcastM)(volatile CSR_type **CSR1, volatile unsigned long **NetRAM1, volatile unsigned long **WIT1);




