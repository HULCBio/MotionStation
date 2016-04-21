/*
 *  randsrcinitstate_gc_64_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.2.3 $ $Date: 2004/04/12 23:48:41 $
 */

#include "dsprandsrc64bit_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans   
 *  state:  35*nChans
 */

EXPORT_FCN void MWDSP_RandSrcInitState_GC_64(const uint32_T *seed,  /* seed value vector */
                                  real64_T       *state, /* state vectors */
                                  int_T          nChans) /* number channels */
{
    MWDSP_RandSrcInitState_U_64(seed, state, nChans);
}

/* [EOF] randsrcinitstate_gc_64_rt.c */
