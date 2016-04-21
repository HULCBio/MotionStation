/*
 * bsub_u_rr_r_rt.c - Signal Processing Blockset backward substitution run-time function 
 * This function solves UX = B where U is a upper triangular matrix
 * 
 * Specifications: 
 * 
 * - Single real inputs and outputs
 * - unit-upper matrix
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:01 $
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BSub_U_RR_R(
        const real32_T *pU,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        )
{
    int_T i;
    int_T k = P;

    pU += N*N - 1;
    pb += N*P - 1;

    do {
        const real32_T *pUcol = pU;
        for(i=0; i<N; i++) {
            real32_T          *xj = x + k*N-1;
            real32_T            s = 0.0F;
            const real32_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += U * xj */
                    s += *pUrow * *xj--;
                    pUrow -= N;
                }
            }

            *xj = *pb-- - s;
        }
    } while(--k);
}

/* [EOF] bsub_u_rr_r_rt.c */

