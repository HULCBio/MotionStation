/* $Revision: 1.4.4.1 $ */
/* multigsadadio.h - xPC Target, header file for the General Standards */
/* ADADIO multi function board.                                        */
/* Copyright 1996-2003 The MathWorks, Inc. */

#define ADDR_MODE_IO       1
#define ADDR_MODE_MEM      0

// readLongIO assumes that there are two local variables,
// addrmode which selects IO versus memory mapped and
// baseaddr which contains either the IO base or the
// memory base address of the board.
#define readLongIO( reg, rtn )                                   \
{                                                                \
    if( addrmode == ADDR_MODE_IO )                               \
    {                                                            \
        rtn = rl32eInpDW( (uint16_T)(baseaddr + ((reg)<<2) ) );  \
    }                                                            \
    else                                                         \
    {                                                            \
        rtn = *((volatile uint32_T *)baseaddr + reg );           \
    }                                                            \
}

#define writeLongIO( reg, value )                                \
{                                                                \
    if( addrmode == ADDR_MODE_IO )                               \
    {                                                            \
        rl32eOutpDW( (uint16_T)(baseaddr + ((reg)<<2)), value ); \
    }                                                            \
    else                                                         \
    {                                                            \
        *((volatile uint32_T *)baseaddr + reg ) = value;         \
    }                                                            \
}

// The registers are positioned by the following defines.
// These are long word offsets from the base address.
#define BCR      0
#define DIGIO    1
#define AOUT0    2
#define AOUT1    3
#define AOUT2    4
#define AOUT3    5
#define AIN      6
#define RATE     7

#define CAL_STATUS         0x00000020
#define OUTPUT_ENABLE      0x00040000
#define OUTPUT_STROBE_EBL  0x00080000
#define INPUT_BUFFER_EMPTY 0x00100000
#define INTERRUPT_REQUEST  0x04000000
#define START_CAL          0x10000000
#define OUTPUT_STROBE      0x20000000
#define MANUAL_AD_TRIGGER  0x40000000
#define BOARD_RESET        0x80000000

// Digital IO control bit
#define DIGITAL_DIR_OUTPUT 0x00000400
