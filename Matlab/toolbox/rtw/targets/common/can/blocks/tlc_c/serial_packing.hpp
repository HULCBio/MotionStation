/*
 * $Revision: 1.6 $
 * $Date: 2002/11/15 16:39:07 $
 *
 * Copyright 2002 The MathWorks, Inc.
 */
#ifndef SERIAL_PACKING_HPP
#define SERIAL_PACKING_HPP

#define WORD uint32_T
#define WORD_SIZE (( int ) sizeof(uint32_T))
#define WORD_BIT_SIZE (( int ) sizeof(uint32_T) * 8)
#define MESSAGE_LENGTH 8
#define MESSAGE_WORD_LENGTH 2

//#define SERIAL_PACK_DEBUG

// function prototypes - use the C function call standard


#include "endian_test.hpp"

#ifdef __cplusplus
extern "C" { // use the C fcn-call standard for all functions  
            // defined within this scope                     
#endif


#include "simstruc.h"
extern void pack(WORD * M , WORD S, int message_length,
      int start_bit, int bit_length, int signal_endian);

extern WORD unpack(WORD * M, int message_length,
      int start_bit, int bit_length, int signal_endian);


#ifdef __cplusplus
} // end of extern "C" scope
#endif

#endif
