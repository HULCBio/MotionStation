/* 
 * File: rt_looklinnlinxzd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   N-D column-major table look-up
 *   operating on real_T with:
 *
 *   - Linear interpolation
 *   - Linear extrapolation
 *   - Linear breakpoint search
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real_T rt_LookLinNLinXZd(int_T                numDims,
			 const real_T * u,
			 rt_LUTnWork  * TWork)
{

  real_T * const bpLambda  = TWork->bpLambda;
  int_T  * const bpIndex   = TWork->bpIndex;
  const int_T * const maxIndex = TWork->maxIndex;
  int_T    k;

  for(k=0; k < numDims; k++) {
    const real_T * const bpData = ((const real_T * const *)TWork->bpDataSet)[k];
    bpIndex[k] = rt_PLookLinXd(u[k], &bpLambda[k], bpData, maxIndex[k], maxIndex[k] >> 1);
  }
                     
  return(rt_IntrpNLind(numDims-1, 0, TWork));
}
/* [EOF] rt_looklinnlinxzd.c */
