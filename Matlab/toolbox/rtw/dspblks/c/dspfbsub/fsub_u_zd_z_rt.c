/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_u_zd_z_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Complex Double input L, Real Double input B and Complex Double output
 *  - Unit lower triangular
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_U_ZD_Z(
        const creal_T *pL,
        const real_T  *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        )
{
    int_T i, k;
    
    for(k=0; k<P; k++) {
        const creal_T *pLcol = pL;                  /* Current RHS column */
        for(i=0; i<N; i++) {
            creal_T       *xj    = x + k*N;
            creal_T        s     = {0.0, 0.0};
            const creal_T *pLrow = pLcol++;         /* access current row of L */
            
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

/* [EOF] fsub_u_zd_z_rt.c */

