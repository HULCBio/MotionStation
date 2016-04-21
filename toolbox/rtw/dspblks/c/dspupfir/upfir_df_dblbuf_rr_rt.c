/*
 *  upfir_df_dblbuf_rr_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:28 $
 *
 * Please refer to dspupfir_rt.h 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIR_DF_DblBuf_RR(
    const real32_T    *u,
          real32_T    *out,
          real32_T    *tap0,
    const real32_T    *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     eachOutBufSize
)
{
    int_T   k         = numChans;
    int_T   curTapIdx = 0;
    int_T   j         = 0;
    real32_T  sum       = 0.0F;         

    if(*wrtBuf) out += eachOutBufSize;

    do {

        int_T   i = inFrameSize;
        curTapIdx = *tapIdx;

        while (i--) {

            const real32_T *cff  = filter;
            int_T           m    = iFactor;
            real32_T       *mem  = tap0 + curTapIdx; 
            *mem               = *u++;

            while (m--) {   

                for (j = 0; j <= curTapIdx; j++) {
                    sum += (*mem--) * (*cff++);
                }
                mem += polyphaseFiltLen;
                while(j++ < polyphaseFiltLen) {
                    sum += (*mem--) * (*cff++);
                }
                *out++ = sum;
                sum    = 0.0F;
            }

            if ( (++curTapIdx) >= polyphaseFiltLen ) curTapIdx = 0;

        } /* inFrameSize */

        tap0 += polyphaseFiltLen;

    } while ((--k) > 0);
    /* Update stored indices */
    *tapIdx = curTapIdx;
    *wrtBuf = (boolean_T)!(*wrtBuf);            
}

/* [EOF] upfir_df_dblbuf_rr_rt.c */
