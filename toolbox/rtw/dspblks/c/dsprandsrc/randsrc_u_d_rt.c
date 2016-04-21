/*
 *  randsrc_u_d_rt.c
 *  DSP Random Source Run-Time Library Helper Function
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $ $Date: 2004/04/12 23:48:35 $
 */

#include "dsprandsrc64bit_rt.h"
#include "dspendian_rt.h"
#include <math.h>

EXPORT_FCN void MWDSP_RandSrc_U_D(real64_T *y,     /* output signal */ 
                       const real64_T *min,   /* vector of mins */
                       int_T minLen,    /* length of min vector */
                       const real64_T *max,   /* vector of maxs */
                       int_T maxLen,    /* length of max vector */
                       real64_T *state, /* state vectors */
                       int_T nChans,    /* number of channels */
                       int_T nSamps)    /* number of samples per channel */
{
    union  { 
        real64_T dp; 
        struct {int32_T top; int32_T bot;} sp; 
    } r; 

    while (nChans--) {
        uint32_T i = ((uint32_T) state[33])&31;
        uint32_T j = (uint32_T) state[34];
        int_T samps = nSamps;
        real64_T scale = *max - *min;

        while (samps--) {
            /* "Subtract with borrow" generator */
            r.dp = state[(i+20)&31] - state[(i+5)&31] - state[32];
            if (r.dp >= 0) {
                state[32] = 0;
            } else {
                r.dp += 1.0;
                /* ldexp(1.,-53) = one in LSB */
                state[32] = ldexp(1.,-53);
            }
            state[i] = r.dp;
            i = (i+1)&31; /* compute (i+1) mod 32 */

            /* XOR with shift register sequence */
            if (isLittleEndian()) {
                r.sp.top ^= j;
                j ^= (j<<13); j ^= (j>>17); j ^= (j<<5); 
                r.sp.bot ^= (j&0x000fffff);
            } else {
                r.sp.bot ^= j;
                j ^= (j<<13); j ^= (j>>17); j ^= (j<<5); 
                r.sp.top ^= (j&0x000fffff);
            }
            *y++ = (*min) + scale*(r.dp);
        }
        /* record and advance state, min, max */
        state[33] = (real64_T) i;
        state[34] = (real64_T) j;
        state += 35;
        if (minLen > 1) min++;
        if (maxLen > 1) max++;
    } 
}

/* [EOF] randsrc_u_d_rt.c */
