/* $Revision: 1.2.2.2 $ */
/*
 *  IIR_DF2T_A0SCALE_RR_RT.C - DSP filter runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision:
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2T_A0Scale_RR(const real32_T         *u,
                               real32_T               *y,
                               real32_T * const       mem_base,
                               const int_T            numDelays,
                               const int_T            sampsPerChan,
                               const int_T            numChans,
                               const real32_T * const tnum,
                               const int_T            ordNUM,
                               const real32_T * const tden,
                               const int_T            ordDEN,
                               const boolean_T        one_fpf)
{
    int_T j, k, lenMIN;
    lenMIN = MIN(ordNUM, ordDEN); /* for common state update loop */

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T i             = sampsPerChan;
        const real32_T *num = tnum;
        const real32_T *den = tden;  
        real32_T invA0;
        invA0 = 1 / *den;
        while (i--) {
            real32_T       in        = *u++;     /* Get next channel input sample */
            real32_T       *filt_mem = mem_base + k * numDelays; /* state memory for this channel */
            real32_T       *next_mem = filt_mem + 1;
            real32_T       out;

            if (one_fpf)
            {
                num = tnum;
                den = tden;
            }
            else invA0 = 1 / *den;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            *y++ = out = invA0 * (in * (*num++) + (*filt_mem));
            den++;
        
            /* Update states having both numerator and denominator coeffs
             *   D0[n+1] = D1[n] + x[n]*b1 - y[n]*a1
             *   D1[n+1] = D2[n] + x[n]*b2 - y[n]*a2
             *   ...
             */
            for (j=0; j < lenMIN; j++) *filt_mem++ = (*next_mem++) + in * (*num++) - out * (*den++);
            /* Update the rest of the states.  Note that
             * at most one of these two statements will execute
             */
            for ( ; j < ordNUM; j++) *filt_mem++ = (*next_mem++) + in  * (*num++);
            for ( ; j < ordDEN; j++) *filt_mem++ = (*next_mem++) - out * (*den++);
        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df2t_a0scale_rr_rt.c */

