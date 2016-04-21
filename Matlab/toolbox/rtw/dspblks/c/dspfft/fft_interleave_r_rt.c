/*
 * fft_interleave_r_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:43:31 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_FFTInterleave_R(
    creal32_T      *y,
    const real32_T *u,
    const int_T     nChans,
    const int_T     nRows
    )
{
    int_T i = nChans >> 1;  /* Loop over channel pairs */

    while(i--) {
        int_T j = nRows;
        while(j--) {
            /* Copy next input sample from first column of the
             * pair to the real part of the current output sample
             */
            y->re = *u;
            (y++)->im = *(u + nRows);
            u++;
        }
        /* Bump input pointer past the pair of input columns.
         * Since u was bumped to the end of the first col already,
         * just offset it by one additional column:
         */
        u += nRows;
        /*
         * Bump output pointer past next (complex) output column,
         * since that will be filled in by the double-signal algorithm.
         */
        y += nRows;
    }
    /* For an odd number of channels, prepare the last channel
     * for a double-length real signal algorithm.  No actual
     * interleaving is required, just a copy of the last column
     * of real data:
     */
    if (nChans & 0x01) {
        memcpy(y, u, nRows * sizeof(real32_T));
    }
}

/* [EOF] fft_interleave_r_rt.c */
