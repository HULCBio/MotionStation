/*
 * File : rt_intrp1flatf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Flat 1-D interpolation of a table, including the 
 *   possibility of extrapolation based on index and values 
 *   interval fraction passed in.
 */
real32_T rt_Intrp1Flatf(const int_T          bpIndex,
			const real32_T         lambda,
			const real32_T * const tableData)
{
  return(tableData[bpIndex + (int_T)(lambda >= 1.0F)]);
} /* [EOF] rt_intrp1flatf.c */
