/* $Revision: 1.2.2.2 $ */
/*
 *  IIR_DF2T_A0SCALE_CC_RT.C - DSP filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision:
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2T_A0Scale_CC(const creal32_T         *u,
                               creal32_T               *y,
                               creal32_T * const       mem_base,
                               const int_T             numDelays,
                               const int_T             sampsPerChan,
                               const int_T             numChans,
                               const creal32_T * const tnum,
                               const int_T             ordNUM,
                               const creal32_T * const tden,
                               const int_T             ordDEN,
                               const boolean_T         one_fpf)
{
    int_T j, k, lenMIN;
    lenMIN = MIN(ordNUM, ordDEN); /* for common state update loop */

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T            i = sampsPerChan;
        const creal32_T *num = tnum;
        const creal32_T *den = tden; 
        creal32_T invA0;
        CRECIP32(*den, invA0);
        while (i--) {
            creal32_T in        = *u++;  /* Get next channel input sample */
            creal32_T *filt_mem = mem_base + k * numDelays; /* state memory for this channel */
            creal32_T *next_mem = filt_mem + 1;
            creal32_T out;        

            if (one_fpf)
            {
                num = tnum;
                den = tden;
            }
            else CRECIP32(*den, invA0);

            
            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            out.re = CMULT_RE(in, *num) + filt_mem->re;
            out.im = CMULT_IM(in, *num) + filt_mem->im;
            y->re  = CMULT_RE(out, invA0);
            y->im  = CMULT_IM(out, invA0);
            ++den;
            ++num;
            
            /* Update states having both numerator and denominator coeffs
             *   D0[n+1] = D1[n] + x[n]*b1 - y[n]*a1
             *   D1[n+1] = D2[n] + x[n]*b2 - y[n]*a2
             *   ...
             */
            for (j=0; j < lenMIN; j++) {
                filt_mem->re     = next_mem->re     + CMULT_RE(in, *num) - CMULT_RE(*y, *den);
                (filt_mem++)->im = (next_mem++)->im + CMULT_IM(in, *num) - CMULT_IM(*y, *den);
                ++num;  ++den;
            }
            /* Update the rest of the states.  Note that
             * at most one of these two statements will execute
             */
            for (   ; j < ordNUM; j++) {
                filt_mem->re     = next_mem->re     + CMULT_RE(in, *num);
                (filt_mem++)->im = (next_mem++)->im + CMULT_IM(in, *num);
                ++num;
            }
            for (   ; j < ordDEN; j++) {
                filt_mem->re     = next_mem->re     - CMULT_RE(*y, *den);
                (filt_mem++)->im = (next_mem++)->im - CMULT_IM(*y, *den);
                ++den;
            }
            y++;
        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df2t_a0scale_cc_rt.c */

