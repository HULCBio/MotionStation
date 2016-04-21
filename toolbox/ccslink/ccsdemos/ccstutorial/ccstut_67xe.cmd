/****************************************************************************
 * CCSFIR_67x.CMD - Example Target Linker Command File 
 *
 *   This file is provided as an example linker command file
 *   for the target code that implements the Matlab demo: CCSTUTORIAL
 *   This file was tested with the 6211/6711 processors.
 *
 *   It may be necessary to modify this file to conform to 
 *   details of each DSP implementation.              
 *****************************************************************************
 * Copyright 2003 The MathWorks, Inc.
 * $Revision: 1.1 $ $Date: 2003/07/07 18:02:21 $
 *****************************************************************************/

-c
-heap  0x500
-stack 0x500  /* adequate for demo program */

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
