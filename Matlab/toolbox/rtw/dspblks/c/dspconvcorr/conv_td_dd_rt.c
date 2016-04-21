/*
 * conv_td_dd_rt.c - Signal Processing Blockset Convolution run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:42:29 $
 */

#include "dsp_rt.h"

/*
 * Time domain convolution of real double precision signals.
 */

EXPORT_FCN void MWDSP_Conv_TD_DD(
    const real_T  *inPtrA,
    int_T         nRowsA,
    boolean_T     multiChanA,
    const real_T  *inPtrB,
    int_T         nRowsB,
    boolean_T     multiChanB,
    real_T        *outPtr,
    int_T         nRowsY,
    int_T         nChansY
)
{
    int_T   i, c;

    for (c=0; c<nChansY; c++) {
        for (i = 0; i < nRowsY; i++) {
            const int_T j_end = MIN(i, nRowsB-1);
            real_T      sum   = 0.0;
            int_T       j;
                
            for (j = MAX(0, i-nRowsA+1); j <= j_end; j++) {
                sum += inPtrA[i-j] * inPtrB[j];
            }
            *outPtr++ = sum;
        }
        inPtrA += nRowsA * multiChanA;
        inPtrB += nRowsB * multiChanB;
    }
}

/* [EOF] conv_td_dd_rt.c */
