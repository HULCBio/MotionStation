/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_nu_cc_c_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Complex Single precision inputs/outputs 
 * - Not unit lower triangular
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_NU_CC_C(
        const creal32_T *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        )
{
    int_T         i, k;
    
    for (k=0; k<P; k++) {
        const creal32_T *pLcol = pL;               /* Current RHS column */
        for(i=0; i<N; i++) {
            creal32_T       *xj    = x + k*N;
            creal32_T        s     = {0.0F, 0.0F};
            const creal32_T *pLrow = pLcol++;      /* access current row of L */
            
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

            {
                /* Complex divide: *xj = cdiff / *cLtemp */
                const creal32_T     cb = *pb++;
                const creal32_T cLtemp = *pLrow;
                creal32_T        cdiff;
                cdiff.re = cb.re - s.re;
                cdiff.im = cb.im - s.im;
            
                CDIV32(cdiff, cLtemp, *xj);
            }
        }
    }
}

/* [EOF] fsub_nu_cc_c_rt.c */
