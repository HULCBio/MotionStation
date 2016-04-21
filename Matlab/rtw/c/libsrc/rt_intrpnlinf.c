/*
 * File : rt_intrpnlinf.c generated from file
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
 *   are in bpIndex and bpLambda.
 *
 */
real32_T rt_IntrpNLinf(int_T                     dim,
		       int_T                     offset,
		       const rt_LUTnWork * const TWork)
{
  const real32_T * const bpLambda = TWork->bpLambda;

  if ( dim > 0 ) {
    int_T  addOff = TWork->dimSizes[dim] * TWork->bpIndex[dim];
    real32_T yLower, yUpper;

    yLower  = rt_IntrpNLinf(dim-1, offset+addOff, TWork);
    addOff += TWork->dimSizes[dim];
    yUpper  = rt_IntrpNLinf(dim-1, offset+addOff, TWork);
    return ( yLower + bpLambda[dim] * (yUpper-yLower) );
  } else {
    const real32_T * const tableItem = &(((real32_T *)TWork->tableData)
                                         [offset + TWork->bpIndex[0]]);
    return ( (*tableItem) + (*bpLambda) * (tableItem[1]-(*tableItem)) );
  }
} /* [EOF] rt_intrpnlinf.c */
