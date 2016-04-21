/*
 *  buf_copy_input_to_output_rt.c - Buffer / Unbuffer block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.2 $  $Date: 2004/04/12 23:48:56 $
 *
 */
#include "dsp_rt.h"
EXPORT_FCN void MWDSP_Buf_CopyInputToOutput(
    const byte_T *u,
    byte_T       *y,
    int32_T      *cnt,
    const int_T   bytesPerElement,
    const int_T   nBytesToCopy,
    const int_T   F,
    const int_T   N,
    const int_T   nChans
)
{
    int32_T  c = *cnt; /* current input buffer index (ptr offset) */
    int_T    n;

    /* Block copy N input data to output for each channel */
    for (n=0; n<nChans; n++) {
        memcpy(y, ((const byte_T *)(u + bytesPerElement*(n*F + c))), nBytesToCopy);
        y += nBytesToCopy;
    }

    /* increment input buffer pointer 
     * resets input buffer pointer when finished copying input frame 
     */
    c += N;
    if (c == F) c = 0;
    *cnt = c;
}

/* [EOF] buf_copy_input_to_output_rt.c */
