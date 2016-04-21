/*************************************************************************
* 
* $Revision: 1.1.4.1 $
* $Date: 2003/11/30 23:06:05 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* C6x specific initialization details
*************************************************************************/
#ifndef __TARGET_H
#define __TARGET_H
#include <c6x.h>                /* IER,ISR,CSR registers                */

/*	RTDX is interrupt driven on the C6x.
	So enable the interrupts now, or it won't work.
*/

#define IER_NMIE	0x00000002
#define CSR_GIE     0x00000001
#define TARGET_INITIALIZE() \
	IER |= 0x00000001 | IER_NMIE; \
	CSR |= CSR_GIE;

#endif /* __TARGET_H    */
