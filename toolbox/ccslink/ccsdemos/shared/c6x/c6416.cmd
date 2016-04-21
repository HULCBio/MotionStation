/* Taken from <TIDIR>\examples\dsk6416\rtdx\shared\c6416.cmd */
/*************************************************************************
* $RCSfile: c6416.cmd,v $
* $Revision: 1.1.6.1 $
* $Date: 2003/11/30 23:06:11 $
* Copyright (c) 1997 Texas Instruments Incorporated
*
* Description: 
*		Sample Linker Control File for C6211 DSK target boards.
*
* Usage:  
*		lnk6x <obj files...>	-o <out file> -m <map file> lcf.cmd
*		cl6x  <src files...> -z -o <out file> -m <map file> lcf.cmd
*************************************************************************/
-c
-heap  0x1000
-stack 0x1000
-u __vectors
-u _auto_init

_HWI_Cache_Control = 0;

/* RTDX Interrupt Mask
   - This symbol defines those interrupts which are clients of RTDX
	 (ie - interrupts which call RTDX functions.
   - RTDX will apply this mask to the IER before excuting code in 
	 RTDX critical sections temporarily disabling those interrupts for
	 a few cycles.
   - Any interrupt handlers which call RTDX_read/write functions should 
	 be added to the mask to prevent corruption of the RTDX global state
	 variables by simulataneous access from multiple RTDX clients.
*/	   
_RTDX_interrupt_mask = ~0x000000208;

MEMORY
{
	VECS:	o=00000000h 	l=00000200h 	/* interrupt vectors		*/
	PMEM:	o=00000200h 	l=0000FE00h 	/* Internal RAM (L2) mem	*/
	BMEM:	o=80000000h 	l=01000000h 	/* CE0, SDRAM, 16 MBytes	*/
}

SECTIONS
{
	.intvecs	>		VECS
	.text		>		BMEM
	.cio		>		BMEM
	.bss		>		BMEM
	.sysmem 	>		BMEM
	.stack		>		BMEM
	.cinit		>		BMEM
	.data		>		BMEM
	.far		>		BMEM
	.switch 	>		BMEM


	.pinit		>		PMEM
	.const		>		BMEM
	.rtdx_text	>		BMEM 
	.rtdx_data	align 0x100 >		BMEM
}

