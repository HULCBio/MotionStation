/*
 *  buf_copy_scalar_input_to_mem_UL_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:48:58 $
 *
 *  Note: this function only works for buffering scalar inputs
 *
 */
#include "dsp_rt.h"
EXPORT_FCN void MWDSP_Buf_CopyScalar_OL(
    const byte_T        *u,                  
          byte_T       **inBufPtr,
          byte_T        *memBase,
    const int_T          shiftPerElement,
    const int_T          bufLenTimesBpe,
    const int_T          nChans
)
{
    const int_T bytesPerElement = (1 << shiftPerElement);
    byte_T     *inBuf;
    int_T       n = 0;

    do {
        const int_T nTimesBufLen = n * bufLenTimesBpe;

        /* Get the original input pointer relative to this channel */
        inBuf = *inBufPtr + nTimesBufLen;

        /* Copy input sample */ 
        memcpy(inBuf, u, bytesPerElement);
        u += bytesPerElement;
        {
            byte_T *topBuf = memBase + nTimesBufLen;
          
            inBuf = (((topBuf + bufLenTimesBpe - inBuf) >> shiftPerElement) > 1)
                  ? (inBuf + bytesPerElement)
                  : topBuf;
        }

    } while ( (++n) < nChans );
    
    /* Update inBuf pointer relative to the first channel */
    *inBufPtr = inBuf - ((nChans-1)*bufLenTimesBpe);
}

/* [EOF] buf_copy_scalar_input_to_mem_t.c */
