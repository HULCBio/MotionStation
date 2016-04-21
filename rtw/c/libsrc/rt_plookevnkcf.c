/*
 * File: rt_plookevnkcf.c generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 *
 */

#include "rtlooksrc.h"



/* Function: ===============================================
 * Abstract:
 *    Integrated index search function with clipping
 *    for evenly spaced data.
 *
 */
int_T    rt_PLookEvnKCf(const real32_T         u,
                        const real32_T * const bpData,
                        const int_T          maxIndex)
{
  if (u <= bpData[0]) {
    return(0);
  } else if (u >= bpData[maxIndex]) {
    return(maxIndex);
  } else {
    return((int_T)((u - bpData[0]) / (bpData[1] - bpData[0])));
  }
} /* [EOF] rt_plookevnkcf.c */
