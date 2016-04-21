/*
 *  lpc2rc_d_rt.c - Reflection coefficient (RC) and Linear Prediction Polynomial (LPC)
 *  interconversion block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:48:49 $
 */

#include "dsprc2lpc_rt.h"
EXPORT_FCN void MWDSP_Lpc2Rc_D(
        const real_T *lpc,     /* pointer to input port which points to LP coefficients */
        real_T       *rc,      /* pointer to output port pointing to the reflection coefficients */
        const int_T   P        /* Order of LPC polynomial */
       )
{
    real_T  *Pc;
    int_T i, j, k;
    /*
     * The iterative procedure generates the optimal predictors of order
     * P, P-1, ... , 1.  In order to preserve the input vector, the predictor
     * is copied into the output array to be subsequently altered.
     */
    Pc = rc;
    for (i = 0; i < P; ++i)
        Pc[i] = -lpc[i+1];        

    /* Main iteration loop */
    for (k = P-1; k >= 0; --k) {
        real_T E;
        rc[k] = -Pc[k];
        E     = 1.0 - rc[k] * rc[k];
        for (i = 0, j = k - 1; i < j; ++i, --j) {
            real_T temp = (Pc[i] - rc[k] * Pc[j]) / E;
            Pc[j] = (Pc[j] - rc[k] * Pc[i]) / E;
            Pc[i] = temp;
        }
        if (i == j)
            Pc[i] = (Pc[i] - rc[k] * Pc[i]) / E;
    }
}

/* [EOF] lpc2rc_d_rt.c */
