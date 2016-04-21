/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_div_int32.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(INT32_T)
int32_T SaturateDivide_int32_T(int32_T a, int32_T b)
{

  if (b == 0) {
    if (a >= 0) {
      return (MAX_int32_T);
    } else {
      return (MIN_int32_T);
    }
  } else {
    if ((a == MIN_int32_T) && (b == -1)) {
      return (MAX_int32_T);
    } else {
      return (a/b);
    }
  }
}
#endif

/* [EOF] rt_sat_div_int32.c */
