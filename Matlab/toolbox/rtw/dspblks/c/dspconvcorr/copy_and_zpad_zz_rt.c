/*
 * copy_and_zpad_ZZ_rt.c - Signal Processing Blockset Convolution/Correlation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:42:37 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Copy_and_ZeroPad_ZZ(const creal_T *u, const int_T Nu, creal_T *y, const int_T Ny)
{
    int_T n=0;
    creal_T czero = {0.0, 0.0};

    while (n++ < Nu) *y++ = *u++;
    n--;
    while (n++ < Ny) *y++ = czero;
}

/* [EOF] copy_and_zpad_ZZ_rt.c */
