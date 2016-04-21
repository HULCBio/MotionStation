/*
 *  buf_output_scalar_1ch_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:49:03 $
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_OutputScalar_1ch(
          byte_T  *y,                  
          byte_T **outBufPtr,
          byte_T  *memBase,
    const int_T    shiftPerElement,
    const int_T    bufLenTimesBpe
)
{
    const int_T bytesPerElement = (1 << shiftPerElement);
    
    *outBufPtr = (byte_T *)( (*outBufPtr < memBase) ? (bufLenTimesBpe + *outBufPtr) : *outBufPtr );

    memcpy(y, *outBufPtr, bytesPerElement);

    *outBufPtr  = ( ((memBase + bufLenTimesBpe - *outBufPtr) >> shiftPerElement) <= 1 )
                ? memBase
                : (*outBufPtr + bytesPerElement);
}

/* [EOF] buf_output_scalar_1ch_rt.c */
