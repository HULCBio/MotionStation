/****************************************************************************
 * CCSFIR_54xx.CMD - Example Target Linker Command File 
 *
 *   This file is provided as an example linker command file
 *   for the target code that implements the Matlab demo: CCSFIRDEMO
 *   This file was tested with the 5402 processor.
 *
 *   It may be necessary to modify this file to conform to 
 *   details of each DSP implemetation.              
 ****************************************************************************/
/*
 * Copyright 2002 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/11/30 23:04:08 $
 */
-c
-heap  0x100
-stack 0x1000  /* adequate for demo program */
-l rts_ext.lib

MEMORY  
{
/* Note: Assume PMST = 0xffe0
        PMST    Bit     Name   Value
        		15-7	IPTR	0xff80
                6       MP/!MC  1
                5       OVLY    1
                3       DROM    0
*/
	PAGE 0:		/* Program Space */
		RSV1	(R)		: o=00000h l=00080h	/* Reserved 				*/
  		DARAM	(RWIX)	: o=00080h l=03f80h	/* On-Chip Dual-Access RAM	*/
  		EXT0	(R)		: o=04000h l=0bf80h	/* External Page 0			*/
		VECS	(RWIX)	: o=0ff80h l=00080h	/* Interrupt Vector Table	*/

	PAGE 1:		/* Data Space */
		MMRS	(RW)	: o=00000h l=00060h	/* Memory-Mapped Registers	*/
		SPAD	(RW)	: o=00060h l=00020h	/* Scratch-Pad RAM			*/
  		DARAM	(RWIX)  : o=00080h l=03f80h	/* On-Chip Dual-Access RAM	*/
  		EXT0	(R)		: o=04000h l=0c000h	/* External Page 0			*/
}

SECTIONS
{
	GROUP : > DARAM	/* group sections in overlay for contiguous addresses	*/
	{	
		.text    	/* User code					*/
		.rtdx_text	/* RTDX code					*/
		.cinit   	/* initialization tables		*/
		.pinit   	/* initialization functions		*/
		.switch  	/* for C-switch tables			*/
	
		.cio		/* C-IO Buffer					*/
		.bss		/* global & static vars			*/
		.const		/* C constant tables			*/

		.sysmem		/* dynamic heap		*/
		.stack		/* system stack		*/
		
	/*	.sysmem		: fill = 0DEADh	/* dynamic heap, diagnostic version	*/
    /*	.stack		: fill = 0BEEFh	/* stack fill, diagnostic version */
	}

	.vectors 	: > VECS  PAGE 0	/* interrupt vector table			*/

	.data		: > SPAD  PAGE 1	/* asm data area					*/
}
