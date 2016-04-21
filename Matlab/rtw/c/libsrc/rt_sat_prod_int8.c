/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_int8.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(INT8_T)
int8_T SaturateProduct_int8_T(int8_T a, int8_T b)
{
  int16_T tmp;

  tmp = (int16_T) a * (int16_T) b;
  if (tmp > (int16_T) MAX_int8_T) {
    return (MAX_int8_T);
  } else if (tmp < (int16_T) MIN_int8_T) {
    return (MIN_int8_T);
  } else {
    /*LINTED E_CAST_INT_TO_SMALL_INT*/
    return ( (int8_T) tmp);
  }
}
#endif

/* [EOF] rt_sat_prod_int8.c */
