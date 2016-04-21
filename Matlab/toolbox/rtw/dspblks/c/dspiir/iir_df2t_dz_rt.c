/*
 *  IIR_DF2T_DZ_RT.C - DSP filter runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:46:20 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2T_DZ(const real_T          *u,
                       creal_T               *y,
                       creal_T * const       mem_base,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const creal_T * const tnum,
                       const int_T           ordNUM,
                       const creal_T * const tden,
                       const int_T           ordDEN,
                       const boolean_T       one_fpf)
{
    int_T j, k, lenMIN;
    lenMIN = MIN(ordNUM, ordDEN); /* for common state update loop */

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        int_T            i = sampsPerChan;
        const creal_T *num = tnum;
        const creal_T *den = tden; 
        while (i--) {
            creal_T *filt_mem   = mem_base + k * numDelays; /* state memory for this channel */
            creal_T *next_mem   = filt_mem + 1;
            real_T  in          = *u++;    /* Get next channel input sample */
            creal_T out;

            den++;  /* All denominator coeffs are assumed to be normalized
                       so that the algorithm starts at a[1] */
            
            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            (y)->re     = out.re = in * num->re     + filt_mem->re;
            (y++)->im   = out.im = in * (num++)->im + filt_mem->im;
            
            /* Update states having both numerator and denominator coeffs
             *   D0[n+1] = D1[n] + x[n]*b1 - y[n]*a1
             *   D1[n+1] = D2[n] + x[n]*b2 - y[n]*a2
             *   ...
             */
            for (j=0; j < lenMIN; j++) {
                filt_mem->re     = next_mem->re     + in * num->re     - CMULT_RE(out, *den);
                (filt_mem++)->im = (next_mem++)->im + in * (num++)->im - CMULT_IM(out, *den);
                ++den;
            }
            /* Update the rest of the states.  Note that
             * at most one of these two statements will execute
             */
            for (   ; j < ordNUM; j++) {
                filt_mem->re     = next_mem->re     + in  * num->re;
                (filt_mem++)->im = (next_mem++)->im + in  * (num++)->im;
            }
            for (   ; j < ordDEN; j++) {
                filt_mem->re     = next_mem->re     - CMULT_RE(out, *den);
                (filt_mem++)->im = (next_mem++)->im - CMULT_IM(out, *den);
                ++den;
            }
            if (one_fpf)
            {
                num = tnum;
                den = tden;
            }
        } /* frame loop */
    } /* channel loop */
}

/* [EOF] iir_df2t_dz_rt.c */

