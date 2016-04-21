/*
 *  cc2lpc_d_rt.c - Cepstrum coefficient (CC) to Linear Prediction Polynomial (LPC) 
 *  conversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:46:51 $
 */

#include "dsplpc2cc_rt.h"

EXPORT_FCN void MWDSP_Cc2Lpc_D(
        const real_T  *cc,      /* pointer to the cepstrum coefficients input port */
        real_T        *lpc,     /* pointer to the LP coefficients output port */
        const int_T    Np       /* Order of LPC polynomial (length of LP coefficients - 1) */
       )
{
    int_T n, k;
    real_T sum;
    /* First LP coefficient is always 1. */
    lpc[0] = 1;
    for (n = 1; n <= Np; ++n) {
        sum = 0.0;
        for (k = 1; k < n; ++k)
          sum = sum - (n - k) * lpc[k] * cc[n-k];
        lpc[n] = -cc[n] + sum / n;
    }
}

/* [EOF] cc2lpc_d_rt.c */
