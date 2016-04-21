/*
 * bsub_u_zd_z_rt.c - Signal Processing Blockset backward substitution run-time function 
 * This function solves UX = B where U is a upper triangular matrix
 * 
 * Specifications: 
 * 
 * - Double inputs and outputs, U - complex, B - real, X - complex
 * - Unit-upper matrix
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:02 $
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_BSub_U_ZD_Z(
        const creal_T *pU,
        const real_T  *pb,
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
        const creal_T *pUcol = pU;
        for(i=0; i<N; i++) {
            creal_T          *xj = x + k*N-1;
            creal_T            s = {0.0, 0.0};
            const creal_T *pUrow = pUcol--;

            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += U * xj */
                    s.re += CMULT_RE(*pUrow, *xj);
                    s.im += CMULT_IM(*pUrow, *xj);
                    xj--;
                    pUrow -= N;
                }
            }

            xj->re = (*pb) - s.re;
            xj->im = - s.im;
            pb--;
        }
    } while(--k);
}

/* [EOF] bsub_u_zd_z_rt.c */

