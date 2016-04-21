/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_uint32.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(UINT32_T)
uint32_T SaturateProduct_uint32_T(uint32_T a, uint32_T b)
{
  uint32_T aHi, aLo, bHi, bLo, cHi, cLo;
  uint32_T pHiHi, pHiLo, pLoHi, pLoLo;
  uint32_T carry;

  aHi = a >> 16;
  aLo = a & 0x0000FFFF;
  bHi = b >> 16;
  bLo = b & 0x0000FFFF;

  pHiHi = aHi * bHi;
  pHiLo = aHi * bLo;
  pLoHi = aLo * bHi;
  pLoLo = aLo * bLo;

  carry = 0;
  cLo = pLoLo + (pLoHi << 16);
  if (cLo < pLoLo) {
    carry++;
  }

  pLoLo = cLo;
  cLo += (pHiLo << 16);
  if (cLo < pLoLo) {
    carry++;
  }

  cHi = carry + pHiHi + (pLoHi >> 16) + (pHiLo >> 16);
  if (cHi != 0) {
    return (MAX_uint32_T);
  } else {
    return (a * b);
  }
}
#endif

/* [EOF] rt_sat_prod_uint32.c */
