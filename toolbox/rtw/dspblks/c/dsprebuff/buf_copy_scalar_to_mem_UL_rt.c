/*
 *  buf_copy_input_to_mem_UL_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:49:00 $
 *
 *  Note: this function only works for buffering scalar inputs
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_CopyScalar_UL(
    const byte_T   *u,                  
          byte_T  **inBufPtr,
          byte_T   *memBase,
    const int_T     shiftPerElement,
    const int_T     bufLenTimesBpe,
    const int_T     nChans,
          int32_T  *ul_count,
    const int_T     N,
    const int_T     V
)
{
    const int_T bytesPerElement = (1 << shiftPerElement);
    byte_T     *inBuf;
    int_T       n = 0;

    /* increment underlap counter */
    ++(*ul_count);
    
    /* Skip this sample if negative overlap */
    if (((int_T)*ul_count) > N) {
        if (((int_T)*ul_count) == (N-V)) {
            *ul_count = 0;
        }
        return; /* Skip acquisition */
    }

    do {
        const int_T   nTimesBufLen = n * bufLenTimesBpe;
              byte_T *topBuf       = memBase + nTimesBufLen;

        /* Get the original input pointer relative to this channel */
        inBuf = *inBufPtr + nTimesBufLen;

        /* Copy F samples */ 
        memcpy(inBuf, u, bytesPerElement);
        u     +=   bytesPerElement;
        {
            const int_T nSampsAtBot = (topBuf + bufLenTimesBpe - inBuf) >> shiftPerElement;

            inBuf = (nSampsAtBot > 1)
                  ? (inBuf + bytesPerElement)
                  : topBuf;
        }

    } while ( (++n) < nChans );
    
    /* Update inBuf pointer relative to the first channel */
    *inBufPtr = inBuf - ((nChans-1)*bufLenTimesBpe);
}

/* [EOF] buf_copy_input_to_mem_UL_t.c */
