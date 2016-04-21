/*
 *  randsrcinitstate_u_64_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $ $Date: 2004/04/12 23:48:44 $
 */

#include "dsprandsrc64bit_rt.h"
#include <math.h>

/* Assumed lengths:
 *  seed:   nChans   
 *  state:  35*nChans
 */

EXPORT_FCN void MWDSP_RandSrcInitState_U_64(const uint32_T *seed,  /* seed value vector */
                                 real64_T       *state, /* state vectors */
                                 int_T          nChans) /* number of channels */
{
    uint32_T jzero = 0x80000000;
    uint32_T j;
    int_T    k,n;
    real64_T d;

    while (nChans--) {
        /*
         * Generate 32 floating point values, one bit at a time,
         * from 20-th bit of random shift register sequence.
         */
        /* need init seed to be != 0 */
        j = *seed ? *seed : jzero;
        k = 32;
        while (k--) {
            d = 0;
            n = 53;
            while (n--) {
                j ^= (j<<13); j ^= (j>>17); j ^= (j<<5); 
                d = d + d + (real64_T) ((j >> 19) & 1);
            }
            *state++ = ldexp(d,-53);
        }
        /* ulb = 0 */
        *state++ = 0.0;
        /* i = 0 */
        *state++ = 0.0;
        /* reset j to initial seed */
        j = (*seed ? *seed : jzero );
        *state++ = (real64_T)j;
        seed++;
    }
}

/* [EOF] randsrcinitstate_u_64_rt.c */
