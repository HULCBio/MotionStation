/************************************************************************
 *	File taken from <TIDIR>\examples\dsk2812\rtdx\shared\target.h
 ************************************************************************/

/*************************************************************************
* $RCSFile: /db/sds/syseng/rtdx/target/examples/c28xx/target.h,v $
* $Revision: 1.1.6.1 $
* $Date: 2003/11/30 23:06:09 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* C55xx specific inititlaization details
*************************************************************************/
#ifndef __TARGET_H
#define __TARGET_H

/*  RTDX Init functions are called by C28x runtimes during PINIT.
    RTDX_Init_RT_Monitor will enable the DLOG interrupt.
    However, the user must enable the global interrupt flag.
*/
/* Enable global ints & disable WD Timer */
#define TARGET_INITIALIZE() \
	asm(" CLRC VMAP " ); \
    asm(" CLRC INTM " ); \
    asm(" EALLOW" ); \
    asm(" NOP"); \
    asm(" NOP"); \
    asm(" NOP"); \
    asm(" NOP"); \
    DISABLE_WD();	\
    asm(" EDIS");
	
	
/* Disable Watchdog Timer */
#define DISABLE_WD() \
    { \
        unsigned short* wdReg1 = (unsigned short*)0x7029; \
        unsigned short* wdReg2 = (unsigned short*)0x7025; \
        *wdReg1 |= 0x0068;               \
        *wdReg2  = 0x0055;               \
        *wdReg2  = 0x00AA;               \
    }

#endif /*__TARGET_H */

