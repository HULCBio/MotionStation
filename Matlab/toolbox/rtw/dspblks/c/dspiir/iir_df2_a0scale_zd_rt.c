/*
 *  IIR_DF2_a0Scale_ZD_RT.C DSP IIR DF2 filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.2.3 $  $Date: 2004/04/12 23:45:59 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF2_A0Scale_ZD( const creal_T           *u,
                               creal_T                *y,
                               creal_T        * const mem_base,
                               int32_T                 *mem_offset,
                               const int_T            numDelays,
                               const int_T            sampsPerChan,
                               const int_T            numChans,
                               const real_T  * const b, 
                               const int_T            ordNUM,
                               const real_T  * const a,
                               const int_T            ordDEN, 
                               const boolean_T        one_fpf)
{
    int_T lenMIN = MIN(ordNUM, ordDEN); /* for common partial sum update loop */
    int_T indexN = *mem_offset;
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {   /* Channel loop */
        int_T i = sampsPerChan;
        creal_T *filt_mem = mem_base + k*(numDelays+1); /* state memory for this channel */
        const real_T *num = b;
        const real_T *den = a;
        real_T num0 = *num;       /* Cache b[0] to calculate output */
        real_T invA0 = 1/(*den);  /* Cache 1/a[0] scale factor      */

        indexN = *mem_offset;
        while (i--) {   /* frame loop */
            creal_T psumDEN = {0.0,0.0}; 
            creal_T psumNUM = {0.0,0.0}; 
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
                psumDEN.re -= *den   * (filt_mem[indexN]).re; 
                psumDEN.im -= *den++ * (filt_mem[indexN]).im;  
                psumNUM.re += *num   * (filt_mem[indexN]).re; 
                psumNUM.im += *num++ * (filt_mem[indexN]).im;  
                if (++indexN > numDelays) indexN = 0;  
            }

            /* Update the rest of the partial sums.  Note that
             * at most one of these two for-loops will execute.
             */
            for ( ; j < ordDEN; j++) {
                psumDEN.re -= *den   * (filt_mem[indexN]).re; 
                psumDEN.im -= *den++ * (filt_mem[indexN]).im;  
                if (++indexN > numDelays) indexN = 0;  
            }
            for ( ; j < ordNUM; j++) {
                psumNUM.re += *num   * (filt_mem[indexN]).re; 
                psumNUM.im += *num++ * (filt_mem[indexN]).im;  
                if (++indexN > numDelays) indexN = 0;  
            }
            psumDEN.re = invA0*(psumDEN.re + (*u).re);
            psumDEN.im = invA0*(psumDEN.im + (*u++).im);

            /* Update states */
            filt_mem[indexN] = psumDEN;

            /* Compute the output value */
            (*y).re   =   psumNUM.re +  num0  *  psumDEN.re; 
            (*y++).im =   psumNUM.im +  num0  *  psumDEN.im;  

        } /* frame loop */
    } /* channel loop */
    *mem_offset = indexN;  /* save index */
}

/* [EOF] */

