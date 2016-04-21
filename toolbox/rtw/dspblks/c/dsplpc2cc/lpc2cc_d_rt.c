/*
 *  lpc2cc_d_rt.c - Linear Prediction Polynomial (LPC) to Cepstrum coefficient (CC)
 *  conversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:46:53 $
 */

#include "dsprc2lpc_rt.h"

EXPORT_FCN void MWDSP_Lpc2Cc_D(
        const real_T *lpc,     /* pointer to LP coefficients input port */
        real_T       *cc,      /* pointer to cepstrum coefficients output port*/
        const int_T   Np,      /* Order of LPC polynomial (Length - 1) */
        const int_T   Ncc      /* Length of output CC polynomial*/
       )
{
    int_T n, k, Nv;
    real_T sum;

    /* First Np values */
    cc[0] = 0.0;  /* Assuming the prediction error power is 1. */
    Nv = MIN(Np, Ncc);
    for (n = 1; n <= Nv; ++n) {
        sum = 0.0;
        for (k = 1; k < n; ++k)
          sum = sum - (n - k) * lpc[k] * cc[n-k];
        cc[n] = -lpc[n] + sum / n;
    }

    /* Remaining values (P(n) = 0 for n > Np) */
    for (n = Np+1; n < Ncc; ++n) {
        sum = 0.0;
        for (k = 1; k <= Np; ++k)
          sum = sum - (n - k) * lpc[k] * cc[n-k];
        cc[n] = sum / n;
    }    
}

/* [EOF] lpc2cc_d_rt.c */


