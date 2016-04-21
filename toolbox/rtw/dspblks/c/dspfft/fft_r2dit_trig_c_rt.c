/*
 * fft_r2dit_trig_c_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:48 $
 */

#include "dspfft_rt.h"

/*
 * In-place radix-2 decimation-in-time FFT (R2DIT)
 * Input is bit-reverse order, output is linear order
 * Trig-based twiddle computation (TRIG)
 * Complex single-precision input (C)
 */
EXPORT_FCN void MWDSP_R2DIT_TRIG_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    )
{
    const int_T    n2 = fftLen>>1;
    const real32_T e  = (real32_T)DSP_TWO_PI / (real32_T)fftLen;

    while(nChans-- > 0) {
        /* First butterfly: */
        {
            int_T i;
            /* Note: use "i<fftLen-1" in order to prevent scalars
             *       from executing within the butterfly.
             */
            for(i=0; i<fftLen-1; i+=2) {
                real32_T temp_re = y[i+1].re;
                real32_T temp_im = y[i+1].im;
                y[i+1].re = y[i].re - temp_re;
                y[i+1].im = y[i].im - temp_im;
                y[i].re += temp_re;
                y[i].im += temp_im;
            }
        }
        /* Remaining butterflies: */
        {
            int_T idelta = 2;               /* =1 for all bflies */
            int_T k;
            for(k=fftLen>>2; k>0; k>>=1) {  /* =fftLen>>1 for all bflies */
                int_T istart = 0;
                int_T j;

                for(j=0; j<n2; j+=k) {
                    int_T     i1 = istart;
                    int_T     i;
                    creal32_T twid;
                    {
                        /* Compute conjugate twiddle */
                        const real32_T theta = j * e;
                        twid.re = cosf(theta);
                        twid.im = sinf(theta);
                        if (!isInverse) twid.im = -twid.im;
                    }
                    for(i=0; i<k; i++) {
                        const int_T i2 = i1 + idelta;
                        real32_T temp_re = CMULT_RE(twid, y[i2]);
                        real32_T temp_im = CMULT_IM(twid, y[i2]);
                        y[i2].re = y[i1].re - temp_re;
                        y[i2].im = y[i1].im - temp_im;
                        y[i1].re += temp_re;
                        y[i1].im += temp_im;
                        i1 += (idelta << 1);
                    }
                    istart++;
                }
                idelta <<= 1;
            }
        }
        y += nRows;  /* Next channel */
    }
}

/* [EOF] fft_r2dit_trig_c_rt.c */
