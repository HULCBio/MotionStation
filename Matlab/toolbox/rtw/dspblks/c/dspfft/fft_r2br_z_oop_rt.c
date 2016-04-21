/*
 * fft_r2br_z_oop_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:36 $
 */

#include "dspfft_rt.h"

/*
 * Out-of-place version of bit-reverse ordering
 */
EXPORT_FCN void MWDSP_R2BR_Z_OOP(
    creal_T       *y,
    const creal_T *x,
    int_T          nChans,
    const int_T    nRows,
    const int_T    fftLen
    )
{
    while(nChans-- > 0) {
        int_T j = 0;
        int_T i;
        /* Be careful not to use "i<fftLen" for loop condition.
         * Although this would appear to work fine, there is
         * one optimization that we would miss, and one bug that
         * would occur:
         * optimization: no need to execute the bit-rev generator
         *               prior to final loop exit, since the final
         *               value isn't used when i hits fftLen-1
         * bug: the bit-rev code used here will create an infinite
         *               loop when trying to compute br(N-1).
         */
        for (i=0; i<fftLen-1; i++) {
            y[j] = x[i]; /* Copy element into bit-rev position */
            {
                int_T bit = fftLen;
                do { bit>>=1; j^=bit; } while (!(j & bit));
            }
        }
        y[j] = x[i]; /* Copy final element */
        y += nRows;  /* Next channel */
        x += nRows;
    }
}

/* [EOF] fft_r2br_z_oop_rt.c */
