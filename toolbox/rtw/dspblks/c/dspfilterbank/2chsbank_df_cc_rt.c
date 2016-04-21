/*
 *  2chsbank_df_cc_rt.c
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:44:26 $
 *
 * Please refer to dspfilterbank_rt.h 
 * for comments and algorithm explanation.
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_2ChSBank_DF_CC(
    const creal32_T        *inputToLongFilt, 
    const creal32_T        *inputToShortFilt, 
          creal32_T        *out,
          creal32_T        *longFiltTapBuf,
          creal32_T        *shortFiltTapBuf,              
    const creal32_T *const  longFilt,  
    const creal32_T *const  shortFilt,          
          int32_T          *longFiltTapIdx, 
          int32_T          *shortFiltTapIdx, 
    const int_T           numChans,
    const int_T           inFrameSize,          
    const int_T           polyphaseLongFiltLen,
    const int_T           polyphaseShortFiltLen
)
{
    const int_T iFactor = 2;

    /* initialize local variables to rid compiler warnings */
    int_T   k           = numChans;
    int_T   curTapLong  = 0;
    int_T   curTapShort = 0;
    int_T   jlong       = 0;
    int_T   jshort      = 0;
    creal32_T sum;
    sum.re = 0.0f;
    sum.im = 0.0f;         

    /* loop through k=numChans channels */
    do {
        int_T   i = inFrameSize;

        /* make per channel copy of long and short tap indices which are common to all channels */
        curTapLong  = *longFiltTapIdx;
        curTapShort = *shortFiltTapIdx;

        /* loop through inFrameSize samples in each input frame */
        while (i--) {

            int_T m = iFactor;

            /* make per sample copies of filter addresses and input tap delay buffer addresses 
               which are common to all input samples */
            const creal32_T *cffLong  = longFilt;
            const creal32_T *cffShort = shortFilt;
            creal32_T       *memLong  = longFiltTapBuf  + curTapLong; 
            creal32_T       *memShort = shortFiltTapBuf + curTapShort;

            /* read input sample into the tap delay buffer locations */
            *memLong  = *inputToLongFilt++;
            *memShort = *inputToShortFilt++;

            /* loop through iFactor interpolation phases 
               output results to output buffer location pointed at by out */
            while (m--) {   

                /* perform direct form FIR filtering on the first curTapLong taps 
                   of the Long Tap Delay Buffer (longFiltTapBuf) */
                for (jlong = 0; jlong <= curTapLong; jlong++) { 
                    sum.re += CMULT_RE(*memLong, *cffLong);
                    sum.im += CMULT_IM(*memLong, *cffLong);
                    --memLong;
                    ++cffLong;
                }
                /* perform direct form FIR filtering on the first curTapShort taps 
                   of the Short Tap Delay Buffer (shortFiltTapBuf) and add the
                   intermediate result to previous sum */
                for (jshort = 0; jshort <= curTapShort; jshort++) {
                    sum.re += CMULT_RE(*memShort, *cffShort);
                    sum.im += CMULT_IM(*memShort, *cffShort);
                    --memShort;
                    ++cffShort;
                }
                /* point memLong and memShort to the last tap delay buffer locations */
                memLong  += polyphaseLongFiltLen;
                memShort += polyphaseShortFiltLen;
                /* perform direct form FIR filtering on the remaining taps for the
                   long and short filters and add their results */
                while(jlong++ < polyphaseLongFiltLen) {
                    sum.re += CMULT_RE(*memLong, *cffLong);
                    sum.im += CMULT_IM(*memLong, *cffLong);
                    --memLong;
                    ++cffLong;
                }
                while(jshort++ < polyphaseShortFiltLen) {
                    sum.re += CMULT_RE(*memShort, *cffShort);
                    sum.im += CMULT_IM(*memShort, *cffShort);
                    --memShort;
                    ++cffShort;
                }
                /* output sum to out and reset sum */
                *out++ = sum;
                sum.re = 0.0f;
                sum.im = 0.0f;
            }

            /* increment circular buffer pointers : curTapLong and curTapShort */
            if ( (++curTapLong)  >= polyphaseLongFiltLen  ) curTapLong  = 0; 
            if ( (++curTapShort) >= polyphaseShortFiltLen ) curTapShort = 0; 

        } /* inFrameSize */

        /* increment for next channel */
        longFiltTapBuf  += polyphaseLongFiltLen;
        shortFiltTapBuf += polyphaseShortFiltLen;

    } while ((--k) > 0);

    /* Update stored indices for next function call */
    *longFiltTapIdx  = curTapLong;     
    *shortFiltTapIdx = curTapShort;  
}
/* [EOF] 2chabank_df_cc_rt.c */
