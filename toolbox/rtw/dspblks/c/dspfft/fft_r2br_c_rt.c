/*
 * fft_r2br_c_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.6.2.3 $  $Date: 2004/04/12 23:43:33 $
 */

#include "dspfft_rt.h"

/* Optimizations to the basic bit reverse reordering:
 *
 *  1 - Skip i=0, since br(0)=0 and no value swap needs to occur
 *  2 - Similarly, skip i=N-1, since br(N-1)=N-1
 *  3 - Skip i=N-2 since br(N-2) <= N-2 for all N>2, and the
 *      value swap will not occur.  For N<=2, the i-loop does
 *      not execute, allowing us to effective reduce the loop.
 *  All told, these 3 items reduce the "standard" reordering by 3
 *  iterations, and yields a slight loop reduction ratio of (N-3)/N.
 *
 *  4 - Main bit-reverse computation loop uses logical operations
 *      instead of the more customary arithmetic operations.
 *      This may or may not be significant depending on the target
 *      architecture.  Note that most DSPs have bit-rev addressing
 *      modes, completely obviating the need for bit-rev software.
 *      Calls to R2BR may be removed, and appropriate bit-rev
 *      addressing code may be employed.
 */
EXPORT_FCN void MWDSP_R2BR_C(
    creal32_T  *y,
    int_T       nChans,
    const int_T nRows,
    const int_T fftLen
    )
{
    while(nChans-- > 0) {
        int_T j = fftLen>>1;
        int_T i;
        for (i = 1; i < fftLen-2; i++) {
            if (i < j) {
                /* Swap complex data values
                 * creal32_T t=y[j]; y[j]=y[i]; y[i]=t;
                 */
                real32_T t=y[j].re; y[j].re=y[i].re; y[i].re=t;
                         t=y[j].im; y[j].im=y[i].im; y[i].im=t;
            }
            {
                int_T bit=fftLen;
                do { bit>>=1; j^=bit; } while (!(j & bit));
            }
        }
        y += nRows;  /* Next channel */
    }
}

/* [EOF] fft_r2br_c_rt.c */
