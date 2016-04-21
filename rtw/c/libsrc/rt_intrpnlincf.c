/*
 * File : rt_intrpnlincf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   n-D linear interpolation for a column major table. 
 *   Index searches have already been performed and results
 *   are in bpIndex and bpLambda.  Clipping is performed.
 *
 */
real32_T rt_IntrpNLinCf(int_T                     dim,
			int_T                     offset,
			const rt_LUTnWork * const TWork)
{
  int_T  addOff;
  real32_T lambda;

  /* Clip current dim to range */
  if (TWork->bpIndex[dim] < 0) {
    addOff = 0;
    lambda = 0.0F;
  } else if (TWork->bpIndex[dim] >= TWork->maxIndex[dim]) {
    addOff = TWork->dimSizes[dim] * (TWork->maxIndex[dim] - 1);
    lambda = 1.0F;
  } else {
    addOff = TWork->dimSizes[dim] * TWork->bpIndex[dim];
    lambda = ((real32_T *)TWork->bpLambda)[dim];
    lambda = ((lambda >= 1.0F) ? 1.0F : 
	      (lambda <= 0.0F ? 0.0F : lambda));
  }

  if ( dim > 0 ) {
    real32_T yLower, yUpper;

    yLower  = rt_IntrpNLinCf(dim-1, offset+addOff, TWork);
    addOff += TWork->dimSizes[dim];
    yUpper  = rt_IntrpNLinCf(dim-1, offset+addOff, TWork);
    return ( yLower + lambda * (yUpper-yLower) );
  } else {
    const real32_T * const tableItem = &(((real32_T *)TWork->tableData)
					 [offset + addOff]);
    return ( (*tableItem) + lambda * (tableItem[1]-(*tableItem)) );
  }
} /* [EOF] rt_intrpnlincf.c */
