/*
 * File : rt_plooklinkcf.c generated from file
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
 *    linear search algorithm.
 */
int_T    rt_PLookLinKCf(const real32_T         u,
                        const real32_T * const bpData,
                        const int_T          maxIndex,
                        const int_T          index0)
{
  if (u <= bpData[0]) {
    return(0);
  } else if (u >= bpData[maxIndex]) {
    return(maxIndex);
  } else {
    int_T bpIndex = index0;

    for(;;) {
      if (u < bpData[bpIndex]) {
        bpIndex--;
      } else if (u >= bpData[bpIndex+1]) {
        bpIndex++;
      } else {
        return(bpIndex);
      }
    }
  }
} /* [EOF] rt_plooklinkcf.c */
