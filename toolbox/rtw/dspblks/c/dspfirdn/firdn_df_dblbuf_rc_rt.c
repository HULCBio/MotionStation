/*
 *  firdn_df_dblbuf_rc_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:45:00 $
 *
 * Please refer to dspfirdn_rt.h and firdn_df_dblbuf_dd_rt.c 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIRDn_DF_DblBuf_RC(
    const real32_T    *u,
          creal32_T   *yout,
          real32_T    *tap0,
          creal32_T   *sums,
    const creal32_T   *filter,
    const creal32_T  **cffPtr,
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
    const creal32_T *cff          = *cffPtr;
    int_T         i, k;

    for (k = 0; k < numChans; k++) {

        curBuf       = *wrtBuf;
        curPhaseIdx  = *phaseIdx;
        curTapIdx    = *tapIdx;
        curOutBufIdx = *outIdx;
        cff          = *cffPtr;

        i = inFrameSize;
        while (i--) {
            
            real32_T  rsum    = sums->re;
            real32_T  isum    = sums->im;

            real32_T  *mem = tap0 + curTapIdx;
            int_T    j   = polyphaseFiltLen;
            *mem = *u++;   
            while (j--) {       
                rsum += (*mem) * (*cff).re;
                isum += (*mem) * (*cff++).im;
                if ((mem-=dFactor) < tap0) mem += filtLen;
            }

            sums->re = rsum;
            sums->im = isum;
            
            if ( (++curTapIdx) >= filtLen ) curTapIdx = 0;

            if ( (++curPhaseIdx) >= dFactor ) {

                creal32_T *y = yout + curOutBufIdx;
                if (curBuf) y += outElem;
                
                *y++ = *sums;
                sums->re = sums->im = 0.0F;
                
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

    *cffPtr  = cff;
    *phaseIdx = curPhaseIdx;
    *tapIdx   = curTapIdx;
    *outIdx   = curOutBufIdx;
    *wrtBuf  = curBuf;
}

/* [EOF] firdn_df_dblbuf_rc_rt.c */
