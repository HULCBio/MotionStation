/*
 * File : rt_plooklincd.c generated from file
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
 *    linear search algorithm to find index and interval 
 *    fraction (lambda).
 */
int_T    rt_PLookLinCd(const real_T         u,
		       real_T * const lambda,
		       const real_T * const bpData,
		       const int_T          maxIndex,
		       const int_T          index0)
{
  if (u <= bpData[0]) {
    *lambda = 0.0;
    return(0);
  } else if (u >= bpData[maxIndex]) {
    *lambda = 1.0;
    return(maxIndex-1);
  } else {
    int_T bpIndex = index0;

    for(;;) {
      if (u < bpData[bpIndex]) {
        bpIndex--;
      } else if (u >= bpData[bpIndex+1]) {
        bpIndex++;
      } else {
        *lambda = (u - bpData[bpIndex]) / (bpData[bpIndex+1] - bpData[bpIndex]);
        return(bpIndex);
      }
    }
  }
} /* [EOF] rt_plooklincd.c */
