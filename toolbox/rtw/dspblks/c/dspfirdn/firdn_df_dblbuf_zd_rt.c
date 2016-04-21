/*
 *  firdn_df_dblbuf_zd_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:45:02 $
 *
 * Please refer to dspfirdn_rt.h and firdn_df_dblbuf_dd_rt.c 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIRDn_DF_DblBuf_ZD(
    const creal_T   *u,
          creal_T   *yout,
          creal_T   *tap0,
          creal_T   *sums,
    const real_T    *filter,
    const real_T   **cffPtr,
          int32_T     *tapIdx,
          int32_T     *outIdx,
          int32_T     *phaseIdx,
          boolean_T *wrtBuf,
    const int_T     filtLen,
    const int_T     numChans,
    const int_T     inFrameSize,
    const int_T     outFrameSize,
    const int_T     dFactor,
    const int_T     polyphaseFiltLen,
    const int_T     outElem
)
{
    int_T         curPhaseIdx  = *phaseIdx;
    int_T         curTapIdx    = *tapIdx;
    int_T         curOutBufIdx = *outIdx;
    boolean_T     curBuf       = *wrtBuf;
    const real_T *cff          = *cffPtr;
    int_T     i, k;

    for (k = 0; k < numChans; k++) {

        curBuf       = *wrtBuf;
        curPhaseIdx  = *phaseIdx;
        curTapIdx    = *tapIdx;
        curOutBufIdx = *outIdx;
        cff          = *cffPtr;

        i = inFrameSize;
        while (i--) {
            
            real_T   rsum    = sums->re;
            real_T   isum    = sums->im;

            creal_T *mem = tap0 + curTapIdx;
            int_T    j   = polyphaseFiltLen;
            *mem = *u++;   
            while (j--) {       
                rsum += (mem->re) * (*cff);
                isum += (mem->im) * (*cff++);
                if ((mem-=dFactor) < tap0) mem += filtLen;
            }
          
            sums->re = rsum;
            sums->im = isum;
            
            if ( (++curTapIdx) >= filtLen ) curTapIdx = 0;

            if ( (++curPhaseIdx) >= dFactor ) {

                creal_T *y = yout + curOutBufIdx;
                if (curBuf) y += outElem;
                
                *y++ = *sums;
                sums->re = sums->im = 0.0;
                
                if ( (++curOutBufIdx) >= outFrameSize ) {
                    curOutBufIdx = 0;
                    curBuf       = (boolean_T)!curBuf;
                }
                curPhaseIdx = 0;
                cff         = filter;
            }
        }

        ++sums;
        tap0 += filtLen;
        yout += outFrameSize;
    }

    *cffPtr   = cff;
    *phaseIdx = curPhaseIdx;
    *tapIdx   = curTapIdx;
    *outIdx   = curOutBufIdx;
    *wrtBuf   = curBuf;
}

/* [EOF] firdn_df_dblbuf_zd_rt.c */
