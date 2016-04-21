/*
 * fft_scaledata_dz_rt.c - Signal Processing Blockset FFT run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.3 $  $Date: 2004/04/12 23:43:51 $
 */

#include "dspfft_rt.h"

/*
 * Applies a real scaleFactor to every element
 * of an nRows x nChans matrix.
 * Example:
 *     MWDSP_ScaleData_DZ(ptr, 64, 1.0/32);
 */
EXPORT_FCN void MWDSP_ScaleData_DZ(
    creal_T     *cplxData,
    int_T        cnt,
    const real_T scaleFactor
    )
{
    real_T *realData = (real_T *)cplxData;
    cnt <<= 1; /* Twice as many real elements */
    while(cnt-- > 0) *(realData++) *= scaleFactor;
}

/* [EOF] fft_scaledata_dz_rt.c */
