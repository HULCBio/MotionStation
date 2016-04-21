/*
 * fft_r2br_rc_oop_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:35 $
 */

#include "dspfft_rt.h"

/*
 * Out-of-place version of bit-reverse ordering
 * Real double-precision input, complex double-precision output
 */
EXPORT_FCN void MWDSP_R2BR_RC_OOP(
    creal32_T       *y,
    const  real32_T *x,
    int_T            nChans,
    const int_T      nRows,
    const int_T      fftLen
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
            y[j].re = x[i]; /* Copy element into bit-rev position */
            y[j].im = 0.0F; /* Set imaginary component to zero    */
            {
                int_T bit = fftLen;
                do { bit>>=1; j^=bit; } while (!(j & bit));
            }
        }
        y[j].re = x[i]; /* Copy final element */
        y[j].im = 0.0F;
        y += nRows;  /* Next channel */
        x += nRows;
    }
}

/* [EOF] fft_r2br_rc_oop_rt.c */
