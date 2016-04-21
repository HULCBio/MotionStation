/*************************************************************************
* 
* $Revision: 1.1.6.1 $
* $Date: 2004/01/22 18:18:10 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* Description:
*       This file is a sample command file that can be used
*       for linking programs built with the LEAD 3 C Compiler.
*       Use it as a guideline; you  may want to change the
*       allocation scheme according to the size of your program
*       and the memory layout of your target system.
*
* Usage:
*       lnk55x <obj files...>    -o <out file> -m <map file> lnk.cmd
*       cl55x  <src files...> -z -o <out file> -m <map file> lnk.cmd
*************************************************************************/
-c
-stack 0x1000                	/* PRIMARY STACK SIZE        			*/
-sysstack 0x1000                /* SECONDARY STACK SIZE      			*/
/*-heap  0x1000                 /* HEAP AREA SIZE            			*/
-lrts55.lib
-lrtdxsim.lib					/*RTDX Simulation Library 				*/

/* This symbol defines the interrupt mask to be applied to IER inside
   RTDX Critical Code sections.
   The LSB 16bits => IER0, MSB 16bits => IER1

   This example masks IE4 (timer) and DLOGINT (for RTDX) on a C5510.
*/
_RTDX_interrupt_mask = ~0x02000010; /* interrupts masked by RTDX        */


/* Set entry point to Reset vector 										*/
/* - Allows Reset ISR to force IVPD/IVPH to point to vector table.		*/
-e RESET_ISR

/* SPECIFY THE SYSTEM MEMORY MAP                                    	*/
/* - Loader/Linker only uses Byte-addresses.							*/
MEMORY
{
	DARAM (RWIX)    : o=00000C0h, l=000FF40h
	SARAM (RWIX)	: o=0010000h, l=0040000h
	CE0 (RWIX)		: o=0050000h, l=03B0000h
	CE1 (RWIX)		: o=0400000h, l=0400000h
	CE2 (RWIX)		: o=0800000h, l=0400000h
	CE3 (RWIX)		: o=0C00000h, l=03F8000h
	DROM(RX)		: o=0FF8000h, l=0008000h
}

/* SPECIFY THE SECTIONS ALLOCATION INTO MEMORY                      	*/
SECTIONS
{
	/* The power-up vector location is NOT writable.					*/
	/* - So vectors must be loaded at a different address.				*/
/*  	.intvecs	> 0ffff00h
*/
    .intvecs	> SARAM

	.text       > SARAM			/* CODE             					*/
    .rtdx_text  > SARAM			/* RTDX CODE        					*/
    .switch     > SARAM			/* SWITCH TABLE INFO 					*/
    .const      > SARAM			/* CONSTANT DATA    					*/
    .cinit      > SARAM			/* INITIALIZATION TABLES 				*/
    .pinit      > SARAM			/* INITIALIZATION TABLES 				*/

    .data       > DARAM fill=0xBEEF	/* INITIALIZED DATA 				*/
    .rtdx_data  > DARAM	fill=0xBEEF /* RTDX DATA 						*/
    .bss        > DARAM	fill=0xBEEF /* GLOBAL & STATIC VARS  			*/
    .sysmem     > DARAM	fill=0xBEEF /* DYNAMIC MALLOC AREA 				*/
    .stack      > DARAM fill=0xBEEF	/* PRIMARY SYSTEM STACK  			*/
    .sysstack   > DARAM fill=0xBEEF	/* SECONDARY SYSTEM STACK 			*/
    .cio        > DARAM fill=0xBEEF
}
