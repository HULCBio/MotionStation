/*
 * File: rt_plookevncd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"



/* Function: ===============================================
 * Abstract:
 *    Integrated index search function with clipping
 *    and direct calculations for both index and interval 
 *    fraction (lambda) for evenly spaced data.
 *
 */
int_T    rt_PLookEvnCd(const real_T         u,
		       real_T * const lambda,
		       const real_T * const bpData,
		       const int_T          maxIndex)
{
  if (u <= bpData[0]) {
    *lambda = 0.0;
    return(0);
  } else if (u >= bpData[maxIndex]) {
    *lambda = 1.0;
    return(maxIndex-1);
  } else {
    const real_T invSpacing = 1.0/(bpData[1] - bpData[0]);
    const int_T bpIndex = (int_T)((u - bpData[0]) * invSpacing);
    *lambda = (u - bpData[bpIndex]) * invSpacing;
    return(bpIndex);
  }
} /* [EOF] rt_plookevncd.c */
