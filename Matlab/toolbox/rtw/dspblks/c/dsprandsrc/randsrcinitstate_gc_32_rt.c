/*
 *  randsrcinitstate_gc_32_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.2.3 $ $Date: 2004/04/12 23:48:40 $
 */

#include "dsprandsrc32bit_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans   
 *  state:  35*nChans
 */

EXPORT_FCN void MWDSP_RandSrcInitState_GC_32(const uint32_T *seed,  /* seed value vector */
                                  real32_T       *state, /* state vectors */
                                  int_T          nChans) /* number channels */
{
    MWDSP_RandSrcInitState_U_32(seed, state, nChans);
}

/* [EOF] randsrcinitstate_gc_32_rt.c */
