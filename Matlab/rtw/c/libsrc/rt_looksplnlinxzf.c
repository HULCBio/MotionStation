/* 
 * File: rt_looksplnlinxzf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   N-D column-major table look-up
 *   operating on real32_T with:
 *
 *   - Spline interpolation
 *   - Linear extrapolation
 *   - Linear breakpoint search
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real32_T rt_LookSplNLinXZf(int_T                numDims,
			   const real32_T * u,
			   rt_LUTSplineWork  * SWork)
{

  rt_LUTnWork * const TWork = SWork->TWork;
  real32_T * const bpLambda  = TWork->bpLambda;
  int_T  * const bpIndex   = TWork->bpIndex;
  const int_T * const maxIndex = TWork->maxIndex;
  int_T    k;

  for(k=0; k < numDims; k++) {
    const real32_T * const bpData = ((const real32_T * const *)TWork->bpDataSet)[k];
    bpIndex[k] = rt_PLookLinXf(u[k], &bpLambda[k], bpData, maxIndex[k], maxIndex[k] >> 1);
  }
                     
  return(rt_IntrpNSplf(numDims, SWork, 2));
}
/* [EOF] rt_looksplnlinxzf.c */
