/*
 *  buf_output_scalar_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:49:04 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_OutputScalar(
          byte_T  *y,                  
          byte_T **outBufPtr,
          byte_T  *memBase,
    const int_T    nChans,
    const int_T    shiftPerElement,
    const int_T    bufLenTimesBpe
)
{
    const int_T bytesPerElement = (1 << shiftPerElement);
    byte_T     *outBuf;
    int_T       n = 0;
    
    do {
        const int_T nTimesBufLen = n * bufLenTimesBpe;
        byte_T     *topBuf       = memBase + nTimesBufLen;
        byte_T     *endBuf       = topBuf + bufLenTimesBpe;
        
        outBuf = *outBufPtr + nTimesBufLen;
        if (outBuf < topBuf) {
            outBuf += (endBuf - topBuf);
        }

        memcpy(y, outBuf, bytesPerElement);
        y += bytesPerElement;

        outBuf  = ( ((endBuf-outBuf) >> shiftPerElement) <= 1 )
                ? topBuf
                : (outBuf + bytesPerElement);

    } while ( (++n) < nChans );
    
    /* Update outBuf pointer relative to the first channel */
    *outBufPtr = outBuf - ((nChans-1)*bufLenTimesBpe);
}

/* [EOF] buf_output_scalar_rt.c */
