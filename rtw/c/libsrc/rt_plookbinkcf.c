/*
 * File : rt_plookbinkcf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"


/* Function: ===============================================
 * Abstract:
 *    Integrated index search function with clipping or 
 *    binary search algorithm to find index.
 */
int_T  rt_PLookBinKCf(const real32_T         u,
                      const real32_T * const bpData,
                      const int_T          maxIndex,
                      const int_T          index0)
{
  if (u <= bpData[0]) {
    return(0);
  } else if (u >= bpData[maxIndex]) {
    return(maxIndex);
  } else if (u < bpData[maxIndex-1]) {
    int_T bottom  = 0;
    int_T top     = maxIndex;
    int_T bpIndex = index0;

    for(;;) {
      if (u < bpData[bpIndex]) {
        top     = bpIndex - 1;
      } else if (u >= bpData[bpIndex+1]) {
        bottom  = bpIndex + 1;
      } else {
        return(bpIndex);
      }
      bpIndex = (bottom + top) >> 1;
    }
  } else {
    return(maxIndex-1);      
  }
} /* [EOF] rt_plookbinkcf.c */
