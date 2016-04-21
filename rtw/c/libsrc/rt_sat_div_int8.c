/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_div_int8.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(INT8_T)
int8_T SaturateDivide_int8_T(int8_T a, int8_T b)
{

  if (b == 0) {
    if (a >= 0) {
      return (MAX_int8_T);
    } else {
      return (MIN_int8_T);
    }
  } else {
    if ((a == MIN_int8_T) && (b == -1)) {
      return (MAX_int8_T);
    } else {
      return (a/b);
    }
  }
}
#endif

/* [EOF] rt_sat_div_int8.c */
