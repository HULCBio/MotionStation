/*
 * File : rt_intrpnflatcf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ==================================================
 * Abstract:
 *   n-D flat look-up operation for a column major table. 
 *   Index searches have already been performed and results
 *   are in bpIndex and bpLambda.  Clipping is performed.
 *
 */
real32_T rt_IntrpNFlatCf(int_T                     numDims,
			 const rt_LUTnWork * const TWork)
{
  const real32_T   * const tableData = TWork->tableData;
  const int_T    * const dimSizes  = TWork->dimSizes;
  const real32_T   * const bpLambda  = TWork->bpLambda;
  int_T                  offset    = 0;
  int_T    k;

  for (k=0; k < numDims; k++) {
    int_T    addOff = TWork->bpIndex[k];
    if (addOff < 0) {
      addOff = 0;
    } else if (addOff >= TWork->maxIndex[k]) {
      addOff = TWork->maxIndex[k];
    } else {
      if (bpLambda[k] >= 1.0F) addOff++;
    }
    addOff *= dimSizes[k];
    offset += addOff;
  }
  return ( tableData[offset] );
} /* [EOF] rt_intrpnflatcf.c */
