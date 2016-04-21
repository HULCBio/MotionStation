/****************************************************************************
* 
* VERSION : $Revision: 1.1.4.1 $
* DATE    : $Date: 2003/11/30 23:05:40 $
* Copyright (c) 2000 Texas Instruments Incorporated
*
* COMMAND FILE FOR LINKING TMS5402 Targets
*
*   Usage:  lnk500 <obj files...>    -o <out file> -m <map file> c5402.cmd
*           cl500  <src files...> -z -o <out file> -m <map file> c5402.cmd
*
*   Description: This file is a sample command file that can be used
*                for linking programs built with the TMS54x C Compiler.   
*                Use it as a guideline; you may want to change
*                the allocation scheme according to the size of your
*                program and the memory layout of your target system.
*
****************************************************************************/
-lrtdxsim.lib
-lrts.lib
-c
-stack 0x0256
-heap  0x0256
/* This symbol defines the interrupt mask to be applied to IMR inside
   RTDX Critical Code sections.

   This example masks the timer interrupt.
*/
_RTDX_interrupt_mask = ~0x0008; /* interrupts masked by RTDX */

MEMORY  
{
/* Note: Assume PMST = 0xffe0
   Bit   Name    Value
   ===   ====    =====
  15-7   IPTR    0xff80
    6    MP/!MC    1
    5    OVLY      1
    3    DROM      0
*/

  PAGE 0: /* Program Space */

    RESERVED(R  ) : o= 00000h l= 00080h    /* Reserved                 */
    PGM1    (RWX) : o= 00080h l= 03f80h     /* On-Chip Dual-Access RAM  */
    PGM2    (RWX) : o= 04000h l= 0bf80h    /* External RAM Page 0      */
    VECS    (RWX) : o= 0ff80h l= 00080h    /* Interrupt Vector Table   */
    

  PAGE 1: /* Data Space */

    MMRS    (RW ) : o= 00000h l= 00060h    /* Memory-mapped registers */
    SCRATCH (RW ) : o= 00060h l= 00020h    /* scratch-pad DARAM */

    /* declarations for DARAM and SARAM already made in PAGE 0 */

    DATA1   (RW ) : o= 00080h l= 03000h    /* External Data RAM */
}

SECTIONS
{
    .intvecs		: > VECS    PAGE 0 /* interrupt vector table			*/

    .text		: > PGM2    PAGE 0 /* User code                     		*/
    .rtdx_text		: > PGM2    PAGE 0 /* RTDX code                     		*/
    .cinit 		: > PGM2    PAGE 0 /* initialization tables         		*/
    .pinit		: > PGM2    PAGE 0 /* initialization functions      		*/
    .switch		: > PGM2    PAGE 0 /* for C-switch tables           		*/

    .sysmem		: > DATA1 PAGE 1 fill = 0DEADh /* dynamic heap 		*/
    .stack		: > DATA1 PAGE 1 fill = 0BEEFh /* system stack 		*/
    .const		: > DATA1 PAGE 1 /* C constant tables             		*/
    .cio		: > DATA1 PAGE 1 /* C-IO Buffer                   		*/
    .bss		: > DATA1 PAGE 1 /* global & static vars          		*/
    .data		: > DATA1 PAGE 1 /* asm data area				*/
    .rtdx_data		: > DATA1 PAGE 1 /* RTDX data area				*/
}
