/*
 * File : rt_intrp2flatf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Flat table look-up of a 2-D column major table.
 *   
 */
real32_T rt_Intrp2Flatf(const int_T  * const bpIndex,
			const int_T          numRows,
			const real32_T * const lambda,
			const real32_T * const tableData)
{
  int_T offset = bpIndex[1];

  if (lambda[1] >= 1.0F) offset++;
  offset *= numRows;
  offset += bpIndex[0];
  if (lambda[0] >= 1.0F) offset++;

  return(tableData[offset]);
} /* [EOF] rt_intrp2flatf.c */
