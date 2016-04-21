/*
 * fft_r2dit_tbls_c_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:46 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_R2DIT_TBLS_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    )
{
    const int_T nHalf = (fftLen>>1) * twiddleStep;  /* N2=fftLen>>1 */
    const int_T nQrtr = nHalf >> 1;

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
            int_T idelta = 2;     /* =1 for all bflies         */
            int_T k = fftLen>>2;  /* =fftLen>>1 for all bflies */
            int_T kratio = k * twiddleStep;
            while(k>0) {
                int_T istart = 0;
                int_T j;

                for(j=0; j<nHalf; j+=kratio) {
                    int_T     i1 = istart;
                    int_T     i;
                    creal32_T twid;  /* conjugate twiddle */
                    twid.re = twiddleTable[j];
                    twid.im = twiddleTable[j+nQrtr];
                    if (isInverse) twid.im = -twid.im;

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
                k>>=1;
                kratio>>=1;
            }
        }
        y += nRows;  /* Next channel */
    }
}

/* [EOF] fft_r2dit_tbls_c_rt.c */
