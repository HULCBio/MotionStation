/*
 *  IIR_DF2_a0Scale_CC_RT.C - DSP IIR DF2 filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:45:53 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2_A0Scale_CC( const creal32_T         *u,
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
        creal32_T  *filt_mem = mem_base + k*(numDelays+1); /* state memory for this channel */
        const creal32_T *num = b;
        const creal32_T *den = a;
        creal32_T num0 = *num;  /* Cache b[0] to calculate output */
        creal32_T invA0;
        CRECIP32(*den,invA0);   /* Cache 1/a[0] scale factor      */

        indexN = *mem_offset;
        while (i--) {   /* frame loop */
            creal32_T psumDEN = {0.0F,0.0F}; 
            creal32_T psumNUM = {0.0F,0.0F}; 
            creal32_T psumTMP; 
            int_T j;

            /* During frame-based processing and one-filter-per-frame */
            /* reset num and den for each sample of the same frame */
            if (one_fpf) {
                num = b;
                den = a;
            } else {
                num0 = *num;            /* Cache b[0] to calculate output */
                CRECIP32(*den,invA0);   /* Cache 1/a[0] scale factor      */
             } 
            num++;
            den++; 

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
            psumTMP.re = psumDEN.re + (*u).re;
            psumTMP.im = psumDEN.im + (*u++).im;;
            psumDEN.re = CMULT_RE(invA0, psumTMP);
            psumDEN.im = CMULT_IM(invA0, psumTMP);

            /* Update states */
            filt_mem[indexN] = psumDEN;

            /* Compute the output value */
            (*y).re   = psumNUM.re + CMULT_RE(num0,psumDEN); 
            (*y++).im = psumNUM.im + CMULT_IM(num0,psumDEN);  

        } /* frame loop */
    } /* channel loop */
    *mem_offset = indexN;  /* save index */
}

/* [EOF] */

