/*
 * corr_td_zd_rt.c - Signal Processing Blockset Correlation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:42:44 $
 */

#include "dsp_rt.h"

/*
 * Time domain correlation of complex/real double precision signals.
 */

EXPORT_FCN void MWDSP_Corr_TD_ZD(
    const creal_T *inPtrA,
    int_T         nRowsA,
    boolean_T     multiChanA,
    const real_T  *inPtrB,
    int_T         nRowsB,
    boolean_T     multiChanB,
    creal_T       *outPtr,
    int_T         nRowsY,
    int_T         nChansY
)
{
    int_T   i, c;

    for (c=0; c<nChansY; c++) {
        for (i = 0; i < nRowsY; i++) {
            int_T B_offset = i - (nRowsB - 1);   /* Shift for leftmost nonzero output point */
            const int_T j_end = MIN(i, nRowsA-1);
            creal_T     sum   = {0.0, 0.0};
            int_T       j;
                
            for (j = MAX(0, B_offset); j <= j_end; j++) {
                sum.re += inPtrA[j].re * inPtrB[j-B_offset];
                sum.im += inPtrA[j].im * inPtrB[j-B_offset];
            }
            *outPtr++ = sum;
        }
        inPtrA += nRowsA * multiChanA;
        inPtrB += nRowsB * multiChanB;
    }
}

/* [EOF] corr_td_zd_rt.c */
