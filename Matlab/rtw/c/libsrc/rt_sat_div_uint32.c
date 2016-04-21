/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_div_uint32.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT32_T)
uint32_T SaturateDivide_uint32_T(uint32_T a, uint32_T b)
{

  if (b == 0) {
    return (MAX_uint32_T);
  } else {
    return (a/b);
  }
}
#endif

/* [EOF] rt_sat_div_uint32.c */
