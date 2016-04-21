/*************************************************************************
*   $Revision: 1.1 $  $Date: 2003/07/07 18:05:50 $      
*    Copyright (c) 2000 Texas Instruments Incorporated
* 
*
* Description: 
*	Sample Linker Control File for C6x1x target boards.
*
* Usage:  
*	lnk6x <obj files...>    -o <out file> -m <map file> lcf.cmd
*	cl6x  <src files...> -z -o <out file> -m <map file> lcf.cmd
*************************************************************************/
-c
-heap  0x1000
-stack 0x1000
-lrts6201.lib
-lrtdx.lib
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
_RTDX_interrupt_mask = ~0x000000008;

MEMORY
{
	PMEM:	o=00000000h	l=00010000h 	/* Internal RAM (L2) mem	*/
	BMEM:	o=80000000h	l=01000000h 	/* CE0, SDRAM, 16 MBytes	*/

}

SECTIONS
{
    .intvecs	>	0h
    .text		>	PMEM
    
    .far		>	PMEM
    .stack		>	PMEM
    .bss		>	PMEM
    .cinit		>	PMEM
    .pinit		>	PMEM
    .cio		>	PMEM
    .const		>	PMEM
    .data		>	PMEM
    .switch		>	PMEM
    .sysmem		>	PMEM
}
