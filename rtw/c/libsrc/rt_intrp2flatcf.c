/*
 * File : rt_intrp2flatcf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Flat table look-up of a 2-D column major table, with
 *   clipping.
 *   
 */
real32_T rt_Intrp2FlatCf(const int_T          bpIndex0,
			 const int_T          bpIndex1,
			 const real32_T 	   lambda0, 
			 const real32_T 	   lambda1, 
			 const real32_T * const tableData,
			 const int_T          maxIndex0,
			 const int_T          maxIndex1)
{
  int_T offset = bpIndex1;

  if (bpIndex1 < 0) {
    offset = 0;
  } else if (bpIndex1 >= maxIndex1) {
    offset = maxIndex1;
  } else {
    if (lambda1 >= 1.0F) offset++;
  } 
  offset *= (maxIndex0 + 1);

  if (bpIndex0 >= 0) {
    if (bpIndex0 >= maxIndex0) {
      offset += maxIndex0;
    } else {
      offset += bpIndex0;
      if (lambda0 >= 1.0F) offset++;
    }
  }
  return(tableData[offset]);
} /* [EOF] rt_intrp2flatcf.c */
