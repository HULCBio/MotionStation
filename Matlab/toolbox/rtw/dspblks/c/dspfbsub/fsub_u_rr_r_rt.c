/* $Revision: 1.4.2.3 $ */
/* 
 * fsub_u_rr_r_rt - Signal Processing Blockset forward substitution run-time function 
 * This function solves LX = B where L is a lower triangular matrix
 * 
 * Specifications: 
 * 
 * - Real Single precision inputs/outputs 
 * - Unit lower triangular
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FSub_U_RR_R(
        const real32_T *pL,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        )
{
    int_T i, k;
    
    for(k=0; k<P; k++) {
        const real32_T  *pLcol = pL;                  /* Current RHS column */
        for(i=0; i<N; i++) {
            real32_T          *xj = x + k*N;
            real32_T            s = 0.0F;
            const real32_T *pLrow = pLcol++;          /* access current row of L */
            
            {
                int_T j = i;
                while(j--) {
                    s += *pLrow * *xj++;
                    pLrow += N;
                }
            }
            
            *xj = *pb++ - s;
        }
    }
}

/* [EOF] fsub_u_rr_r_rt.c */

