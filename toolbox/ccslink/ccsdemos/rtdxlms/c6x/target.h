#ifndef __TARGET_H
#define __TARGET_H

/***********************************************************************
* 
* VERSION : $Revision: 1.2.2.1 $
* DATE    : $Date: 2003/11/30 23:05:27 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* - Target specific initialization details
*
************************************************************************/

extern cregister volatile unsigned int IER;
extern cregister volatile unsigned int ISR;
extern cregister volatile unsigned int CSR;

#define NMIE_BIT	0x00000002
#define TARGET_INITIALIZE() \
	IER |= 0x00000001 | NMIE_BIT; \
	CSR |= 0x00000001;

#endif // __TARGET_H
