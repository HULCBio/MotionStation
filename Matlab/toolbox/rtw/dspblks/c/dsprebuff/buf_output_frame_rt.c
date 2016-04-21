/*
 *  buf_output_frame_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:49:02 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_OutputFrame(
          byte_T  *y,                  
          byte_T **outBufPtr,
          byte_T  *memBase,
    const int_T    nChans,
    const int_T    shiftPerElement,
    const int_T    bufLenTimesBpe,
    const int_T    N,
    const int_T    VTimesBpe
)
{
    byte_T *outBuf;
    int_T   n = 0;
    
    do {
        const int_T nTimesBufLen = n * bufLenTimesBpe;
        byte_T     *topBuf       = memBase + nTimesBufLen;
        byte_T     *endBuf       = topBuf + bufLenTimesBpe;
        
        /* Get the original output pointer relative to this channel
        * and back it up V samples: 
        */
        outBuf = *outBufPtr + nTimesBufLen;
        outBuf = (byte_T *)
                 ( ( (outBuf - VTimesBpe) < topBuf )
                   ? (endBuf - (topBuf - (outBuf-VTimesBpe)))
                   : (outBuf-VTimesBpe)
                 );

        /* Read N samples: */
        {
            const int_T nSampsAtBot = (endBuf-outBuf) >> shiftPerElement;
            int_T       nSamps = N;
            
            if ( nSampsAtBot <= N ) {
                /* Copy all samples left in buffer before wrapping pointer */
                const int_T bpeTimesNSampsAtBot = (nSampsAtBot << shiftPerElement);

                memcpy(y, outBuf, bpeTimesNSampsAtBot);
                y      += bpeTimesNSampsAtBot;

                /* Need to wrap pointer */
                outBuf  = topBuf;      /* Wrap outBuf to beginning of buffer*/
                nSamps -= nSampsAtBot; /* Left over samples to copy from top of buffer */
            }

            {
                const int_T bpeTimesNSamps = (nSamps << shiftPerElement);

                memcpy(y, outBuf, bpeTimesNSamps);
                y      += bpeTimesNSamps;
                outBuf += bpeTimesNSamps;
            }
        }
    } while ( (++n) < nChans );
    
    /* Update outBuf pointer relative to the first channel */
    *outBufPtr = outBuf - ((nChans-1)*bufLenTimesBpe);
}

/* [EOF] buf_output_frame_rt.c */
