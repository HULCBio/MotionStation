/*
 * acf_fd_c_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:40:32 $
 */

#include "dspacf_rt.h"

/*
 * Frequency domain autocorrelation of a complex single precision signal.
 */

EXPORT_FCN void MWDSP_ACF_FD_C(
    const creal32_T *inPtr,
    int_T         inRows,
    creal32_T       *outPtr,
    int_T         outRows,
    int_T         outChans,
    int_T         N,
    creal32_T       *buff,
    const real32_T  *twid_tbl
)
{
    int_T n    = outChans * N, i;
    creal32_T *b = buff;
    real32_T   g = 1.0F / (real32_T)N;

    MWDSP_Copy_and_ZeroPad_CC_Nchan(inPtr, inRows, buff, N, outChans);
    MWDSP_R2DIF_TBLS_C(buff, outChans, N, N, twid_tbl, 1, 0);
    while (n--) {
        b->re = b->re * b->re + b->im * b->im;
        (b++)->im = 0.0F;
    }
    MWDSP_R2DIT_TBLS_C(buff, outChans, N, N, twid_tbl, 1, 1);

    n = outChans;
    while (n--) {
        for (i=0; i<outRows; i++) {
            outPtr->re = buff->re * g;
            (outPtr++)->im = (buff++)->im * g;
        }
        buff += (N - outRows);
    }
}
/* [EOF] acf_fd_c_rt.c */

