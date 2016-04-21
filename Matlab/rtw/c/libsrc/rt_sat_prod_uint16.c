/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_uint16.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT16_T)
uint16_T SaturateProduct_uint16_T(uint16_T a, uint16_T b)
{
  uint32_T tmp;

  tmp = (uint32_T) a * (uint32_T) b;
  if (tmp > (uint32_T) MAX_uint16_T) {
    return (MAX_uint16_T);
  } else {
    /*LINTED E_CAST_INT_TO_SMALL_INT*/
    return ( (uint16_T) tmp);
  }
}
#endif

/* [EOF] rt_sat_prod_uint16.c */
