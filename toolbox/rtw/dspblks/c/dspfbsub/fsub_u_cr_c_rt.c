/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_u_cr_c_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Complex Single input L, Real Single input B and Complex Single output
 * - Unit lower triangular 
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_U_CR_C(
        const creal32_T *pL,
        const real32_T  *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        )
{
    int_T         i, k;
    
    for(k=0; k<P; k++) {
        const creal32_T *pLcol = pL;                  /* Current RHS column */
        for(i=0; i<N; i++) {
            creal32_T       *xj    = x + k*N;
            creal32_T        s     = {0.0F, 0.0F};
            const creal32_T *pLrow = pLcol++;         /* access current row of L */
            
            {
                int_T j = i;
                while(j--) {
                    /* Compute: s += L * xj, in complex */
                    s.re += CMULT_RE(*pLrow, *xj);
                    s.im += CMULT_IM(*pLrow, *xj);
                    pLrow += N;
                    xj++;
                }
            }
            
            xj->re = *pb++ - s.re;
            xj->im = -s.im;
        }
    }
}

/* [EOF] fsub_u_cr_c_rt.c */

