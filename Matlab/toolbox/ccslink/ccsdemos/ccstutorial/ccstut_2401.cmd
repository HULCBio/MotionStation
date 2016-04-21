/* Copyright 2002-2003 The MathWorks, Inc. */

/* Linker commands */
-c				               /* ROM autoinitialization */
-x                             /* force rereading libraries */
-stack 100
 
/* Specify memory map */
MEMORY
{
  PAGE 0 : /* program memory */
          VECS: origin = 08000h, length = 00004h 
          CODE: origin = 08004h, length = 001FCh    
          
  PAGE 1 : /* data memory */
          DARAMB0: origin = 0200h, length = 0100h
          DARAMB1: origin = 0300h, length = 0100h
}

/* Specify sections */
SECTIONS
{
  .text      :    > CODE PAGE = 0
  .switch    :    > CODE PAGE = 0
  .data      :    > DARAMB0 PAGE = 1
  .bss       :    > DARAMB0 PAGE = 1
  .heap      :    > DARAMB0 PAGE = 1
  .stack     :    > DARAMB1 PAGE = 1
}
