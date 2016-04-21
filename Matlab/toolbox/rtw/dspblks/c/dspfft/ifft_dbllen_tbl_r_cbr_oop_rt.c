/*
 * ifft_dbllen_tbl_r_cbr_oop_rt.c- Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:44:06 $
 */

#include "dspfft_rt.h"

/*
 * This program implements preprocessing so that a length N conjugate symmetric sequence
 * can be IFFT'ed with a length N/2 IFFT. The equations implemented herein are:
 *
 *  Fe(n) = x(n) + conj(x(N/2-n))
 *  Fo(n) = W(n) * (x(n) - conj(x(N/2-n)))
 *    where W(n) = exp(j*2*pi*n/N) and N is the original input sequence length.
 *  Then, the length N/2 sequence to be inverse transformed is given by
 *  y(n) = Fe(n) + j*Fo(n)
 *
 * Out-of-place version of preprocessing for dbl length IFFT.
 * Will only be used for one channel. Others will use dbl signal.
 * Assumes input is in order. Output is in length N/2 bit-reversed order.
 *
 * N > 1 (N2 >= 1) is guaranteed by the S-function.
 *
 */
EXPORT_FCN void MWDSP_Ifft_DblLen_TBL_R_Cbr_Oop(
    creal32_T       *y,
    const real32_T  *x,
    const int_T      fftLen,
    const real32_T  *twiddleTable,
    const int_T      twiddleStep
    )
{
    const int_T N2=fftLen>>1;
    const int_T N4=N2>>1;
    const int_T W4 = N4 * twiddleStep;

    /*
     * First point has no partner at N/2-i.
     * The i=0 point does not change location for bit reversed ordering
     */
    y[0].re = x[0] + x[N2];
    y[0].im = x[0] - x[N2];

    {
        real32_T  W_re, W_im, xsum, xdiff;
        if (N2 > 1) {
            /*
             * N2 >= 2
             * Handle point n=1 (which will go to location N4, once bit reversed
             * It is separate, because if N2 > 2, the partner for n=1 is n=N2-1
             * and the point at N2-1 cannot be handled in the loop below. The bit
             * reversed counter goes into an infinite loop.
             */
            W_re = twiddleTable[twiddleStep];
            W_im = twiddleTable[W4 - twiddleStep];

            xsum  = x[1] + x[N2 - 1];   /* X(n) + X(N2-n) */
            xdiff = x[1] - x[N2 - 1];   /* X(n) - X(N2-n) */

            /* y[n] = xsum + j*(W * xdiff) */
            y[N4].re =  xsum - W_im * xdiff;
            y[N4].im =  W_re * xdiff;

            if (N4 > 1) {
                /* N2 >= 4
                 *     Handle last point (n=N2-1) separately, which does not change
                 *     location for bit reversed ordering
                 *     Note that W(N2-n) = -conj(W(n)) where W(n) = exp(j*2*pi*n/N)
                 */
                y[N2-1].re =  xsum + W_im * xdiff;
                y[N2-1].im =  y[N4].im;

                /* Handle midpoint (n=N4) separately. It will have no partner in the loop below.
                 *     It goes to point 1 in bit reversed ordering.
                 */
                y[1].im =  0;
                y[1].re =  2 * x[N4];
            }
        }

        {
            int_T i, k;
            int_T jbr_f = N4 >> 1;    /* Initialize  forward moving bit reversed counter */
            int_T jbr_b = N4 - 1;     /* Initialize backward moving bit reversed counter */

            for (i=2, k=2*twiddleStep; i<N4; i++, k+=twiddleStep) {

                W_re = twiddleTable[k];
                W_im = twiddleTable[W4 - k];

                xsum  = x[i] + x[N2 - i];   /* X(n) + conj(X(N2-n)) */
                xdiff = x[i] - x[N2 - i];   /* X(n) - conj(X(N2-n)) */

                y[jbr_f].re  =  xsum - W_im * xdiff;  /* y(n) = xsum + j*W*xdiff */
                y[jbr_f].im  =  W_re * xdiff;         /* Compute output n and store bit reversed */

                y[jbr_b].im  =  y[jbr_f].im;          /* y(N2-n) = conj(xsum)+j*(-conj(W))*(-conj(xdiff)) */
                y[jbr_b].re  =  xsum + W_im * xdiff;  /* Compute output N2-n and store bit reversed */


                {   /* Increment forward moving bit reversed counter */
                    int_T bit = N2;  /* Output is half length */
                    do { bit>>=1; jbr_f^=bit; } while (!(jbr_f & bit));
                    /* Increment backward moving bit reversed counter */
                    bit = N2;
                    do { bit>>=1; jbr_b^=bit; } while (jbr_b & bit);
                }
            }
        }
    }
}
/* [EOF] ifft_dbllen_tbl_r_cbr_oop_rt.c */

