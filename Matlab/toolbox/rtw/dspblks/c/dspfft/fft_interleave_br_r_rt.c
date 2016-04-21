/*
 * fft_interleave_br_r_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.7.2.3 $  $Date: 2004/04/12 23:43:29 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_FFTInterleave_BR_R(
    creal32_T      *y,
    const real32_T *u,
    const int_T     nChans,
    const int_T     nRows
    )
{
    /*
     * Interleave for double real-signal algorithm
     */
    int_T i = nChans >> 1;  /* Loop over channel pairs */

    while(i--) {
        creal32_T *y_1   = y;
        int_T      br_j = 0;
        int_T      j    = nRows-1;

        while(j--) {
            /* Copy real element from this column to real part of output,
             * Copy real element from next column to imag part of output,
             * Bump input pointer to next real input in this column:
             */
            y_1->re = *u;
            y_1->im = *(u++ + nRows);

            /* Point y_1 to the next bit-reversed output sample index */
            {
                int_T bit = nRows;
                do { bit>>=1; br_j^=bit; } while (!(br_j & bit));
                y_1 = y + br_j;
            }
        }
        /* Copy last pair of real values into complex output element.
         *
         * Also, bump input pointer past the pair of input columns.
         * Since u was bumped to the end of the first col already,
         * just offset it by one additional column:
         */
        y_1->re = *u;
        u += nRows;
        y_1->im = *u++;

        /* Bump output pointer to start of next column pair of output matrix: */
        y += 2*nRows;
    }

    /* For an odd number of channels, prepare the last channel
     * for a double-length real signal algorithm.  No actual
     * interleaving is required, just a copy of the last column
     * of real data, but now placed in bit-rev order.
     * We need to cast the real u pointer to a creal_T pointer,
     * in order to fake the interleaving, and cut the number
     * of elements in half (half as many complex interleaved
     * elements as compared to real non-interleaved elements).
     */
    if (nChans & 0x01) {
        MWDSP_R2BR_C_OOP(y, (const creal32_T *)u, 1, nRows, nRows/2);
    }
}

/* [EOF] fft_interleave_br_r_rt.c */
