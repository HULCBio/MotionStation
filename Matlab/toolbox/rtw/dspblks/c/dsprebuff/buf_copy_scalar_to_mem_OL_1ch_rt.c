/*
 *  buf_copy_scalar_input_to_mem_OL_1ch_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:48:57 $
 *
 *  Note: this function only works for buffering scalar inputs
 *
 */
#include "dsp_rt.h"
EXPORT_FCN void MWDSP_Buf_CopyScalar_OL_1ch(
    const byte_T        *u,                  
          byte_T       **inBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe
)
{
    /* Copy input sample */ 
    const int_T bytesPerElement = (1 << shiftPerElement);
    memcpy(*inBufPtr, u, bytesPerElement);

    *inBufPtr = (((memBase + bufLenTimesBpe - *inBufPtr) >> shiftPerElement) > 1)
              ? (*inBufPtr + bytesPerElement)
              : memBase;
}

/* [EOF] buf_copy_scalar_input_to_mem_OL_1ch_rt.c */
