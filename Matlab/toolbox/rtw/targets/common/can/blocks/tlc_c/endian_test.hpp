/*
 * File: endian_test.hpp
 *
 * Abstract:
 *    
 *
 *
 * $Revision: 1.9.4.1 $
 * $Date: 2004/04/19 01:19:49 $
 *
 * Copyright 2001-2002 The MathWorks, Inc.
 */

#ifndef ENDIAN_TEST_HPP
#define ENDIAN_TEST_HPP

// the ENDIANESS of the CPU running this code
typedef enum CPU_ENDIAN { LITTLE_ENDIAN=0,BIG_ENDIAN }; 

// store long(1) and access as char array to determine how bytes are stored (Endianess)
static union {
   long l;
   char c[sizeof(long)];
}ENDIAN_TEST = {1};
// the ENDIAN test: 1 in high byte -> BE, 1 in low byte -> LE
#define CPU_ENDIAN ( ENDIAN_TEST.c[sizeof(long)-1]  == 1 ? BIG_ENDIAN : LITTLE_ENDIAN )

#endif
