/*
 * File: sfun_can_frame_fp_functions.c
 *
 * Abstract:
 *
 *
 * $Revision: 1.1.6.1 $
 * $Date: 2004/04/08 20:57:32 $
 *
 * Copyright 2004 The MathWorks, Inc.
 */

#include "sfun_can_frame_fp_functions.h"

/* WARNING: The following functions require CANDB_CONSISTENT_FP
 * to be defined - this is a sanity check to make sure that the -Op
 * option is being correctly applied in the makefile.
 */
#ifndef CANDB_CONSISTENT_FP
   #error CANDB_CONSISTENT_FP is not defined - only define if -Op option is set!
#endif

/* documentation in header file 
 * 
 * WARNING: See this function needs to be 
 * compiled with true ANSI floating point support
 * see header file for more details. 
 *
 * Note: this function was tested with all possible input values.
 * It was found that the maximum number of iterations of the while 
 * loop is 128 for an input == UINT32_MAX.
 *
 * This is an acceptable amount of processing in the worst case, 
 * since this code only executes once during Simulation mdlStart. This 
 * code does not run in real time.
 * 
 */
real32_T castMaxSVtoFloat(uint32_T input) {
   real64_T inputDbl = (real64_T) input;
   real64_T workingDbl = inputDbl;
   real32_T output;
   while (1) {
      output = (real32_T) workingDbl;
      if (output <= inputDbl) {
         break;
      }
      else {
         /* step down until we find a real32 value 
          * smaller than the input */
         workingDbl -= 1.0;
      }
   }
   if (output != inputDbl) {
      mexPrintf("A maximum scaled value %u, could not be exactly represented as a single.\n", input);
      mexPrintf("The value has been reduced to %f.\n", output);
   }
   return output;
}

/* documentation in header file 
 *
 * WARNING: See this function needs to be 
 * compiled with true ANSI floating point support
 * see header file for more details. 
 * 
 * See comments above for castMaxSVtoFloat worst case.
 * 
 */
real32_T castMinSVtoFloat(int32_T input) {
   real64_T inputDbl = (real64_T) input;
   real64_T workingDbl = inputDbl;
   real32_T output;
   while (1) {
      output = (real32_T) workingDbl;
      if (output >= inputDbl) {
         break;
      }
      else {
         /* step up until we find a real32 value
          * larger than the input */
         workingDbl += 1.0;
      }
   }
   if (output != inputDbl) {
      mexPrintf("A minimum scaled value %d, could not be exactly represented as a single.\n", input);
      mexPrintf("The value has been increased to %f.\n", output);
   }
   return output;
}
