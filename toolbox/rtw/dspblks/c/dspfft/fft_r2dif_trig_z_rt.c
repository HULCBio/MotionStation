/*
 * fft_r2dif_trig_z_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:43 $
 */

#include "dspfft_rt.h"

/*
 * In-place radix-2 decimation-in-frequency FFT (R2DIF)
 * Input is linear order, output is bit-reverse order
 * Trig-based twiddle computation (TRIG)
 * Complex double-precision input (Z)
 */
EXPORT_FCN void MWDSP_R2DIF_TRIG_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen,
    const int_T isInverse
    )
{
    while(nChans-- > 0) {
        int_T n2 = fftLen;
        int_T k;
        for(k=fftLen>>2; k>0; k>>=1) {
            int_T n1 = n2;
            int_T j;
            n2>>=1;  /* n2/=2 */

            for (j = 0; j < n2; j++) {
                creal_T twid;
                int_T i;
                {
                    const real_T theta = j * (real_T)DSP_TWO_PI / n1;
                    twid.re = cos(theta);
                    twid.im = sin(theta);
                }
                if (!isInverse) twid.im = -twid.im; /* Conjugate twiddle */

                for (i = j; i < fftLen; i+=n1) {
		    const int_T q = i+n2;
                    creal_T t;
                    t.re = y[i].re - y[q].re;
                    t.im = y[i].im - y[q].im;
                    y[i].re += y[q].re;
                    y[i].im += y[q].im;
                    y[q].re = CMULT_RE(twid, t);
                    y[q].im = CMULT_IM(twid, t);
	        }
	    }
        }
        /* Last butterfly */
        {
            int_T i;
            /* Note: use "i<fftLen-1" in order to prevent scalars
             *       from executing within the butterfly.
             */
            for (i=0; i<fftLen-1; i+=2) {
                real_T t_re = y[i].re - y[i+1].re;
                real_T t_im = y[i].im - y[i+1].im;
                y[i].re += y[i+1].re;
                y[i].im += y[i+1].im;
                y[i+1].re = t_re;
                y[i+1].im = t_im;
	    }
        }
        y += nRows;  /* Next channel */
    }
}

/* [EOF] fft_r2dif_trig_z_rt.c */
