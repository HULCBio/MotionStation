/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_nu_rc_c_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Real Single input L, Complex Single input B and Complex Single output
 * - Not unit lower triangular
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_NU_RC_C(
        const real32_T  *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        )
{
    int_T i, k;
    
    for(k=0; k<P; k++) {
        const real32_T  *pLcol = pL;                   /* Current RHS column */
        for(i=0; i<N; i++) {
            creal32_T         *xj = x + k*N;
            creal32_T           s = {0.0F, 0.0F};
            const real32_T *pLrow = pLcol++;           /* access current row of L */
            
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

/* [EOF] fsub_nu_rc_c_rt.c */
