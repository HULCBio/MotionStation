/*
 *  buf_copy_input_to_mem_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:48:54 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_CopyFrame_OL(
    const byte_T   *u,                  
          byte_T  **inBufPtr,
          byte_T   *memBase,
    const int_T     shiftPerElement,
    const int_T     bufLenTimesBpe,
    const int_T     nChans,
    const int_T     F
)
{
    byte_T *inBuf;
    int_T   n = 0;

    do {
        const int_T   nTimesBufLen = n * bufLenTimesBpe;
              byte_T *topBuf       = memBase + nTimesBufLen;
        const byte_T *endBuf       = topBuf  + bufLenTimesBpe;
        
        /* Get the original input pointer relative to this channel */
        inBuf = *inBufPtr + nTimesBufLen;
        
        /* Copy F samples (input frame length)
         *
         * Variables/naming:
         *   nSampsAtBot - number of samples at bottom (end) of the inBuf
         *   "bpe"       - "bytes per element"
         */
        {
            const int_T nSampsAtBot = (endBuf - inBuf) >> shiftPerElement;
            int_T       nSamps      = F;
            
            if ( nSampsAtBot <= nSamps) {
                const int_T bpeTimesNSampsAtBot = nSampsAtBot << shiftPerElement;

                memcpy(inBuf, u, bpeTimesNSampsAtBot);
                u += bpeTimesNSampsAtBot;

                /* Need to wrap inBuf pointer */
                inBuf   = topBuf;
                nSamps -= nSampsAtBot;
            }

            {
                const int_T bpeTimesNSamps = nSamps << shiftPerElement;
                memcpy(inBuf, u, bpeTimesNSamps);
                inBuf += bpeTimesNSamps;
                u     += bpeTimesNSamps;
            }
        }

    } while ( (++n) < nChans );
    
    /* Update inBufPtr pointer relative to the first channel */
    *inBufPtr = inBuf -((nChans-1)*bufLenTimesBpe);
}

/* [EOF] buf_copy_input_to_mem_rt.c */
