/*
 * acf_fd_r_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:40:34 $
 */

#include "dspacf_rt.h"

/*
 * Frequency domain autocorrelation of a real single precision signal.
 */

EXPORT_FCN void MWDSP_ACF_FD_R(
    const real32_T *inPtr,
    int_T           inRows,
    real32_T       *outPtr,
    int_T           outRows,
    int_T           outChans,
    int_T           N,
    creal32_T      *buff,
    const real32_T *twid_tbl
)
{
    int_T n    = outChans * N, i;
    creal32_T *b = buff;
    real32_T   g = 1.0F / (real32_T)N;

    MWDSP_ACF_FFTInterleave_ZPad_R(inPtr, inRows, buff, N, outChans);
    if (outChans > 1) {
        /* Double-signal algorithm
         *
         * This algorithm handles all pairs of data columns.
         * Any remaining "odd column" will be handled by the double-length
         *   algorithm below.
         *
         * FFT will skip over odd output channels, since the corresponding
         * input data has been interleaved into the even complex channels.
         * To do this, we tell a "small white lie" (well, not really!)
         * We say that there are half as many channels to process (which is true),
         * and we say that the column stride length is twice as long as the FFT
         * (which is also true).  The FFT computation is not twice as long, however,
         * and hence the last argument (the "fftLen" arg) is just nRows, as usual.
         */
        MWDSP_R2DIF_TBLS_C(buff, outChans/2, N*2, N, twid_tbl, 1, 0);
        MWDSP_DblSig_BR_C( buff, outChans,   N);
    }
    /*
     * The following conditional always executes for an odd number of channels,
     * even if the above conditional executes.  That is entirely expected and correct.
     */
    if (outChans & 0x01) {
        /* Double-length algorithm for last channel
         * Compute one half-length FFT on last channel
         */
        creal32_T *lastCol = buff + (N * (outChans - 1));
        MWDSP_R2DIF_TBLS_C(    lastCol, 1, N, N/2, twid_tbl, 2, 0);
        MWDSP_R2BR_C(       lastCol, 1, N, N/2);
        MWDSP_DblLen_TBL_C( lastCol,    N, twid_tbl, 1);
        MWDSP_R2BR_C(       lastCol, 1, N, N);
    }

    while (n--) {
        b->re = g * (b->re * b->re + b->im * b->im);
        (b++)->im = 0.0F;
    }
    MWDSP_R2DIT_TBLS_C(buff, outChans, N, N, twid_tbl, 1, 1);

    n = outChans;
    while (n--) {
        for (i=0; i<outRows; i++) {
            *outPtr++ = (buff++)->re;
        }
        buff += (N - outRows);
    }        
}
/* [EOF] acf_fd_r_rt.c */
