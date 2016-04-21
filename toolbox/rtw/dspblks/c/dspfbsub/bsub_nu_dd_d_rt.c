/*
 * bsub_nu_dd_d_rt.c - Signal Processing Blockset backward substitution run-time function 
 * This function solves UX = B where U is a upper triangular matrix
 * 
 * Specifications: 
 * 
 * - Double real inputs and outputs
 * - Not unit-upper matrix
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:42:50 $
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BSub_NU_DD_D(
        const real_T *pU,
        const real_T *pb,
              real_T  *x,
        const int_T    N,
        const int_T    P
        )
{
    int_T i;
    int_T k = P;

    pU += N*N - 1;
    pb += N*P - 1;

    do {
        const real_T *pUcol = pU;
        for(i=0; i<N; i++) {
            real_T          *xj = x + k*N-1;
            real_T            s = 0.0;
            const real_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += U * xj */
                    s += *pUrow * *xj--;
                    pUrow -= N;
                }
            }

            *xj = (*pb-- - s) / *pUrow;
        }
    } while(--k);
}

/* [EOF] bsub_nu_dd_d_rt.c */
