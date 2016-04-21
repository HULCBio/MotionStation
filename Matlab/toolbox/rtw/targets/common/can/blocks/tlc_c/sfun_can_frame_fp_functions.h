/*
 * File: sfun_can_frame_fp_functions.h
 *
 * Abstract:
 *
 *
 * $Revision: 1.1.6.1 $
 * $Date: 2004/04/08 20:57:33 $
 *
 * Copyright 2004 The MathWorks, Inc.
 */

#ifndef _SFUN_CAN_FRAME_FP_FUNCTIONS_H_
#define  _SFUN_CAN_FRAME_FP_FUNCTIONS_H_

#include "tmwtypes.h"

/* WARNING:
 *
 * The following functions need to be compiled with true ANSI floating 
 * point support.   Otherwise, the compiler may apply floating point
 * optimisations (using the 80 bit native fp registers on Intel) and 
 * the functions will not behave as desired.
 *
 * This code will be compiled with the Microsoft Visual C++ cl compiler
 * and we should use the -Op option which provides "improved floating point
 * consistency" which is actually ANSI C floating point behaviour.
 */
   
/* given a min scaled value as an int32,
 * calculate a single precision floating point value
 * that is greater than or equal to the input */
real32_T castMinSVtoFloat(int32_T input);
  
/* given a max scaled value as a uint32,
 * calculate a single precision floating point value 
 * that is less than or equal to the input */
real32_T castMaxSVtoFloat(uint32_T input);

#endif
