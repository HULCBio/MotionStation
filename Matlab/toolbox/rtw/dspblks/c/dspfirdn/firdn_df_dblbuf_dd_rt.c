/*
 *  firdn_df_dblbuf_dd_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:44:58 $
 *
 * Please refer to dspfirdn_rt.h and firdn_df_dblbuf_dd_rt.c 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIRDn_DF_DblBuf_DD(
    const real_T    *u,      
          real_T    *yout,             
          real_T    *tap0,              
          real_T    *sums,              
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
    /* initialize local variables to rid compiler warnings */
    int_T         curPhaseIdx  = *phaseIdx;
    int_T         curTapIdx    = *tapIdx;
    int_T         curOutBufIdx = *outIdx;
    boolean_T     curBuf       = *wrtBuf;
    const real_T *cff          = *cffPtr;
    int_T     i, k;

    /* Each channel uses the same filter phase but accesses
     * its own state memory and input. 
     */
    for (k = 0; k < numChans; k++) {

        /* make per channel copies of polyphase parameters common for
           all channels */
        curBuf       = *wrtBuf;
        curPhaseIdx  = *phaseIdx;
        curTapIdx    = *tapIdx;
        curOutBufIdx = *outIdx;
        cff          = *cffPtr;

        i = inFrameSize;
        while (i--) {
            
            /* filter current phase */
            real_T  *mem = tap0 + curTapIdx;
            int_T    j   = polyphaseFiltLen;
            
            /* read input into TapDelayBuffer */
            *mem = *u++;
            
            /* perform filtering on current phase */
            while (j--) {
                *sums += (*mem) * (*cff++);
                if ((mem-=dFactor) < tap0) mem += filtLen;
            }

            /* points to next TapDelayBuffer index
               (manages input circular TapDelayBuffer) */
            if ( (++curTapIdx) >= filtLen ) curTapIdx = 0;
       
            /* increment curPhaseIdx and 
             * output to OutputBuffer ONLY WHEN all polyphase filters are executed
             * i.e. curPhaseIdx = dFactor
             */
            if ( (++curPhaseIdx) >= dFactor ) {
                
                /* calculate appropriate location for filter output */
                real_T *y = yout + curOutBufIdx;
                
                /* manage ping-pong buffer */ 
                if (curBuf) y += outElem;
                
                /* save sums to location pointed to by y */
                *y++ = *sums;

                /* reset sums to zero after transfering its content */
                *sums = 0.0;
                
                /* increment circular buffer pointer curOutBufIdx 
                   (manage ping-pong buffer) */
                if ( (++curOutBufIdx) >= outFrameSize ) {
                    curOutBufIdx = 0;
                    curBuf       = (boolean_T)!curBuf;
                }
                /* reset curPhaseIdx to zero
                   reset cff to point to filter coefficients start address */
                curPhaseIdx = 0;
                cff         = filter;
            }

        } /* inFrameSize */

        /* increment indices for next channel */
        ++sums;
        tap0 += filtLen;
        yout += outFrameSize;
    } /* channel */
    
    /* save common per channel parameters for next function call */
    *cffPtr   = cff;
    *phaseIdx = curPhaseIdx;
    *tapIdx   = curTapIdx;
    *outIdx   = curOutBufIdx;
    *wrtBuf   = curBuf;
}

/* [EOF] firdn_df_dblbuf_dd_rt.c */
