/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_look1d32.c    $Revision: 1.4 $	$Date: 2002/04/14 10:17:13 $
 *
 * Abstract:
 *      Real-Time Workshop index finding routine used in the code
 *      generated from SL models involving 1D Lookup Table
 *      blocks for type single.
 */

#include "rtlibsrc.h"

real32_T rt_Lookup32(const real32_T *x, int_T xlen, real32_T u,
                     const real32_T *y)
{
  int_T idx = rt_GetLookupIndex32(x, xlen, u);
  real32_T num = y[idx+1] - y[idx];
  real32_T den = x[idx+1] - x[idx];
  
  /* Due to the way the binary search is implemented
     in rt_look.c (rt_GetLookupIndex), den cannot be
     0.  Equivalently, m cannot be inf or nan. */
  
  real32_T m = num/den;

  return (y[idx] + m * (u - x[idx]));
}

