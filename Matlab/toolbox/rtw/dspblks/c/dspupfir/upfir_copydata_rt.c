/*
 *  upfir_copydata_rt.c - FIR Decimation block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:22 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_UpFIR_CopyDataToOutPort(
    const byte_T *outBufBase,                  
          byte_T *y,
          int32_T  *rdIdx,
    const int_T   outFrameSize,
    const int_T   numChans,
    const int_T   bytesPerElem,
    const int_T   bytesToCopy,
    const int_T   perChanOutBufElems,
    const int_T   perChanOutBufBytes,
    const int_T   outBufBaseOffsetInBytes,
    const int_T   rdIdxSpan
)
{
    int_T         k = numChans;
    const byte_T *out;
   
    /* calculate start address of Output Buffer for this function call */   
    if ( *rdIdx >= perChanOutBufElems ) outBufBase += outBufBaseOffsetInBytes;
    out    = outBufBase + (*rdIdx) * bytesPerElem;

    /* copy output buffer contents to output port per channel */
    while (k--) {
        memcpy(y, out, bytesToCopy);
        y   += bytesToCopy;
        out += perChanOutBufBytes;
    }
    /* update rdIdx */
    if ( (*rdIdx += outFrameSize) >= rdIdxSpan ) *rdIdx = 0;
}

/* [EOF] upfir_copydata_rt.c */
