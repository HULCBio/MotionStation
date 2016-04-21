/*
 * fft_interleave_d_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:30 $
 */

#include "dspfft_rt.h"

/*
 * For pairs of real signals:
 *   Interleave elements of adjacent real columns of data from matrix
 *   into a complex length nRows/2 matrix, by interleaving data elements.
 *   This operation allows pairs of real input signals to be transformed
 *   by a single complex FFT of the same length.
 * For a single real signal:
 *   Interleave successive real samples into the real and imag parts of
 *   a complex vector of half the real data length.  This operation allows
 *   a real length-N input to be transformed using a complex length-N/2 FFT.
 *
 * This operation could be performed in-place, since the real nRows-by-N matrix
 * has exactly the same number of elements as the complex nRows/2-by-N matrix,
 * etc, but Simulink will allocate the input and output spaces separately due
 * to the differing data complexity.
 */
EXPORT_FCN void MWDSP_FFTInterleave_D(
    creal_T      *y,
    const real_T *u,
    const int_T   nChans,
    const int_T   nRows
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
        memcpy(y, u, nRows * sizeof(real_T));
    }
}

/* [EOF] fft_interleave_d_rt.c */
