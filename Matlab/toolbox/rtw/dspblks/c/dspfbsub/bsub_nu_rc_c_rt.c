/*
 * bsub_nu_rc_c_rt.c - Signal Processing Blockset backward substitution run-time function 
 * This function solves UX = B where U is a upper triangular matrix
 * 
 * Specifications: 
 * 
 * - Single inputs and outputs, U - real, B - complex, X - complex
 * - Not unit-upper matrix
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:42:52 $
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BSub_NU_RC_C(
        const real32_T  *pU,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        )
{
    int_T i;
    int_T k = P;

    pU += N*N - 1;
    pb += N*P - 1;

    do {
        const real32_T *pUcol = pU;
        for(i=0; i<N; i++) {
            creal32_T         *xj = x + k*N-1;
            creal32_T           s = {0.0F, 0.0F};
            const real32_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += U * xj */
                    s.re += *pUrow * xj->re;
                    s.im += *pUrow * (xj--)->im;
                    pUrow -= N;
                }
            }
            {
                const creal32_T cb = *pb--;
                xj->re     = (cb.re - s.re) / *pUrow;
                xj->im = (cb.im - s.im) / *pUrow;
            }
        }
    } while(--k);
}

/* [EOF] bsub_nu_rc_c_rt.c */

