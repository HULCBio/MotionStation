/*
 * File : rt_intrp2lincd.c generated from file
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
real_T rt_Intrp2LinCd(const int_T          bpIndex0,
		      const int_T          bpIndex1,
                      const real_T 	   lambda0, 
                      const real_T 	   lambda1, 
                      const real_T * const tableData,
                      const int_T          maxIndex0,
                      const int_T          maxIndex1)
{
  const int_T numRows = maxIndex0 + 1;
  int_T  clipIdx0, clipIdx1;
  real_T clipLambda0, clipLambda1;

  if (bpIndex0 < 0) {
    clipIdx0    = 0;
    clipLambda0 = 0.0;
  } else if (bpIndex0 > (maxIndex0 - 1)) {
    clipIdx0    = (maxIndex0-1);
    clipLambda0 = 1.0;
  } else {
    clipIdx0    = bpIndex0;
    clipLambda0 = ((lambda0 >= 1.0) ? 1.0 : 
		   (lambda0 <= 0.0 ? 0.0 : lambda0));
  }

  if (bpIndex1 < 0) {
    clipIdx1    = 0;
    clipLambda1 = 0.0;
  } else if (bpIndex1 > (maxIndex1 - 1)) {
    clipIdx1    = (maxIndex1 - 1);
    clipLambda1 = 1.0;
  } else {
    clipIdx1    = bpIndex1;
    clipLambda1 = ((lambda1 >= 1.0) ? 1.0 : 
		   (lambda1 <= 0.0 ? 0.0 : lambda1));
  }

  {
    const real_T *yupper  = (const real_T *)&tableData[clipIdx0 + numRows*clipIdx1];
    const real_T *ylower  =  yupper + 1;
    const real_T  yleft   = *yupper + clipLambda0 * (*ylower - (*yupper));
    
    yupper +=  numRows;
    ylower  =  yupper + 1;

    return(yleft + clipLambda1 * 
	   (((*yupper) + clipLambda0*((*ylower) - (*yupper))) - yleft));
  }
} /* [EOF] rt_intrp2lincd.c */
