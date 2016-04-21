/*
 * File : rt_plookbincf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ===============================================
 * Abstract:
 *    Integrated index search function with clipping or 
 *    binary search algorithm to find index and interval 
 *    fraction (lambda).  32-bit index will not overflow
 *    for double or single datatypes with 32-bit addressing
 *    (i.e., 256M max elements in breakpoint data).
 */
int_T  rt_PLookBinCf(const real32_T         u,
		     real32_T * const lambda,
		     const real32_T * const bpData,
		     const int_T          maxIndex,
		     const int_T          index0)
{
  if (u <= bpData[0]) {
    *lambda = 0.0F;
    return(0);
  } else if (u >= bpData[maxIndex]) {
    *lambda = 1.0F;
    return(maxIndex-1);
  } else if (u < bpData[maxIndex-1]) {
    int_T bottom  = 0;
    int_T top     = maxIndex;
    int_T bpIndex = index0;

    for(;;) {
      if (u < bpData[bpIndex]) {
        top     = bpIndex - 1;
      } else if (u >= bpData[bpIndex+1]) {
        bottom  = bpIndex + 1;
      } else {
        *lambda = (u - bpData[bpIndex])/(bpData[bpIndex+1]-bpData[bpIndex]);
        return(bpIndex);
      }
      bpIndex = (bottom + top) >> 1;
    }
  } else {
    int_T bpIndex = maxIndex-1;
    *lambda = (u - bpData[bpIndex])/(bpData[bpIndex+1]-bpData[bpIndex]);
    return(bpIndex);      
  }
} /* [EOF] rt_plookbincf.c */
