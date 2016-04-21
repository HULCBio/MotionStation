/*
 *  randsrccreateseeds_32_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:48:38 $
 */

#include "dsprandsrc32bit_rt.h"

/* Assumed lengths:
 *  seed:   nChans   
 *  state:  35*nChans
 */

EXPORT_FCN void MWDSP_RandSrcCreateSeeds_32(uint32_T  initSeed,
                                 uint32_T *seedArray,
                                 uint32_T  numSeeds)
{
    real32_T state[35];
    real32_T tmp;
    real32_T min = 0.0F;
    real32_T max = 1.0F;
    MWDSP_RandSrcInitState_U_32(&initSeed,state,1);
    while (numSeeds--) {
        MWDSP_RandSrc_U_R(&tmp,&min,1,&max,1,state,1,1);
        /* scale by 2^31 = 2147483328 */
        *seedArray++ = (uint32_T)(tmp*2147483328U);
    }
}

/* [EOF] randsrccreateseeds_32_rt.c */
