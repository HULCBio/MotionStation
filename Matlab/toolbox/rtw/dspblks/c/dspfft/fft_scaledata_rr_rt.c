/*
 * fft_scaledata_rr_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:43:53 $
 */

#include "dspfft_rt.h"


/*
 * Applies a real scaleFactor to every element
 * of an nRows x nChans matrix.
 * Example:
 *     MWDSP_ScaleData_RR(ptr, 64, 1.0F/32);
 */
EXPORT_FCN void MWDSP_ScaleData_RR(
    real32_T      *realData,
    int_T          cnt,
    const real32_T scaleFactor
    )
{
    while(cnt-- > 0) *(realData++) *= scaleFactor;
}

/* [EOF] fft_scaledata_rr_rt.c */
