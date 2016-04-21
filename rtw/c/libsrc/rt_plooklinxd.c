/*
 * File : rt_plooklinxd.c generated from file
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
 *    or linear search algorithm to find index and interval 
 *    fraction (lambda).
 */
int_T    rt_PLookLinXd(const real_T         u,
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
  } else {
    for(;;) {
      if (u < bpData[bpIndex]) {
        bpIndex--;
      } else if (u >= bpData[bpIndex+1]) {
        bpIndex++;
      } else {
        break;
      }
    }
  }

  *lambda = (u - bpData[bpIndex]) / (bpData[bpIndex+1] - bpData[bpIndex]);
  return(bpIndex);
} /* [EOF] rt_plooklinxd.c */
