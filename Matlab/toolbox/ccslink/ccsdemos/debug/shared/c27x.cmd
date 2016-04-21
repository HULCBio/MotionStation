

/****************************************************************************/
/* SINEWAVE.CMD - COMMAND FILE FOR LINKING TMS27xx/TMS28xx C PROGRAMS       */
/*                                                                          */
/*   Description: This file is a sample command file that can be used       */
/*                for linking programs built with the TMS320C2000 C         */
/*                Compiler.   Use it as a guideline; you may want to change */
/*                the allocation scheme according to the size of your       */
/*                program and the memory layout of your target system.      */
/****************************************************************************/

MEMORY
{
PAGE 0 : RESET(R)       : origin = 0x000000, length = 0x2
         VECTORS(R)     : origin = 0x000002, length = 0x1E
         PROG(R)        : origin = 0x3f0000, length = 0x8000
PAGE 1 : RAM1 (RW)      : origin = 0x000010, length = 0x3F0
PAGE 1 : RAM2 (RW)      : origin = 0x001000, length = 0x3000
PAGE 1 : RAM3 (RW)      : origin = 0x3f8000, length = 0x8000
}
 
SECTIONS
{
      .reset   : > RESET,   PAGE = 0
       vectors : > VECTORS, PAGE = 0
      .pinit   : > PROG,    PAGE = 0
      .cinit   : > PROG,    PAGE = 0
      .text    : > PROG,    PAGE = 0

      .bss     : > RAM2,    PAGE = 1
      .const   : > RAM2,    PAGE = 1
      .stack   : > RAM2,    PAGE = 1
      .sysmem  : > RAM2,    PAGE = 1

      .ebss    : > RAM3,    PAGE = 1
      .econst  : > RAM3,    PAGE = 1
      .esysmem : > RAM3,    PAGE = 1
}
