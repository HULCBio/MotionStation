/****************************************************************************
 *   $Revision: 1.1 $  $Date: 2003/07/07 18:05:44 $                                               
 *   Copyright (c) 2000 Texas Instruments Incorporated                                                            
 *
 *   old file: c6x0x.cmd
 ****************************************************************************/
-c
-heap  0x40001
-stack 0x6000
-u __vectors
-u _auto_init

_HWI_Cache_Control = 0;
_RTDX_interrupt_mask = ~0x000000008;     /* int used by RTDX     */

/* Memory Map specific to c6x0x */
MEMORY
{
	IPRAM:	o = 00000000h	l = 000010000h
	SBSRAM:	o = 00400000h	l = 000040000h
	SDRAM0:	o = 02000000h	l = 000400000h
	SDRAM1:	o = 03000000h	l = 000400000h
	IDRAM:	o = 80000000h	l = 000010000h
}


SECTIONS
{
    .intvecs >  IPRAM
    .text    >  IPRAM
    
    .far	 >	IDRAM
    .stack	 >	IDRAM
    .bss	 >	IDRAM
    .cinit	 >	IDRAM
    .pinit	 >	IDRAM
    .cio     >  IDRAM
    .const	 >	IDRAM
    .data    >  IDRAM
    .switch	 >	IDRAM
    .sysmem	 >	IDRAM
}
