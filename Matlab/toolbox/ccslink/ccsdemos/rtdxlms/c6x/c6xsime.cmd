/****************************************************************************
* 
* $Revision: 1.1.4.1 $
* $Date: 2003/11/30 23:05:16 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* Description: 
*	Sample Linker Control File for C6201 DSK target boards.
*	Note: Also works for C6701 DSK target boards.
*
* Usage:  
*	lnk6x <obj files...>    -o <out file> -m <map file> lcf.cmd
*	cl6x  <src files...> -z -o <out file> -m <map file> lcf.cmd
****************************************************************************/
-c
-heap  0x2000
-stack 0x4000
-u __vectors
-u _auto_init

_HWI_Cache_Control = 0;
_RTDX_interrupt_mask = ~0x000000008;    /* int used by RTDX     */

MEMORY
{
	VECS:	o = 00000000h	l = 00000200h
	PMEM:	o = 00000200h	l = 0000fe00h
	EXT0:	o = 00400000h	l = 00040000h
	EXT1:	o = 01400000h	l = 00040000h
	EXT2:	o = 02000000h	l = 00040000h
	BMEM:	o = 80000000h	l = 00010000h
}

SECTIONS
{
	.intvecs	>   VECS
    .text       >   PMEM
    .rtdx_text  >   PMEM
    .far		>	BMEM
    .stack		>	BMEM
    .bss		>	BMEM
    .cinit		>	BMEM
    .pinit		>	BMEM
    .cio        >   BMEM
    .const		>	BMEM
    .data       >   BMEM
    .rtdx_data  >   BMEM
    .switch		>	BMEM
    .sysmem		>	BMEM
}
