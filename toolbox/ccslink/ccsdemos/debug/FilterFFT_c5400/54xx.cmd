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
 * $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:17:04 $
 */
-c
-heap  0x100
-stack 0x1000  /* adequate for demo program */
-l rts.lib

MEMORY {
   PAGE 0: /* program memory */

      /* IF       THIS IS                               */
      /* ===      =======                               */
      /* OVLY=1   some of internal RAM and/or external  */
      /*          RAM depending on which C54x this is.  */
      /* OVLY=0   external RAM                          */
	PROG_RAM (RWX) : origin = 0x1400, length = 0x6C00
	PROG_EXT (RWX) : origin = 0x8000, length = 0x4000
   
      /* boot interrupt vector table location */
        VECTORS (RWX): origin = 0xFF80, length = 0x80


   PAGE 1: /* data memory, addresses 0-7Fh are reserved */

      /* some (or all) of internal DARAM */
	DATA_RAM (RW): origin = 0x1400, length = 0x6C00
	DATA_EXT (RW): origin = 0x8000, length = 0x7FFF


   PAGE 2: /* I/O memory */

      /* no devices declared */

} /* MEMORY */


SECTIONS {
   .text    >> PROG_RAM | PROG_EXT PAGE 0   /* code                     */
   .switch  > PROG_RAM PAGE 0               /* switch table info        */

/* .cinit must be allocated to PAGE 0 when using -c (vs -cr)            */
/* .cinit   > PROG_RAM PAGE 0 *//* commented because -cr used above     */

   .vectors > VECTORS PAGE 0               /* interrupt vectors         */

   .cio     >  DATA_RAM PAGE 1             /* C I/O                     */  
   .data    >> DATA_RAM | DATA_EXT PAGE 1  /* initialized data          */
   .bss     >> DATA_RAM | DATA_EXT PAGE 1  /* global & static variables */
   .const   >  DATA_RAM PAGE 1             /* constant data             */
   .sysmem  >> DATA_RAM | DATA_EXT PAGE 1  /* heap                      */
   .stack   >> DATA_RAM | DATA_EXT PAGE 1  /* stack                     */
} /* SECTIONS */