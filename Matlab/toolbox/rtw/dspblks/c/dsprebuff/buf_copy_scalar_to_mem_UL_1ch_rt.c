/*
 *  buf_copy_input_to_mem_UL_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:48:59 $
 *
 *  Note: this function only works for buffering scalar inputs
 *
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Buf_CopyScalar_UL_1ch(
    const byte_T   *u,                  
          byte_T  **inBufPtr,
          byte_T   *memBase,
    const int_T     shiftPerElement,
    const int_T     bufLenTimesBpe,
          int32_T  *ul_count,
    const int_T     N,
    const int_T     V
)
{
    const int_T bytesPerElement = (1 << shiftPerElement);

    /* increment underlap counter */
    ++(*ul_count);
    
    /* Skip this sample if negative overlap */
    if (((int_T)*ul_count) > N) {
        if (((int_T)*ul_count) == (N-V)) {
            *ul_count = 0;
        }
        return; /* Skip acquisition */
    }

    /* Copy F samples */ 
    memcpy(*inBufPtr, u, bytesPerElement);

    *inBufPtr = (((memBase + bufLenTimesBpe - *inBufPtr) >> shiftPerElement) > 1 )
              ? (*inBufPtr + bytesPerElement)
              : memBase;
}

/* [EOF] buf_copy_input_to_mem_UL_t.c */
