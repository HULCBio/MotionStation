/*
 * File : rt_intrp1lincd.c generated from file
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
real_T rt_Intrp1LinCd(const int_T    bpIndex,
                      const real_T   lambda,
                      const real_T * const tableData,
                      const int_T    maxIndex)
{
  if (bpIndex < 0) {
    return(tableData[0]);
  } else if (bpIndex >= maxIndex) {
    return(tableData[maxIndex]);
  } else {
    return(tableData[bpIndex] + 
           ((lambda >= 1.0) ? 1.0 : (lambda <= 0.0 ? 0.0 : lambda)) *
	   (tableData[bpIndex+1] - tableData[bpIndex]));
  }
    
} /* [EOF] rt_intrp1lincd.c */
