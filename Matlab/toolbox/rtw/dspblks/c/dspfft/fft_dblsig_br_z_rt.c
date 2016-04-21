/*
 * fft_dblsig_br_z_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:25 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_DblSig_BR_Z(
    creal_T    *y,
    int_T       nChans,
    const int_T nRows
    )
{
    const int_T N2 = nRows >> 1; /* nRows/2 */
    const int_T NN = nRows << 1; /* 2*nRows */
    nChans >>= 1;  /* Half the number of channels */

    while(nChans-- > 0) {
        int_T j;
        int_T br_j  = 0;  /* br(j), init to br(0) = 0 */
        int_T br_Nj = 0;  /* br(N-j) */

        y[nRows].re = y[0].im;
        y[nRows].im = y[0].im = 0.0;

        for(j=1; j<=N2; j++) {
            /* Find next bit-reversed indices */
            {
                /* Forward bit-reversed counter: */
                int_T bit = nRows;
                do { bit>>=1; br_j ^=bit; } while(!(br_j & bit));

                /* Backward bit-reversed counter: */
                bit = nRows;
                do { bit>>=1; br_Nj^=bit; } while(br_Nj & bit);
            }
            {
                creal_T c, d;
                c.re = (y[br_j].re + y[br_Nj].re) / 2;
                c.im = (y[br_j].im - y[br_Nj].im) / 2;
                d.re = (y[br_j].im + y[br_Nj].im) / 2;
                d.im = (y[br_j].re - y[br_Nj].re) / 2;
                y[br_j]          =  c;
                y[br_Nj].re      =  c.re;
                y[br_Nj].im      = -c.im;
                y[nRows+br_j].re =  d.re;
                y[nRows+br_j].im = -d.im;
                y[nRows+br_Nj]   =  d;
            }
        }
        y += NN;  /* Next pair of channels */
    }
}

/* [EOF] fft_dblsig_br_z_rt.c */
