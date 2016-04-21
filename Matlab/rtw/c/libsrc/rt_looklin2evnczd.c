/* 
 * File: rt_looklin2evnczd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   2-D column-major table look-up
 *   operating on real_T with:
 *
 *   - Linear interpolation
 *   - Clipping
 *   - Evenly-spaced breakpoints
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real_T rt_LookLin2EvnCZd(const real_T         u0,
                         const real_T         u1,
                         const real_T * const bpData01,
                         const real_T * const bpData02,
                         const real_T * const tableData,
                         const int_T  * const maxIndex)
{
  real_T bpLambda[2];
  int_T  bpIndex[2];

  bpIndex[0] = rt_PLookEvnCd(u0, &bpLambda[0], bpData01, maxIndex[0]);
  bpIndex[1] = rt_PLookEvnCd(u1, &bpLambda[1], bpData02, maxIndex[1]);
  {
    const int_T   numRows = maxIndex[0] + 1;
    const real_T *yupper  = (const real_T *)&tableData[bpIndex[0]+numRows*bpIndex[1]];
    const real_T *ylower  =  yupper + 1;
    const real_T  yleft   = *yupper + bpLambda[0]*(*ylower - (*yupper));
                       
    yupper +=  numRows;
    ylower  =  yupper + 1;
                       
    return(yleft + bpLambda[1] * 
	   (((*yupper) + bpLambda[0]*((*ylower) - (*yupper))) - yleft));
  }
}
/* [EOF] rt_looklin2evnczd.c */
