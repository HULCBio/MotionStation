/*
 *  IIR_DF1T_A0SCALE_RR_RT.C - DSP filter runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:45:42 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1T_A0Scale_RR( const real32_T         *u,
                         real32_T               *y,
                         real32_T * const       mem_base,
                         const int_T          numDelays,
                         const int_T          sampsPerChan,
                         const int_T          numChans,
                         const real32_T * const tnum,
                         const int_T          ordNUM,
                         const real32_T * const tden,
                         const int_T          ordDEN,
                         const boolean_T      one_fpf)
{
    int_T j, k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T i           = sampsPerChan;
        const real32_T *num = tnum;
        const real32_T *den = tden;  
        real32_T invA0      = 1/(*den);
        while (i--) {
            real32_T       in        = *u++;     /* Get next channel input sample */
            real32_T       sum;
            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            real32_T       *filt_mem_num = mem_base + k * numDelays; /* state memory for this channel */
            real32_T       *filt_mem_den = filt_mem_num + ordNUM +1;
            real32_T       *next_mem_num = filt_mem_num + 1;
            real32_T       *next_mem_den = filt_mem_den + 1;
            /* During frame_based processing and one filter-per-frame reset num and den for
               each sample of the same frame. */
            if (one_fpf) {
                num = tnum;  /* reset back to the start of the numerator coefficients */
                den = tden;  /* reset back to the start of the denominator coeffs. */
            } else {
                invA0 = 1/(*den);
            }
            den++;  /* All denominator coeffs are assumed to be normalized
                       so that the algorithm starts at a[1] */

            sum = invA0*(in + (*filt_mem_den));  /* temporaray variable to hold the sum (x + v0)/a0 */
            *y++ = *filt_mem_num + (*num++)*sum;

            /* Update states having both numerator and denominator coeffs
             */
            for (j = 0; j < ordNUM; j++)  {
                *filt_mem_num++ = (*next_mem_num++) + (*num++)*sum;
            }

            for (j = 0; j < ordDEN; j++)  {
                *filt_mem_den++ = (*next_mem_den++) - (*den++)*sum;
            }

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df1t_a0scale_rr_rt.c */
