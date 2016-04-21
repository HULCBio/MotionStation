/*
 *  IIR_DF2_RC_RT.C -  DSP IIR DF2 filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:46:05 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2_RC( const real32_T          *u,
                       creal32_T               *y,
                       creal32_T       * const mem_base,
                       int32_T                   *mem_offset,
                       const int_T             numDelays,
                       const int_T             sampsPerChan,
                       const int_T             numChans,
                       const creal32_T * const b, 
                       const int_T             ordNUM,
                       const creal32_T * const a,
                       const int_T             ordDEN, 
                       const boolean_T         one_fpf)
{
    int_T lenMIN = MIN(ordNUM, ordDEN); /* for common partial sum update loop */
    int_T indexN = *mem_offset;
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {   /* Channel loop */
        int_T i = sampsPerChan;
        creal32_T *filt_mem = mem_base + k*(numDelays+1); /* state memory for this channel */
        const creal32_T *num = b;
        const creal32_T *den = a;

        indexN = *mem_offset;
        while (i--) {   /* frame loop */
            creal32_T psumDEN = {0.0F,0.0F}; 
            creal32_T psumNUM = {0.0F,0.0F}; 
            creal32_T num0 = *num;  /* Cache 0th element to calculate output */
            int_T j;

            num++; /* b[0] not used until we calculate y */
            den++; /* a[0] is assumed to be unity        */
            /* Calculate partial sum for denominator and numerator */
            for (j=0; j<lenMIN; j++) {
                psumDEN.re -= CMULT_RE(*den, filt_mem[indexN]);
                psumDEN.im -= CMULT_IM(*den, filt_mem[indexN]);  
                psumNUM.re += CMULT_RE(*num, filt_mem[indexN]);
                psumNUM.im += CMULT_IM(*num, filt_mem[indexN]);
                den++; num++;
                if (++indexN > numDelays) indexN = 0;  
            }

            /* Update the rest of the partial sums.  Note that
             * at most one of these two for-loops will execute.
             */
            for ( ; j < ordDEN; j++) {
                psumDEN.re -= CMULT_RE(*den, filt_mem[indexN]);
                psumDEN.im -= CMULT_IM(*den, filt_mem[indexN]);
                den++;
                if (++indexN > numDelays) indexN = 0;  
            }
            for ( ; j < ordNUM; j++) {
                psumNUM.re += CMULT_RE(*num, filt_mem[indexN]);
                psumNUM.im += CMULT_IM(*num, filt_mem[indexN]);  
                num++;
                if (++indexN > numDelays) indexN = 0;  
            }
            psumDEN.re += *u++;  

            /* Update states */
            filt_mem[indexN] = psumDEN;

            /* Compute the output value */
            (*y).re   = psumNUM.re + CMULT_RE(num0,psumDEN); 
            (*y++).im = psumNUM.im + CMULT_IM(num0,psumDEN);  

            /* During frame-based processing and one-filter-per-frame */
            /* reset num and den for each sample of the same frame */
            if (one_fpf) {
                num = b;
                den = a;
            } 

        } /* frame loop */
    } /* channel loop */
    *mem_offset = indexN;  /* save index */
}

/* [EOF] */

