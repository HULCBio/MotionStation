/* 
 * File: rt_looklin1binxsf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   1-D  table look-up
 *   operating on real32_T with:
 *
 *   - Linear interpolation
 *   - Linear extrapolation
 *   - Binary breakpoint search
 *   - Uses previous index search result
 */

#include "rtlooksrc.h"

real32_T rt_LookLin1BinXSf(const real32_T u,
			   const real32_T * const bpData,
			   const real32_T * const tableData,
			   int_T  * const bpIndex,
			   const int_T    maxIndex)
{
  real32_T lambda;
  *bpIndex = rt_PLookBinXf(u, &lambda, bpData, maxIndex, *bpIndex);
  return(tableData[*bpIndex] + lambda * (tableData[*bpIndex+1] - tableData[*bpIndex]));
}
/* [EOF] rt_looklin1binxsf.c */
