/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_sat_prod_int32.c     $Revision: 1.4 $
 *
 * Abstract:
 *      Real-Time Workshop support routines for saturation for
 *      integer multiplies and divides.
 *      
 */

#include "rtlibsrc.h"

#if defined(INT32_T)
int32_T SaturateProduct_int32_T(int32_T a, int32_T b)
{
  boolean_T negC;
  uint32_T aAbs = (uint32_T) a;
  uint32_T bAbs = (uint32_T) b;
  uint32_T aHi, aLo, bHi, bLo, cHi, cLo;
  uint32_T pHiHi, pHiLo, pLoHi, pLoLo;
  uint32_T carry;

  if (a < 0) {
    aAbs = -a;
  }

  if (b < 0) {
    bAbs = -b;
  }

  if ((a == 0) || (b == 0) || ((a > 0) == (b > 0))) {
    negC = 0;
  } else {
    negC = 1;
  }

  aHi = aAbs >> 16;
  aLo = aAbs & 0x0000FFFF;
  bHi = bAbs >> 16;
  bLo = bAbs & 0x0000FFFF;

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
  if (negC) {
    cHi = ~cHi;
    cLo = ~cLo;
    cLo++;
    if (!(cLo)) {
      cHi++;
    }
  }

  if(( ( (int32_T) cHi) > 0) || ((cHi == 0) && (cLo >= 0x80000000))) {
    return (MAX_int32_T);
  } else if (( ( (int32_T) cHi) < -1) || (( ( (int32_T) cHi) == -1) && (cLo <= 0x80000000))) {
    return (MIN_int32_T);
  } else {
    return (a * b);
  }
}
#endif

/* [EOF] rt_sat_prod_int32.c */
