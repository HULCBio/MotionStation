/*
 *  upfir_df_dblbuf_rc_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:27 $
 *
 * Please refer to dspupfir_rt.h and upfir_df_dblbuf_dd_rt.c 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIR_DF_DblBuf_RC(
    const real32_T    *u,
          creal32_T   *out,
          real32_T    *tap0,
    const creal32_T   *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     eachOutBufSize
)
{
    creal32_T sum;    
    int_T   k   = numChans;
    int_T   curTapIdx = 0;
    int_T   j   = 0;
    sum.re      = 0.0F;
    sum.im      = 0.0F;     

    if(*wrtBuf) out += eachOutBufSize;

    do {
        int_T   i = inFrameSize;
        curTapIdx = *tapIdx;

        while (i--) {

            const creal32_T *cff = filter;
            int_T            m   = iFactor;
            real32_T        *mem = tap0 + curTapIdx; 
            *mem               = *u++;

            while (m--) {   

                for (j = 0; j <= curTapIdx; j++) {
                    sum.re += (*mem  ) * (cff->re);
                    sum.im += (*mem--) * (cff++->im);
                }
                mem += polyphaseFiltLen;
                while(j++ < polyphaseFiltLen) {
                    sum.re += (*mem  ) * (cff->re);
                    sum.im += (*mem--) * (cff++->im);
                }
                *out++ = sum;
                sum.re = 0.0F;
                sum.im = 0.0F;
            }

            if ( (++curTapIdx) >= polyphaseFiltLen ) curTapIdx = 0;

        }

        tap0 += polyphaseFiltLen;

    } while ((--k) > 0);

    *tapIdx = curTapIdx;
    *wrtBuf = (boolean_T)!(*wrtBuf);
}

/* [EOF] upfir_df_dblbuf_rc_rt.c */
