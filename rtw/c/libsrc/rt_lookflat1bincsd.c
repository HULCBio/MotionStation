/* 
 * File: rt_lookflat1bincsd.c generated from file
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
 *   - Binary breakpoint search
 *   - Uses previous index search result
 */

#include "rtlooksrc.h"

real_T rt_LookFlat1BinCSd(const real_T u,
			  const real_T * const bpData,
			  const real_T * const tableData,
			  int_T  * const bpIndex,
			  const int_T    maxIndex)
{
  real_T lambda;
  *bpIndex = rt_PLookBinCd(u, &lambda, bpData, maxIndex, *bpIndex);
  return(rt_Intrp1Flatd(*bpIndex, lambda, tableData));
}
/* [EOF] rt_lookflat1bincsd.c */
