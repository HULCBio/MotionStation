/*
 *  randsrc_u_r_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:48:36 $
 */

#include "dsprandsrc32bit_rt.h"

/* SP_ULP = ldexp(1.0,-24); */
#define SP_ULP 0x33800000

EXPORT_FCN void MWDSP_RandSrc_U_R(real32_T *y,     /* output signal */ 
                       const real32_T *min,   /* vector of mins */
                       int_T minLen,    /* length of min vector */
                       const real32_T *max,   /* vector of maxs */
                       int_T maxLen,    /* length of max vector */
                       real32_T *state, /* state vectors */
                       int_T nChans,    /* number of channels */
                       int_T nSamps)    /* number of samples per channel */
{
    union  { 
        real32_T fp; /* floating-point representation */
        int32_T  ip; /* integer representation */
    } r; 
    uint32_T *ulpptr = (uint32_T*)&state[32];

    while (nChans--) {
        uint32_T i = ((uint32_T) state[33])&31;
        uint32_T j = (uint32_T) state[34];
        int_T samps = nSamps;
        real32_T scale = *max - *min;

        while (samps--) {
            /* "Subtract with borrow" generator */
            r.fp = state[(i+20)&31] - state[(i+5)&31] - state[32];
            if (r.fp >= 0.0F) {
                state[32] = 0.0F;
            } else {
                r.fp += 1.0F;
                *ulpptr = SP_ULP; /* 2^-24 */
            }
            state[i] = r.fp;
            i = (i+1)&31; /* compute (i+1) mod 32 */

            /* XOR with shift register sequence */
            j ^= (j<<13); j ^= (j>>17); j ^= (j<<5); 
            r.ip ^= (j&0x007fffff);
            *y++ = (*min) + scale*(r.fp);
        }
        /* record and advance state, min, max */
        state[33] = (real32_T) i;
        state[34] = (real32_T) j;
        state += 35;
        if (minLen > 1) min++;
        if (maxLen > 1) max++;
    } 
}

/* [EOF] randsrc_u_r_rt.c */
