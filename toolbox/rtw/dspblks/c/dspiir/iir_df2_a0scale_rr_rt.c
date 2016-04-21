/*
 *  IIR_DF2_a0Scale_RR_RT.C - DSP IIR DF2 filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:45:58 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2_A0Scale_RR (const real32_T         *u,
                               real32_T               *y,
                               real32_T        * const mem_base,
                               int32_T                   *mem_offset,
                               const int_T             numDelays,
                               const int_T             sampsPerChan,
                               const int_T             numChans,
                               const real32_T  * const b, 
                               const int_T             ordNUM,
                               const real32_T  * const a,
                               const int_T             ordDEN, 
                               const boolean_T         one_fpf)
{
    int_T lenMIN = MIN(ordNUM, ordDEN); /* for common partial sum update loop */
    int_T indexN = *mem_offset;
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {   /* Channel loop */
        int_T i = sampsPerChan;
        real32_T *filt_mem = mem_base + k*(numDelays+1); /* state memory for this channel */
        const real32_T *num = b;
        const real32_T *den = a;
        real32_T num0 = *num;       /* Cache b[0] to calculate output */
        real32_T invA0 = 1/(*den);  /* Cache 1/a[0] scale factor      */

        indexN = *mem_offset;
        while (i--) {   /* frame loop */
            real32_T psumDEN = 0.0F; 
            real32_T psumNUM = 0.0F; 
            int_T j;

            /* During frame-based processing and one-filter-per-frame */
            /* reset num and den for each sample of the same frame */
            if (one_fpf) {
                num = b;
                den = a;
            } else {
                num0 = *num;       /* Cache b[0] to calculate output */
                invA0 = 1/(*den);  /* Cache 1/a[0] scale factor      */
            } 
            num++;
            den++; 

            /* Calculate partial sum for denominator and numerator */
            for (j=0; j<lenMIN; j++) {
                psumDEN -= *den++ * filt_mem[indexN]; 
                psumNUM += *num++ * filt_mem[indexN]; 
                if (++indexN > numDelays) indexN = 0;  
            }

            /* Update the rest of the partial sums.  Note that
             * at most one of these two for-loops will execute.
             */
            for ( ; j < ordDEN; j++) {
                psumDEN -= *den++ * filt_mem[indexN]; 
                if (++indexN > numDelays) indexN = 0;  
            }
            for ( ; j < ordNUM; j++) {
                psumNUM += *num++ * filt_mem[indexN]; 
                if (++indexN > numDelays) indexN = 0;  
            }
            psumDEN = invA0*(psumDEN + *u++); 

            /* Update states */
            filt_mem[indexN] = psumDEN;

            /* Compute the output value */
            *y++ = psumNUM + num0 * psumDEN; 

        } /* frame loop */
    } /* channel loop */
    *mem_offset = indexN;  /* save index */
}

/* [EOF] */

