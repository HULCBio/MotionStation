/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_div_uint16.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT16_T)
uint16_T SaturateDivide_uint16_T(uint16_T a, uint16_T b)
{

  if (b == 0) {
    return (MAX_uint16_T);
  } else {
    return (a/b);
  }
}
#endif

/* [EOF] rt_sat_div_uint16.c */
