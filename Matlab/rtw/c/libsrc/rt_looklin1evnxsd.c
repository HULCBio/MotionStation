/* 
 * File: rt_looklin1evnxsd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   1-D  table look-up
 *   operating on real_T with:
 *
 *   - Linear interpolation
 *   - Linear extrapolation
 *   - Evenly-spaced breakpoints
 *   - Uses previous index search result
 */

#include "rtlooksrc.h"

real_T rt_LookLin1EvnXSd(const real_T u,
                         const real_T * const bpData,
                         const real_T * const tableData,
			 int_T  * const bpIndex,
                         const int_T    maxIndex)
{
  real_T lambda;
  *bpIndex = rt_PLookEvnXd(u, &lambda, bpData, maxIndex);
  return(tableData[*bpIndex] + lambda * (tableData[*bpIndex+1] - tableData[*bpIndex]));
}
/* [EOF] rt_looklin1evnxsd.c */
