/*
 * acf_fft_interleave_zpad_r_rt.c - Signal Processing Blockset ACF run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:37 $
 */

#include "dsp_rt.h"

/*
 * Identical to fft_interleave_r_rt.c except that this one allows for zero padding
 * at the end of each input channel
 */
EXPORT_FCN void MWDSP_ACF_FFTInterleave_ZPad_R(
    const real32_T *inPtr,
    int_T         inRows,
    creal32_T       *buff,
    int_T         N,
    int_T         nChans
    )
{
    int_T i = nChans >> 1;  /* Loop over channel pairs */
    creal32_T czero = {0.0F, 0.0F};

    while(i--) {
        int_T j = inRows;
        while(j--) {
            /* Copy next input sample from first column of the
             * pair to the real part of the current output sample
             */
            buff->re = *inPtr;
            (buff++)->im = *(inPtr + inRows);
            inPtr++;
        }
        /* Bump input pointer past the pair of input columns.
         * Since u was bumped to the end of the first col already,
         * just offset it by one additional column:
         */
        inPtr += inRows;

        j = (N - inRows);
        while (j--) {
            *buff++ = czero;
        }
        /*
         * Bump output pointer past next (complex) output column,
         * since that will be filled in by the double-signal algorithm.
         */
        buff += N;
    }
    /* For an odd number of channels, prepare the last channel
     * for a double-length real signal algorithm.  No actual
     * interleaving is required, just a copy of the last column
     * of real data:
     */
    if (nChans & 0x01) {
        real32_T *rbuff = (real32_T *)buff;
        int_T j = (N - inRows);

        memcpy(rbuff, inPtr, inRows * sizeof(real32_T));
        rbuff += inRows;
        while (j--) {
            *rbuff++ = 0.0F;
        }        
    }
}

/* [EOF] acf_fft_interleave_zpad_r_rt.c */
