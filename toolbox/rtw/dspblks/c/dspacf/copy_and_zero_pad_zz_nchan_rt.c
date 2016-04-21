/*
 * copy_and_zpad_zz_nchan_rt.c - Signal Processing Blockset AutoCorrelation run-time library components.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:43 $
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Copy_and_ZeroPad_ZZ_Nchan(const creal_T *u, const int_T Nu, creal_T *y, const int_T Ny, int_T Nchan)
{
    int_T n, c=Nchan;
    creal_T czero = {0.0, 0.0};

    while (c--) {
        n = 0;
        while (n++ < Nu) *y++ = *u++;
        n--;
        while (n++ < Ny) *y++ = czero;
    }
}

/* [EOF] copy_and_zpad_zz_nchan_rt.c */
