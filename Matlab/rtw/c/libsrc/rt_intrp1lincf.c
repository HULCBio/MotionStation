/*
 * File : rt_intrp1lincf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Linear 1-D interpolation of a table, with clipping.
 */
real32_T rt_Intrp1LinCf(const int_T    bpIndex,
			const real32_T   lambda,
			const real32_T * const tableData,
			const int_T    maxIndex)
{
  if (bpIndex < 0) {
    return(tableData[0]);
  } else if (bpIndex >= maxIndex) {
    return(tableData[maxIndex]);
  } else {
    return(tableData[bpIndex] + 
           ((lambda >= 1.0F) ? 1.0F : (lambda <= 0.0F ? 0.0F : lambda)) *
	   (tableData[bpIndex+1] - tableData[bpIndex]));
  }
    
} /* [EOF] rt_intrp1lincf.c */
