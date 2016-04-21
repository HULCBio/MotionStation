/*
 * File : rt_intrp1flatcf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Flat 1-D interpolation of a table, with clipping.
 */
real32_T rt_Intrp1FlatCf(const int_T          bpIndex,
			 const real32_T         lambda,
			 const real32_T * const tableData,
			 const int_T          maxIndex)
{
  if (bpIndex < 0) {
    return(tableData[0]);
  } else if (bpIndex >= maxIndex) {
    return(tableData[maxIndex]);
  } else {
    int_T idx = bpIndex + (int_T)(((int_T)lambda) > 0);
    return(tableData[idx]);
  }
} /* [EOF] rt_intrp1flatcf.c */
