/*
 *  buf_copy_input_to_mem_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:48:53 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_CopyFrame_OL_1ch(
    const byte_T   *u,                  
          byte_T  **inBufPtr,
          byte_T   *memBase,
    const int_T     shiftPerElement,
    const int_T     bufLenTimesBpe,
    const int_T     F
)
{
    /* Copy F samples (input frame length)
     *
     * Variables/naming:
     *   nSampsAtBot - number of samples at bottom (end) of the inBuf
     *   "bpe"       - "bytes per element"
     */
    byte_T       *topBuf      = memBase;
    const byte_T *endBuf      = topBuf + bufLenTimesBpe;
    const int_T   nSampsAtBot = (endBuf - *inBufPtr) >> shiftPerElement;
    int_T         nSamps      = F;
    
    if ( nSampsAtBot <= nSamps) {
        const int_T bpeTimesNSampsAtBot = nSampsAtBot << shiftPerElement;

        memcpy(*inBufPtr, u, bpeTimesNSampsAtBot);
        u += bpeTimesNSampsAtBot;

        /* Need to wrap inBuf pointer */
        *inBufPtr = topBuf;
        nSamps   -= nSampsAtBot;
    }

    {
        const int_T bpeTimesNSamps = nSamps << shiftPerElement;
        memcpy(*inBufPtr, u, bpeTimesNSamps);
        *inBufPtr += bpeTimesNSamps;
    }
}

/* [EOF] buf_copy_input_to_mem_rt.c */
