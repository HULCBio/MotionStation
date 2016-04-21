/****************************************************************************/
/*   ccstut_28xx.cmd - Sample linker command file for F28xx devices            */
/*                                                                          */
/*   Description: This file is a sample F2812 linker command file that can  */
/*                be used for linking programs built with the TMS320C2000   */
/*                C Compiler. Use it as a guideline; you may want to change */
/*                the allocation scheme according to the size of your       */
/*                program and the memory layout of your target system.      */
/****************************************************************************/

MEMORY
{
   PAGE 0 : BOOT(R)     : origin = 0x3f8000, length = 0x80
   PAGE 0 : PROG(R)     : origin = 0x3f8080, length = 0x1f80
   PAGE 0 : RESET(R)    : origin = 0x000000, length = 0x2
   PAGE 0 : POFFCHIP    : origin = 0x100000, length = 0x4000

   PAGE 1 : L0L1RAM(RW)   : origin = 0x000000, length = 0x400
   PAGE 1 : L0L1RAM(RW)   : origin = 0x000400, length = 0x400
   PAGE 1 : L0L1RAM(RW) : origin = 0x008000, length = 0x2000
   PAGE 1 : OFFCHIP     : origin = 0x104000, length = 0x4000
}
 
SECTIONS
{
   /* 22-bit program sections */
   .reset   : > RESET,   PAGE = 0
   .pinit   : > PROG,    PAGE = 0
   .cinit   : > PROG,    PAGE = 0
   .boot > BOOT
   {
      -lrts2800_ml.lib<boot.obj> (.text)
   }
   
   .text    : > PROG,    PAGE = 0

   /* 16-Bit data sections */
   .const   : > L0L1RAM, PAGE = 1
   .bss     : > L0L1RAM, PAGE = 1
   .stack   : > L0L1RAM, PAGE = 1
   .sysmem  : > L0L1RAM, PAGE = 1

   /* 32-bit data sections */
   .ebss    : > L0L1RAM, PAGE = 1
   .econst  : > L0L1RAM, PAGE = 1
   .esysmem : > L0L1RAM, PAGE = 1
}
