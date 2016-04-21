/*
 * File : rt_intrp1flatd.c generated from file
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
real_T rt_Intrp1Flatd(const int_T          bpIndex,
                      const real_T         lambda,
                      const real_T * const tableData)
{
  return(tableData[bpIndex + (int_T)(lambda >= 1.0)]);
} /* [EOF] rt_intrp1flatd.c */
