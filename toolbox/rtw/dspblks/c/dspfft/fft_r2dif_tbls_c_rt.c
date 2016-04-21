/*
 * fft_r2dif_tbls_c_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:43:40 $
 */

#include "dspfft_rt.h"

EXPORT_FCN void MWDSP_R2DIF_TBLS_C(
    creal32_T      *y,
    int_T           nChans,
    const int_T     nRows,
    const int_T     fftLen,
    const real32_T *twiddleTable,
    const int_T     twiddleStep,
    const int_T     isInverse
    )
{
    const int_T nHalf = (fftLen >> 1) * twiddleStep;
    const int_T nQrtr = nHalf >> 1;

    while(nChans--) {
        int_T n2 = fftLen;
        int_T k;
        for(k=twiddleStep; k < nHalf; k<<=1) { /* skip last butterfly */
            int_T n1 = n2;
            int_T tableIdx  = 0;
            int_T j;
            n2>>=1;

            for (j = 0; j < n2; j++) {
                int_T   i;
                creal32_T twid;

                twid.re = twiddleTable[tableIdx];
                twid.im = twiddleTable[tableIdx+nQrtr];
                if (isInverse) twid.im = -twid.im;
                tableIdx += k;

                for (i = j; i < fftLen; i+=n1) {
		    const int_T q = i+n2;
                    creal32_T t;
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
                real32_T t_re = y[i].re - y[i+1].re;
                real32_T t_im = y[i].im - y[i+1].im;
                y[i].re += y[i+1].re;
                y[i].im += y[i+1].im;
                y[i+1].re = t_re;
                y[i+1].im = t_im;
	    }
        }
        y += nRows;  /* Next channel */
    }
}

/* [EOF] fft_r2dif_tbls_c_rt.c */
