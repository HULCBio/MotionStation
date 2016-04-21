/*
 * copy_and_zpad_CC_rt.c - Signal Processing Blockset Convolution/Correlation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:42:34 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Copy_and_ZeroPad_CC(const creal32_T *u, const int_T Nu, creal32_T *y, const int_T Ny)
{
    int_T n=0;
    creal32_T czero = {0.0F, 0.0F};

    while (n++ < Nu) *y++ = *u++;
    n--;
    while (n++ < Ny) *y++ = czero;
}

/* [EOF] copy_and_zpad_CC_rt.c */
