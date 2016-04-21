/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_nu_dz_z_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Real Double input L, Complex Double input B and Complex Double output
 * - Not Unit lower triangular
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_NU_DZ_Z(
        const real_T  *pL,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        )
{
    int_T        i, k;
    
    for(k=0; k<P; k++) {
        const real_T  *pLcol = pL;                   /* Current RHS column */
        for(i=0; i<N; i++) {
            creal_T         *xj = x + k*N;
            creal_T           s = {0.0, 0.0};
            const real_T *pLrow = pLcol++;           /* access current row of L */
            
            {
                int_T j = i;
                while(j--) {
                    s.re  += *pLrow * xj->re;
                    s.im  += *pLrow * (xj++)->im;
                    pLrow += N;
                }
            }
            xj->re = (pb->re - s.re) / *pLrow;
            xj->im = (pb->im - s.im) / *pLrow;
            pb++;
        }
    }
}

/* [EOF] fsub_nu_dz_z_rt.c */
 
