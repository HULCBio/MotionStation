/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_uint8.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT8_T)
uint8_T SaturateProduct_uint8_T(uint8_T a, uint8_T b)
{
  uint16_T tmp;

  tmp = (uint16_T) a * (uint16_T) b;
  if (tmp > (uint16_T) MAX_uint8_T) {
    return (MAX_uint8_T);
  } else {
    /*LINTED E_CAST_INT_TO_SMALL_INT*/
    return ( (uint8_T) tmp);
  }
}
#endif

/* [EOF] rt_sat_prod_uint8.c */
