/* 
 * File: rt_lookflatnbinczd.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 *
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 * Abstract:
 *   N-D column-major table look-up
 *   operating on real_T with:
 *
 *   - Flat table look-up
 *   - Clipping
 *   - Binary breakpoint search
 *   - Index search starts at the same place each time
 */

#include "rtlooksrc.h"

real_T rt_LookFlatNBinCZd(int_T                numDims,
			  const real_T * u,
			  rt_LUTnWork  * TWork)
{

  real_T * const bpLambda  = TWork->bpLambda;
  int_T  * const bpIndex   = TWork->bpIndex;
  const int_T * const maxIndex = TWork->maxIndex;
  int_T    k;

  for(k=0; k < numDims; k++) {
    const real_T * const bpData = ((const real_T * const *)TWork->bpDataSet)[k];
    bpIndex[k] = rt_PLookBinCd(u[k], &bpLambda[k], bpData, maxIndex[k], maxIndex[k] >> 1);
  }
                     
  return(rt_IntrpNFlatd(numDims-1, TWork));
}
/* [EOF] rt_lookflatnbinczd.c */
