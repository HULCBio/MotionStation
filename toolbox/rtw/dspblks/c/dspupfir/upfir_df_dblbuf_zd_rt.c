/*
 *  upfir_df_dblbuf_zd_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:29 $
 *
 * Please refer to dspupfir_rt.h and upfir_df_dblbuf_dd_rt.c 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIR_DF_DblBuf_ZD(
    const creal_T   *u,
          creal_T   *out,
          creal_T   *tap0,
    const real_T    *filter,
          int32_T     *tapIdx,
          boolean_T *wrtBuf,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     iFactor,
    const int_T     polyphaseFiltLen,
    const int_T     eachOutBufSize
)
{
    creal_T sum;    
    int_T   k         = numChans;
    int_T   curTapIdx = 0;
    int_T   j         = 0;
    sum.re            = 0.0;
    sum.im            = 0.0;     

    if(*wrtBuf) out += eachOutBufSize;

    do {
        int_T   i = inFrameSize;
        curTapIdx = *tapIdx;

        while (i--) {

            const real_T *cff = filter;
            int_T         m   = iFactor;
            creal_T      *mem = tap0 + curTapIdx; 
            *mem              = *u++;

            while (m--) {   

                for (j = 0; j <= curTapIdx; j++) {
                    sum.re += (  mem->re    ) * (*cff  );
                    sum.im += ( (mem--)->im ) * (*cff++);
                }
                mem += polyphaseFiltLen;
                while(j++ < polyphaseFiltLen) {
                    sum.re += (  mem->re    ) * (*cff  );
                    sum.im += ( (mem--)->im ) * (*cff++);
                }
                *out++ = sum;
                sum.re = 0.0;
                sum.im = 0.0;
            }

            if ( (++curTapIdx) >= polyphaseFiltLen ) curTapIdx = 0;

        }

        tap0 += polyphaseFiltLen;

    } while ((--k) > 0);

    *tapIdx = curTapIdx;
    *wrtBuf = (boolean_T)!(*wrtBuf);
}

/* [EOF] upfir_df_dblbuf_zd_rt.c */
