/*
 * bsub_u_dz_z_rt.c - Signal Processing Blockset backward substitution run-time function 
 * This function solves UX = B where U is a upper triangular matrix
 * 
 * Specifications: 
 * 
 * - Double inputs and outputs, U - real, B - complex, X - complex
 * - Unit-upper matrix
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:42:59 $
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BSub_U_DZ_Z(
        const real_T  *pU,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        )
{
    int_T i;
    int_T k = P;

    pU += N*N - 1;
    pb += N*P - 1;

    do {
        const real_T *pUcol = pU;
        for(i=0; i<N; i++) {
            creal_T         *xj = x + k*N-1;
            creal_T           s = {0.0, 0.0};
            const real_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += U * xj */
                    s.re += *pUrow * xj->re;
                    s.im += *pUrow * (xj--)->im;
                    pUrow -= N;
                }
            }

            xj->re = pb->re - s.re;
            xj->im = pb->im - s.im;
            pb--;
        }
    } while(--k);
}

/* [EOF] bsub_u_dz_z_rt.c */

