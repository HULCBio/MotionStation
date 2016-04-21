/*
 *  IIR_DF1T_A0SCALE_RC_RT.C - DSP filter runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:45:41 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1T_A0Scale_RC( const real32_T         *u,
                         creal32_T               *y,
                         creal32_T * const       mem_base,
                         const int_T          numDelays,
                         const int_T          sampsPerChan,
                         const int_T          numChans,
                         const creal32_T * const tnum,
                         const int_T          ordNUM,
                         const creal32_T * const tden,
                         const int_T          ordDEN,
                         const boolean_T      one_fpf)
{
    int_T j, k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T i           = sampsPerChan;
        const creal32_T *num = tnum;
        const creal32_T *den = tden;  
        creal32_T invA0;
        CRECIP32(*den,invA0); /* usage of  CRECIP32(B,C) -> C = 1 / B  (A=1)*/
        while (i--) {
            real32_T       in        = *u++;     /* Get next channel input sample */
            creal32_T       sum, tempsum;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            creal32_T       *filt_mem_num = mem_base + k * numDelays; /* state memory for this channel */
            creal32_T       *filt_mem_den = filt_mem_num + ordNUM +1; 
            creal32_T       *next_mem_num = filt_mem_num + 1;
            creal32_T       *next_mem_den = filt_mem_den + 1;
            /* During frame_based processing and one filter-per-frame reset num and den for
               each sample of the same frame. */
            if (one_fpf) {
                num = tnum;  /* reset back to the start of the numerator coefficients */
                den = tden;  /* reset back to the start of the denominator coeffs. */
            } else {
                CRECIP32(*den,invA0);
            }
            den++; 
            tempsum.re = in + (filt_mem_den->re);  /* temporaray variable to hold the sum (x + v0) */
            tempsum.im = filt_mem_den->im;         /* temporaray variable to hold the sum (x + v0) */
            sum.re = CMULT_RE(invA0, tempsum);
            sum.im = CMULT_IM(invA0, tempsum);

            (y)->re   = (filt_mem_num->re) + CMULT_RE(*num, sum);
            (y++)->im = (filt_mem_num->im) + CMULT_IM(*num, sum);
            num++;
            /* Update states having both numerator and denominator coeffs
             */
            for (j = 0; j < ordNUM; j++)  {
                filt_mem_num->re     = (next_mem_num->re)   + CMULT_RE(*num, sum);
                (filt_mem_num++)->im = (next_mem_num++)->im + CMULT_IM(*num, sum);
                num++;
            }

            for (j = 0; j < ordDEN; j++)  {
                filt_mem_den->re     = (next_mem_den->re)   - CMULT_RE(*den, sum);
                (filt_mem_den++)->im = (next_mem_den++)->im - CMULT_IM(*den, sum);
                den++;
            }

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df1t_a0scale_rc_rt.c */
