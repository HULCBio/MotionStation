/* 
 * File: rt_looksplnevncsd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   N-D column-major table look-up
 *   operating on real_T with:
 *
 *   - Spline interpolation
 *   - Clipping
 *   - Evenly-spaced breakpoints
 *   - Uses previous index search result
 */

#include "rtlooksrc.h"

real_T rt_LookSplNEvnCSd(int_T                numDims,
			 const real_T * u,
			 rt_LUTSplineWork  * SWork)
{

  rt_LUTnWork * const TWork = SWork->TWork;
  real_T * const bpLambda  = TWork->bpLambda;
  int_T  * const bpIndex   = TWork->bpIndex;
  const int_T * const maxIndex = TWork->maxIndex;
  int_T    k;

  for(k=0; k < numDims; k++) {
    const real_T * const bpData = ((const real_T * const *)TWork->bpDataSet)[k];
    bpIndex[k] = rt_PLookEvnCd(u[k], &bpLambda[k], bpData, maxIndex[k]);
  }
                     
  return(rt_IntrpNSpld(numDims, SWork, 1));
}
/* [EOF] rt_looksplnevncsd.c */
