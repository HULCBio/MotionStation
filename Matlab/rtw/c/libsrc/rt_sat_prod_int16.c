/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_int16.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(INT16_T)
int16_T SaturateProduct_int16_T(int16_T a, int16_T b)
{
  int32_T tmp;

  tmp = (int32_T) a * (int32_T) b;
  if (tmp > (int32_T) MAX_int16_T) {
    return (MAX_int16_T);
  } else if (tmp < (int32_T) MIN_int16_T) {
    return (MIN_int16_T);
  } else {
    /*LINTED E_CAST_INT_TO_SMALL_INT*/
    return ( (int16_T) tmp);
  }
}
#endif

/* [EOF] rt_sat_prod_int16.c */
