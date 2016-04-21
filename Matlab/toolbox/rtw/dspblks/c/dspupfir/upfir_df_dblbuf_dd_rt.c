/*
 *  upfir_df_dblbuf_dd_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:25 $
 *
 * Please refer to dspupfir_rt.h 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIR_DF_DblBuf_DD(
    const real_T    *u,                 /* input port*/
          real_T    *out,               /* double length output buffer to hold filter output */
          real_T    *tap0,              /* points to input buffer start address per channel */
    const real_T    *filter,            /* FIR coeff */
          int32_T     *tapIdx,            /* points to input TapDelayBuffer location to read in u */
          boolean_T *wrtBuf,            /* determines which one of the two double buffer to store out */
    const int_T     numChans,           /* number of channels */
    const int_T     inFrameSize,        /* input frame size */
    const int_T     iFactor,            /* interpolation factor */
    const int_T     polyphaseFiltLen,   /* length of each polyphase filter */
    const int_T     eachOutBufSize      /* number of elements in each one of the double output buffer */
)
{
    /* initialize local variables to rid compiler warnings */
    int_T   k         = numChans;
    int_T   curTapIdx = 0;
    int_T   j         = 0;
    real_T  sum       = 0.0;         

    /* determines which one of the two output buffers to store filter results */
    if(*wrtBuf) out += eachOutBufSize;

    /* loop through k=numChans channels */
    do {
        int_T   i = inFrameSize;

        /* make per channel copy of tapIdx which is common to all channels */
        curTapIdx = *tapIdx;

        /* loop through inFrameSize samples in each input frame */
        while (i--) {

            int_T m = iFactor;

            /* make per sample copies of filter address and input tap delay buffer address 
               which are common to all input samples */
            const real_T *cff  = filter;
            real_T       *mem  = tap0 + curTapIdx; 

            /* read input sample into the tap delay buffer location pointed at by mem */
            *mem = *u++;

            /* loop through iFactor interpolation phases 
               output results to output buffer location pointed at by out */
            while (m--) {   

                /* perform direct form FIR filtering on the first curTapIdx taps 
                   of the TapDelayBuffer */
                for (j = 0; j <= curTapIdx; j++) {
                    sum += (*mem--) * (*cff++);
                }
                /* point mem to the last tap delay buffer location */
                mem += polyphaseFiltLen;
                /* perform direct form FIR filtering on the remaining taps */
                while(j++ < polyphaseFiltLen) {
                    sum += (*mem--) * (*cff++);
                }
                /* output sum to out and reset sum */
                *out++ = sum;
                sum    = 0.0;
            }

            /* increment circular buffer pointer : curTapIdx */
            if ( (++curTapIdx) >= polyphaseFiltLen ) curTapIdx = 0;

        } /* inFrameSize */

        /* increment tap0 for next channel */
        tap0 += polyphaseFiltLen;

    } while ((--k) > 0);

    /* Update stored indices for next function call */
    *tapIdx = curTapIdx;
    *wrtBuf = (boolean_T)!(*wrtBuf);            
}

/* [EOF] upfir_df_dblbuf_dd_rt.c */
