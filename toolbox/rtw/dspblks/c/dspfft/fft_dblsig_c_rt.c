/*
 * fft_*_rt - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:26 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_DblSig_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows
    )
{
    const int_T N2 = nRows >> 1; /* nRows/2 */
    const int_T NN = nRows << 1; /* 2*nRows */
    nChans >>= 1;  /* Half the number of channels */

    while(nChans-- > 0) {
        int_T j;

        y[nRows].re = y[0].im;
        y[nRows].im = y[0].im = 0.0;

        for(j=1; j<=N2; j++) {
            creal32_T c, d;
            c.re = (y[j].re + y[nRows-j].re) / 2;
            c.im = (y[j].im - y[nRows-j].im) / 2;
            d.re = (y[j].im + y[nRows-j].im) / 2;
            d.im = (y[j].re - y[nRows-j].re) / 2;
            y[j]          =  c;
            y[nRows-j].re =  c.re;
            y[nRows-j].im = -c.im;
            y[nRows+j].re =  d.re;
            y[nRows+j].im = -d.im;
            y[NN-j]       =  d;
        }
        y += NN;  /* Next pair of channels */
    }
}

/* [EOF] */
