/*
 *  rc2lpc_r_rt.c - Reflection coefficient (RC) and Linear Prediction Polynomial (LPC)
 *  interconversion block runtime helper function for single precision datatype. 
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:48:52 $
 */

#include "dsprc2lpc_rt.h"

EXPORT_FCN void MWDSP_Rc2Lpc_R(
        const real32_T *rc,   /* pointer to input port which contains the reflection coefficients */
        real32_T       *lpc,  /* pointer to output port holding the LP coefficients */
        const int_T     P     /* Order of LPC polynomial */
       )
{
  int_T   i, j, k;

  /* We are solving the following set of recursive equations to convert LPC to RC 
   *   LPC[P,m] = LPC[P-1,m] + RC[P-1]*LPC[P-1,P-m] for 1 <= m <= P
   *   LPC[P,P] = RC[P]
   * We start solving these equations from order 1 to P recursively, so as to finally
   * get the LPC polynomial of required order P. 
   */

  lpc[0] = 1.0F;
  for (k = 0; k < P; ++k) {
    lpc[k+1] = rc[k];
    for (i = 1, j = k ; i < j; ++i, --j) {
      real32_T temp = lpc[i] + rc[k] * lpc[j];
      lpc[j] = lpc[j] + rc[k] * lpc[i];
      lpc[i] = temp;
    }
    if (i == j) 
      lpc[i] = lpc[i] + rc[k] * lpc[i];
  }
}


/* [EOF] rc2lpc_r_rt.c */

