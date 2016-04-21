/****************************************************************************/
/*   Origin: <CCSROOT>\tutorial\dsk2407\volume1
/*   volume.cmd - Sample linker command file for F24xx devices              */
/*                                                                          */
/*   Description: This file is a sample F24xx linker command file that can  */
/*                be used for linking programs built with the TMS320C24xx   */
/*                C Compiler. Use it as a guideline; you may want to change */
/*                the allocation scheme according to the size of your       */
/*                program and the memory layout of your target system.      */
/****************************************************************************/

MEMORY
{
    PAGE 0: VECS:  origin = 0000h, length = 0040h
            PROG:  origin = 0040h, length = 3fc0h

    PAGE 1: B0B1:  origin = 0200h, length = 200h
            SARAM: origin = 8000h, length = 1000h
}
 
SECTIONS
{
    vectors : { } > VECS    PAGE = 0
   .cinit   : { } > PROG    PAGE = 0
   .text    : { } > PROG    PAGE = 0


   .const   : { } > B0B1    PAGE 1
   .data    : { } > B0B1    PAGE 1
   .bss     : { } > SARAM   PAGE 1
   .stack   : { } > SARAM   PAGE 1
   .sysmem  : { } > SARAM   PAGE 1
}
