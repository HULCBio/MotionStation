/*
 * fft_scaledata_dd_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:43:50 $
 */

#include "dspfft_rt.h"

/*
 * Applies a real scaleFactor to every element
 * of an nRows x nChans matrix.
 * Example:
 *     MWDSP_ScaleData_DD(ptr, 64, 1.0/32);
 */
EXPORT_FCN void MWDSP_ScaleData_DD(
    real_T      *realData,
    int_T        cnt,
    const real_T scaleFactor
    )
{
    while(cnt-- > 0) *(realData++) *= scaleFactor;
}

/* [EOF] fft_scaledata_dd_rt.c */
