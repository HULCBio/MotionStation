/*
 * fft_r2dif_tbls_z_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:41 $
 */

#include "dspfft_rt.h"

/*
 * In-place radix-2 decimation-in-frequency FFT (R2DIF)
 * Input is linear order, output is bit-reverse order
 * Table-based speed-optimized twiddle computation (TBLS)
 * Complex double-precision input (Z)
 *
 * twiddleTable is assumed to be in linear order, with 3N/4 elements
 *
 * twiddleTableBasisLen is not the actual length of twiddle table,
 * but rather, the FFT length N for which the twiddle table was constructed.
 * All twiddle tables are either length 3N/4 or N/4+1, depending on
 * the storage/memory efficiency setting.
 */
EXPORT_FCN void MWDSP_R2DIF_TBLS_Z(
    creal_T      *y,
    int_T         nChans,
    const int_T   nRows,
    const int_T   fftLen,
    const real_T *twiddleTable,
    const int_T   twiddleStep,
    const int_T   isInverse
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
                creal_T twid;

                twid.re = twiddleTable[tableIdx];
                twid.im = twiddleTable[tableIdx+nQrtr];
                if (isInverse) twid.im = -twid.im;
                tableIdx += k;

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

/* [EOF] fft_r2dif_tbls_z_rt.c */

