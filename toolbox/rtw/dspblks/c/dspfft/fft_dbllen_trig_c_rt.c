/*
 * fft_dbllen_trig_c_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:22 $
 */

#include "dspfft_rt.h"

/* 
 * In-place "double-length" data recovery (dblLenStage)
 * Trig-based twiddle computation (TRIG)
 * Complex single-precision data (C)
 *
 * Use to recover linear-ordered length-N point complex FFT result
 * from a linear-ordered complex length-N/2 point FFT, performed
 * on N interleaved real values.
 *
 * Only works on one-channel since this function is not as efficient
 * as the double-signal algorithm when applied to multiple real signals.
 */
EXPORT_FCN void MWDSP_DblLen_TRIG_C(
    creal32_T  *y,
    const int_T nRows
    )
{
    const int_T N2 = nRows >> 1; /* nRows/2 */
    const int_T N4 = N2 >> 1;    /* N2/2    */
    int_T i;

    if (nRows>2) {  /* Protect against short input sequences */
        y[N2+N4] =  y[N4];
        y[N4].im = -y[N4].im;
    }
    if (nRows>1) {  /* Protect against short input sequences */
        y[N2].re = y[0].re - y[0].im;
        y[N2].im = 0.0;
    }
    y[0].re += y[0].im;
    y[0].im  = 0.0;

    for (i = 1; i < N4; i++) {
        creal32_T c, d;
        {
            creal32_T a = y[i];
            creal32_T b = y[N2-i];
            c.re = (a.re + b.re) / 2;
            c.im = (a.im - b.im) / 2;
            d.re = (a.im + b.im) / 2;
            d.im = (b.re - a.re) / 2;
        }
        {
            creal32_T W;
            {
                /* Compute conjugate twiddle: */
                const real32_T theta = i * (real32_T)DSP_TWO_PI / nRows;
                W.re =  cosf(theta);
                W.im = -sinf(theta);
            }
            {
                /* Precompute W*d: */
                creal32_T ctemp;
                ctemp.re = CMULT_RE(W, d);
                ctemp.im = CMULT_IM(W, d);
    
                /* y[i] = c + W * d */
                y[i].re       = c.re + ctemp.re;
                y[i].im       = c.im + ctemp.im;
                y[nRows-i].re =  y[i].re;
                y[nRows-i].im = -y[i].im;
    
                /* y[N2 - i] = conj(c - W*d) */
                y[N2 - i].re =  c.re - ctemp.re;
                y[N2 - i].im = -c.im + ctemp.im;
                y[N2 + i].re =  y[N2 - i].re;
                y[N2 + i].im = -y[N2 - i].im;
            }
        }
    }
}

/* [EOF] fft_dbllen_trig_c_rt.c */
