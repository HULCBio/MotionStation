/*
 *  rc2lpc_d_rt.c - Reflection coefficient (RC) and Linear Prediction Polynomial (LPC)
 *  interconversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:48:51 $
 */

#include "dsprc2lpc_rt.h"

EXPORT_FCN void MWDSP_Rc2Lpc_D(
        const real_T *rc,       /* pointer to input port which contains the reflection coefficients */
        real_T       *lpc,      /* pointer to output port holding the LP coefficients */
        const int_T   P         /* Order of LPC polynomial */
       )
{
  int_T   i, j, k;

  /* We are solving the following set of recursive equations to convert LPC to RC 
   *   LPC[P,m] = LPC[P-1,m] + RC[P-1]*LPC[P-1,P-m] for 1 <= m <= P
   *   LPC[P,P] = RC[P]
   * We start solving these equations from order 1 to P recursively, so as to finally
   * get the LPC polynomial of required order P. 
   */

  lpc[0] = 1;  /* First LPC coefficient is equal to 1 */
  for (k = 0; k < P; ++k) {
    lpc[k+1] = rc[k];
    for (i = 1, j = k ; i < j; ++i, --j) {
      real_T temp = lpc[i] + rc[k] * lpc[j];
      lpc[j] = lpc[j] + rc[k] * lpc[i];
      lpc[i] = temp;
    }
    if (i == j) 
      lpc[i] = lpc[i] + rc[k] * lpc[i];
  }
}


/* [EOF] rc2lpc_d_rt.c */

