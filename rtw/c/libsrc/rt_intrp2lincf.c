/*
 * File : rt_intrp2lincf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   Linear 2-D interpolation of a column major table, 
 *   with clipping.  Interpolate the left column then 
 *   the right column, then between the two columns.
 *   
 */
real32_T rt_Intrp2LinCf(const int_T          bpIndex0,
			const int_T          bpIndex1,
			const real32_T 	   lambda0, 
			const real32_T 	   lambda1, 
			const real32_T * const tableData,
			const int_T          maxIndex0,
			const int_T          maxIndex1)
{
  const int_T numRows = maxIndex0 + 1;
  int_T  clipIdx0, clipIdx1;
  real32_T clipLambda0, clipLambda1;

  if (bpIndex0 < 0) {
    clipIdx0    = 0;
    clipLambda0 = 0.0F;
  } else if (bpIndex0 > (maxIndex0 - 1)) {
    clipIdx0    = (maxIndex0-1);
    clipLambda0 = 1.0F;
  } else {
    clipIdx0    = bpIndex0;
    clipLambda0 = ((lambda0 >= 1.0F) ? 1.0F : 
		   (lambda0 <= 0.0F ? 0.0F : lambda0));
  }

  if (bpIndex1 < 0) {
    clipIdx1    = 0;
    clipLambda1 = 0.0F;
  } else if (bpIndex1 > (maxIndex1 - 1)) {
    clipIdx1    = (maxIndex1 - 1);
    clipLambda1 = 1.0F;
  } else {
    clipIdx1    = bpIndex1;
    clipLambda1 = ((lambda1 >= 1.0F) ? 1.0F : 
		   (lambda1 <= 0.0F ? 0.0F : lambda1));
  }

  {
    const real32_T *yupper  = (const real32_T *)&tableData[clipIdx0 + numRows*clipIdx1];
    const real32_T *ylower  =  yupper + 1;
    const real32_T  yleft   = *yupper + clipLambda0 * (*ylower - (*yupper));
    
    yupper +=  numRows;
    ylower  =  yupper + 1;

    return(yleft + clipLambda1 * 
	   (((*yupper) + clipLambda0*((*ylower) - (*yupper))) - yleft));
  }
} /* [EOF] rt_intrp2lincf.c */
