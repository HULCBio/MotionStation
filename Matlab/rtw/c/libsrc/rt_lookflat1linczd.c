/* 
 * File: rt_lookflat1linczd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   1-D  table look-up
 *   operating on real_T with:
 *
 *   - Flat table look-up
 *   - Clipping
 *   - Linear breakpoint search
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real_T rt_LookFlat1LinCZd(const real_T u,
			  const real_T * const bpData,
			  const real_T * const tableData,
			  const int_T    maxIndex)
{
  real_T lambda;
  int_T bpIndex = maxIndex >> 1;
  bpIndex = rt_PLookLinCd(u, &lambda, bpData, maxIndex, bpIndex);
  return(rt_Intrp1Flatd(bpIndex, lambda, tableData));
}
/* [EOF] rt_lookflat1linczd.c */
