/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_div_uint8.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT8_T)
uint8_T SaturateDivide_uint8_T(uint8_T a, uint8_T b)
{

  if (b == 0) {
    return (MAX_uint8_T);
  } else {
    return (a/b);
  }
}
#endif

/* [EOF] rt_sat_div_uint8.c */
