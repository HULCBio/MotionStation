/*
 * File : rt_plookbinxd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ===============================================
 * Abstract:
 *    Integrated index search function with extrapolation  
 *    or binary search algorithm to find index and interval 
 *    fraction (lambda).  32-bit index will not overflow
 *    for double or single datatypes with 32-bit addressing
 *    (i.e., only 256k max elements in breakpoint data).
 */
int_T rt_PLookBinXd(const real_T         u,
		    real_T * const lambda,
		    const real_T * const bpData,
		    const int_T          maxIndex,
		    const int_T          index0)
{
  int_T bpIndex = index0;

  if (u <= bpData[0]) {
    bpIndex = 0;
  } else if (u >= bpData[maxIndex]) {
    bpIndex = maxIndex - 1;
  } else if (u < bpData[maxIndex]) {
    int_T bottom = 0;
    int_T top    = maxIndex;

    for(;;) {
      if (u < bpData[bpIndex]) {
        top = bpIndex - 1;
        bpIndex = (bottom + top) >> 1;
      } else if (u >= bpData[bpIndex+1]) {
        bottom  = bpIndex + 1;
        bpIndex = (bottom + top) >> 1;
      } else {
        *lambda = (u - bpData[bpIndex])/(bpData[bpIndex+1]-bpData[bpIndex]);
        break;
      }
    }
  } else {
    bpIndex = maxIndex - 1;
  }

  *lambda = (u - bpData[bpIndex]) / (bpData[bpIndex+1] - bpData[bpIndex]);
  return(bpIndex);
} /* [EOF] rt_plookbinxd.c */
