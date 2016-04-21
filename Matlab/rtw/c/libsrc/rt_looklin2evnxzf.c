/* 
 * File: rt_looklin2evnxzf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   2-D column-major table look-up
 *   operating on real32_T with:
 *
 *   - Linear interpolation
 *   - Linear extrapolation
 *   - Evenly-spaced breakpoints
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real32_T rt_LookLin2EvnXZf(const real32_T         u0,
			   const real32_T         u1,
			   const real32_T * const bpData01,
			   const real32_T * const bpData02,
			   const real32_T * const tableData,
			   const int_T  * const maxIndex)
{
  real32_T bpLambda[2];
  int_T  bpIndex[2];

  bpIndex[0] = rt_PLookEvnXf(u0, &bpLambda[0], bpData01, maxIndex[0]);
  bpIndex[1] = rt_PLookEvnXf(u1, &bpLambda[1], bpData02, maxIndex[1]);
  {
    const int_T   numRows = maxIndex[0] + 1;
    const real32_T *yupper  = (const real32_T *)&tableData[bpIndex[0]+numRows*bpIndex[1]];
    const real32_T *ylower  =  yupper + 1;
    const real32_T  yleft   = *yupper + bpLambda[0]*(*ylower - (*yupper));
                       
    yupper +=  numRows;
    ylower  =  yupper + 1;
                       
    return(yleft + bpLambda[1] * 
	   (((*yupper) + bpLambda[0]*((*ylower) - (*yupper))) - yleft));
  }
}
/* [EOF] rt_looklin2evnxzf.c */
