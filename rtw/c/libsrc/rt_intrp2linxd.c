/*
 * File : rt_intrp2linxd.c generated from file
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
 *   with extrapolation.  Interpolate the left column
 *   the the right column, then between the two columns.
 *   
 */
real_T rt_Intrp2LinXd(const int_T          bpIndex0,
		      const int_T          bpIndex1,
                      const real_T 	   lambda0, 
                      const real_T 	   lambda1, 
                      const real_T * const tableData,
                      const int_T          maxIndex0,
                      const int_T          maxIndex1)
{
  const int_T numRows = maxIndex0 + 1;
  int_T  normIdx0, normIdx1;
  real_T normLambda0 = lambda0;
  real_T normLambda1 = lambda1;

  if (bpIndex0 < 0) {
    normIdx0 = 0;
    if (!(lambda0 < (real_T)(bpIndex0))) {
      normLambda0 = (real_T)bpIndex0;
    }
  } else if (bpIndex0 > (maxIndex0 - 1)) {
    normIdx0 = (maxIndex0-1);
    if (!(lambda0 > (real_T)(bpIndex0))) {
      normLambda0 = (real_T)(bpIndex0 - maxIndex0);
    }
  } else {
    normIdx0 = bpIndex0;
  }

  if (bpIndex1 < 0) {
    normIdx1 = 0;
    if (!(lambda1 < (real_T)(bpIndex1))) {
      normLambda1 = (real_T)bpIndex1;
    }
  } else if (bpIndex1 > (maxIndex1 - 1)) {
    normIdx1 = (maxIndex1 - 1);
    if (!(lambda1 > (real_T)(bpIndex1 - maxIndex1))) {
      normLambda1 = (real_T)(bpIndex1 - maxIndex1);
    }
  } else {
    normIdx1 = bpIndex1;
  }

  {
    const real_T *yupper  = (const real_T *)&tableData[normIdx0 + numRows*normIdx1];
    const real_T *ylower  =  yupper + 1;
    const real_T  yleft   = *yupper + normLambda0 * (*ylower - (*yupper));
    
    yupper +=  numRows;
    ylower  =  yupper + 1;

    return(yleft + normLambda1 * 
	   (((*yupper) + normLambda0*((*ylower) - (*yupper))) - yleft));
  }
} /* [EOF] rt_intrp2linxd.c */
