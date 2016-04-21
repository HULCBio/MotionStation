/*
 * File : rt_intrpnflatf.c generated from file
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
 *   are in bpIndex and bpLambda.
 *
 */
real32_T rt_IntrpNFlatf(int_T                     numDims,
			const rt_LUTnWork * const TWork)
{
  const real32_T   * const tableData = TWork->tableData;
  const int_T    * const dimSizes  = TWork->dimSizes;
  const real32_T   * const bpLambda  = TWork->bpLambda;
  int_T                  offset    = 0;
  int_T    k;

  for (k=0; k < numDims; k++) {
    int_T    addOff = TWork->bpIndex[k];
    if (bpLambda[k] >= 1.0F) addOff++;
    addOff *= dimSizes[k];
    offset += addOff;
  }
  return ( tableData[offset] );
} /* [EOF] rt_intrpnflatf.c */
