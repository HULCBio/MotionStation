/*
 *  lpc2cc_r_rt.c - Linear Prediction Polynomial (LPC) to Cepstrum coefficient (CC)
 *  conversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:46:54 $
 */

#include "dsprc2lpc_rt.h"

EXPORT_FCN void MWDSP_Lpc2Cc_R(
        const real32_T *lpc,     /* pointer to input port which points to LP coefficients */
        real32_T       *cc,      /* pointer to output port pointing to the cepstrum coefficients */
        const int_T     Np,      /* Order of LPC polynomial (Length - 1) */
        const int_T     Ncc      /* Length of output CC polynomial */
       )
{
    int_T n, k, Nv;
    real32_T sum;

    /* First Np values */
    cc[0] = 0.0F; /* Assuming that the prediction error power is unity. */
    Nv = MIN(Np, Ncc);
    for (n = 1; n <= Nv; ++n) {
        sum = 0.0F;
        for (k = 1; k < n; ++k)
          sum = sum - (n - k) * lpc[k] * cc[n-k];
        cc[n] = -lpc[n] + sum / n;
    }

    /* Remaining values (P(n) = 0 for n > Np) */
    for (n = Np + 1; n < Ncc; ++n) {
        sum = 0.0F;
        for (k = 1; k <= Np; ++k)
          sum = sum - (n - k) * lpc[k] * cc[n-k];
        cc[n] = sum / n;
    }    
}

/* [EOF] lpc2cc_r_rt.c */
