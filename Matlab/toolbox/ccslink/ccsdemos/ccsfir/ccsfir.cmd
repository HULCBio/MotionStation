/* CCSFIR.CMD - Example Target Linker Command Fail
 *   This file is provided as an example linker command file
 *   for the target code that implements the Matlab demo: CCSFIRDEMO
 *   This file was tested with a 62xx DSK and 67xx EVM.  However,
 *   it may be necessary to modify this file to conform to 
 *   details of each DSP implementation.
 */
/*
 * Copyright 2001-2003 The MathWorks, Inc.
 * $Revision: 1.6.4.1 $ $Date: 2003/11/30 23:03:25 $
 */
-c
-heap  0x100
-stack 0x100  /* adequate for demo program */


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
