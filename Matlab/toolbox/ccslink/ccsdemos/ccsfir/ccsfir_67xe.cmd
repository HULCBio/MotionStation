/****************************************************************************
 * CCSFIR_6x11.CMD - Example Target Linker Command File 
 *
 *   This file is provided as an example linker command file
 *   for the target code that implements the Matlab demo: CCSFIRDEMO
 *   This file was tested with the 6211/6711 processors.
 *
 *   It may be necessary to modify this file to conform to 
 *   details of each DSP implementation.              
 ****************************************************************************/
/*
 * Copyright 2002-2003 The MathWorks, Inc.
 * $Revision: 1.2 $ $Date: 2003/07/28 15:42:57 $
 */
-c
-heap  0x1000
-stack 0x1000  /* adequate for demo program */

MEMORY
{
    IRAM       : origin = 0x0,         len = 0x10000
}


SECTIONS
{
        .vectors  load=0x00000000 
        .text    > IRAM

        .bss     > IRAM
        .cinit   > IRAM
        .const   > IRAM
        .far     > IRAM
        .stack   > IRAM
        .cio     > IRAM
        .sysmem  > IRAM
}
