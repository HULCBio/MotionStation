/*
 *  randsrcinitstate_gz_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $ $Date: 2004/04/12 23:48:42 $
 */

#include "dsprandsrc_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans   
 *  state:  2*nChans
 */

EXPORT_FCN void MWDSP_RandSrcInitState_GZ(const uint32_T *seed,  /* seed value vector */
                                     uint32_T *state, /* state vectors */
                                     int_T    nChans) /* number of channels */
{
    while (nChans--) {
        *state++ = 362436069;
        *state++ = (*seed == 0) ? 521288629 : *seed;
        seed++;
    }
}

/* [EOF] randsrcinitstate_gz_rt.c */
