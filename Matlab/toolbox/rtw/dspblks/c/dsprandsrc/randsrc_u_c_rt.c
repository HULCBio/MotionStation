/*
 *  randsrc_u_c_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:48:34 $
 */

#include "dsprandsrc32bit_rt.h"

/* SP_ULP = ldexp(1.0,-24); */
#define SP_ULP 0x33800000

EXPORT_FCN void MWDSP_RandSrc_U_C(creal32_T *y,    /* output signal */ 
                       const real32_T *min,   /* vector of mins */
                       int_T minLen,    /* length of min vector */
                       const real32_T *max,   /* vector of maxs */
                       int_T maxLen,    /* length of max vector */
                       real32_T *state, /* state vectors */
                       int_T nChans,    /* number of channels */
                       int_T nSamps)    /* number of samples per channel */
{
    union  { 
        real32_T dp; 
        int32_T sp; 
    } r; 
    /* Treat real and imag parts as separate samples; that is,
     * samps = 2*nSamps, fill real and imag parts of output separately
     * Min and max vector elements apply to both parts.  For example,
     * min = 2, max = 6 defines the rectangle with lower left (2+2i) and
     * upper right (6+6i)
     */
    int_T newNSamps = 2*nSamps;
    real32_T *yPtr = (real32_T*)y;
    uint32_T *ulpptr = (uint32_T*)&state[32];

    while (nChans--) {
        uint32_T i = ((uint32_T)state[33])&31;
        uint32_T j = (uint32_T) state[34];
        int_T samps = newNSamps;
        real32_T scale = *max - *min;

        while (samps--) {
            /* "Subtract with borrow" generator */
            r.dp = state[(i+20)&31] - state[(i+5)&31] - state[32];
            if (r.dp >= 0) {
                state[32] = 0.0F;
            } else {
                r.dp += 1.0F;
                *ulpptr = SP_ULP; /* 2^-24 */
            }
            state[i] = r.dp;
            i = (i+1)&31; /* compute (i+1) mod 32 */

            /* XOR with shift register sequence */
            j ^= (j<<13); j ^= (j>>17); j ^= (j<<5); 
            r.sp ^= (j&0x007fffff);
            *yPtr++ = (*min) + scale*(r.dp);
        }
        /* record and advance state, min, max */
        state[33] = (real32_T) i;
        state[34] = (real32_T) j;
        state += 35;
        if (minLen > 1) min++;
        if (maxLen > 1) max++;
    } 
}

/* [EOF] randsrc_u_c_rt.c */
