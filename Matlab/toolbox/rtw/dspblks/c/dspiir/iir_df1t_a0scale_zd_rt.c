/*
 *  IIR_DF1T_A0SCALE_ZD_RT.C - DSP filter runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:45:43 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1T_A0Scale_ZD( const creal_T          *u,
                         creal_T               *y,
                         creal_T * const       mem_base,
                         const int_T          numDelays,
                         const int_T          sampsPerChan,
                         const int_T          numChans,
                         const real_T * const tnum,
                         const int_T          ordNUM,
                         const real_T * const tden,
                         const int_T          ordDEN,
                         const boolean_T      one_fpf)
{
    int_T j, k;
    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T i           = sampsPerChan;
        const real_T *num = tnum;
        const real_T *den = tden;  
        real_T invA0      = 1/(*den);
        while (i--) {
            creal_T       in        = *u++;     /* Get next channel input sample */
            creal_T       sum;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            creal_T       *filt_mem_num = mem_base + k * numDelays; /* state memory for this channel */
            creal_T       *filt_mem_den = filt_mem_num + ordNUM +1; 
            creal_T       *next_mem_num = filt_mem_num + 1;
            creal_T       *next_mem_den = filt_mem_den + 1;
            /* During frame_based processing and one filter-per-frame reset num and den for
               each sample of the same frame. */
            if (one_fpf) {
                num = tnum;  /* reset back to the start of the numerator coefficients */
                den = tden;  /* reset back to the start of the denominator coeffs. */
            } else {
                invA0 = 1/(*den);
            }
            den++; 
            sum.re = invA0 * (in.re + filt_mem_den->re);  /* temporaray variable to hold the sum (x + v0) */
            sum.im = invA0 * (in.im + filt_mem_den->im);  /* temporaray variable to hold the sum (x + v0) */
            y->re     = filt_mem_num->re + (*num)*sum.re;
            (y++)->im = filt_mem_num->im + (*num++)*sum.im;

            /* Update states having both numerator and denominator coeffs
             */
            for (j = 0; j < ordNUM; j++)  {
                filt_mem_num->re = next_mem_num->re + (*num)*sum.re;
                (filt_mem_num++)->im = (next_mem_num++)->im + (*num++)*sum.im;
            }

            for (j = 0; j < ordDEN; j++)  {
                filt_mem_den->re = next_mem_den->re - (*den)*sum.re;
                (filt_mem_den++)->im = (next_mem_den++)->im - (*den++)*sum.im;
            }

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df1t_a0scale_zd_rt.c */

