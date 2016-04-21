/************************************************************************
 *	File taken from <TIDIR>\examples\dsk2812\rtdx\shared\f2812dsk.cmd
 ************************************************************************/
/*
//###########################################################################
//
// FILE:	F2812.cmd
//
// TITLE:	Linker Command File For F2812 Device
//
//###########################################################################
*
* Description:
*       This file is a sample command file that can be used
*       for linking programs built with the C28XX C Compiler.
*       Use it as a guideline; you  may want to change the
*       allocation scheme according to the size of your program
*       and the memory layout of your target system.
*
//###########################################################################
*/

-c
-stack 0x400                   /* STACK SIZE               */
-heap  0x200                   /* HEAP  SIZE               */


/* This symbol defines the interrupt mask to be applied to IER inside
   RTDX Critical Code sections.
   This masks DLOGINT
*/

_RTDX_interrupt_mask = ~0x4000; /* interrupts masked by RTDX    */

/* Set entry point to Reset vector                                  */
/* - Allows Reset ISR to force VMAP to point to vector table.  */



 -e c_int00 

MEMORY
{
PAGE 0 : 
   VECTORS(R)   : origin = 0x000000, length = 0x000040
   BOOT(R)      : origin = 0x3f8000, length = 0x80
   PROG(R)      : origin = 0x3f8080, length = 0x1f80
   M0RAM(R)   	: origin = 0x000100, length = 0x300
   
PAGE 1 : 

   PAGE 1 : M1RAM(RW)   : origin = 0x000400, length = 0x400
   PAGE 1 : L0L1RAM(RW) : origin = 0x008000, length = 0x2000

}
 
 
SECTIONS
{
   /* Allocate program areas: */

   .intvecs         : > VECTORS,  PAGE = 0  /* Interrupt Vectors        */

   .cinit           : > PROG,     PAGE = 0  /* Initialization Tables    */
   .pinit           : > PROG,     PAGE = 0  /* Initialization Tables    */
   .text            : > PROG,     PAGE = 0  /* Code                     */
   .rtdx_text       : > PROG,     PAGE = 0  /* rtdx code                */
   .switch          : > PROG,     PAGE = 0  /* switch table info        */

   .econst           : > M0RAM,     PAGE = 0  /* constant data  
   /* Allocate data areas: */
   .stack           : > M1RAM,  PAGE = 1  fill=0xBEEF
   .bss             : > L0L1RAM,  PAGE = 1  fill=0xBEEF
   .ebss            : > L0L1RAM,  PAGE = 1  fill=0xBEEF
   .sysmem          : > L0L1RAM,  PAGE = 1  fill=0xBEEF 
   .data            : > L0L1RAM,  PAGE = 1  fill=0xBEEF
   .rtdx_data       : > L0L1RAM,  PAGE = 1  fill=0xBEEF
   .cio             : > L0L1RAM,  PAGE = 1  fill=0xBEEF
   .const           : > L0L1RAM,  PAGE = 1  fill=0xBEEF/* constant data            */

  .boot > BOOT
   {
      -lrts2800.lib<boot.obj>(.text)
   }
}
