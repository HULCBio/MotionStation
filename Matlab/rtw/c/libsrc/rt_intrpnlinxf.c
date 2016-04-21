/*
 * File : rt_intrpnlinxf.c generated from file
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
 *   are in bpIndex and bpLambda.  Extrapolation is performed.
 *
 */
real32_T rt_IntrpNLinXf(int_T                     dim,
			int_T                     offset,
			const rt_LUTnWork * const TWork)
{
  int_T  addOff;
  real32_T lambda = ((real32_T *)TWork->bpLambda)[dim];

  /* Extrapolate normalized current dim to range */
  if (TWork->bpIndex[dim] < 0) {
    /* input bad, accomodate */
    addOff = 0;
    if (!(lambda < (real32_T)(TWork->bpIndex[dim]))) {
      lambda = (real32_T)TWork->bpIndex[dim];
    }
  } else if (TWork->bpIndex[dim] >= TWork->maxIndex[dim]) {
    /* input bad, accomodate */
    addOff = TWork->dimSizes[dim] * (TWork->maxIndex[dim] - 1);
    if (!(lambda > (real32_T)(TWork->bpIndex[dim]))) {
      lambda = (real32_T)(TWork->bpIndex[dim] - TWork->maxIndex[dim]);
    }
  } else {
    addOff = TWork->dimSizes[dim] * TWork->bpIndex[dim];
  }

  if ( dim > 0 ) {
    real32_T yLower, yUpper;

    yLower  = rt_IntrpNLinXf(dim-1, offset+addOff, TWork);
    addOff += TWork->dimSizes[dim];
    yUpper  = rt_IntrpNLinXf(dim-1, offset+addOff, TWork);
    return ( yLower + lambda * (yUpper-yLower) );
  } else {
    const real32_T * const tableItem = &(((real32_T *)TWork->tableData)
                                         [offset + TWork->bpIndex[0]]);
    return ( (*tableItem) + lambda * (tableItem[1]-(*tableItem)) );
  }
} /* [EOF] rt_intrpnlinxf.c */
