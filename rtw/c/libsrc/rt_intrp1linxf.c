/*
 * File : rt_intrp1linxf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Linear 1-D interpolation of a table, with extrapolation.
 */
real32_T rt_Intrp1LinXf(const int_T    bpIndex,
			const real32_T   lambda,
			const real32_T * const tableData,
			const int_T    maxIndex)
{
  real32_T normLambda = lambda;
  int_T  normIdx;

  if (bpIndex < 0) {
    normIdx = 0;
    if (!(lambda < (real32_T)(bpIndex))) {
      normLambda = (real32_T)bpIndex;
    }
  } else if (bpIndex >= maxIndex) {
    normIdx = (maxIndex - 1);
    if (!(lambda > (real32_T)(bpIndex - maxIndex))) {
      normLambda = (real32_T)(bpIndex - maxIndex);
    }
  } else {
    normIdx = bpIndex;
  }
    
  return(tableData[normIdx] + 
         normLambda * (tableData[normIdx+1] - tableData[normIdx]));
} /* [EOF] rt_intrp1linxf.c */
