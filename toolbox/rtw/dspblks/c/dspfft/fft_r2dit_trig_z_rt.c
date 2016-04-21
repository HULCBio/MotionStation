/*
 * fft_r2dit_trig_z_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:49 $
 */

#include "dspfft_rt.h"

/*
 * In-place radix-2 decimation-in-time FFT (R2DIT)
 * Input is bit-reverse order, output is linear order
 * Trig-based twiddle computation (TRIG)
 * Complex double-precision input (Z)
 */
EXPORT_FCN void MWDSP_R2DIT_TRIG_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    )
{
    const int_T    n2 = fftLen>>1;
    const real_T e  = (real_T)DSP_TWO_PI / fftLen;

    while(nChans-- > 0) {
        /* First butterfly: */
        {
            int_T i;
            /* Note: use "i<fftLen-1" in order to prevent scalars
             *       from executing within the butterfly.
             */
            for(i=0; i<fftLen-1; i+=2) {
                real_T temp_re = y[i+1].re;
                real_T temp_im = y[i+1].im;
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
                    creal_T twid;
                    {
                        /* Compute conjugate twiddle */
                        const real_T theta = j * e;
                        twid.re = cos(theta);
                        twid.im = sin(theta);
                        if (!isInverse) twid.im = -twid.im;
                    }
                    for(i=0; i<k; i++) {
                        const int_T i2 = i1 + idelta;
                        real_T temp_re = CMULT_RE(twid, y[i2]);
                        real_T temp_im = CMULT_IM(twid, y[i2]);
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

/* [EOF] fft_r2dit_trig_z_rt.c */
