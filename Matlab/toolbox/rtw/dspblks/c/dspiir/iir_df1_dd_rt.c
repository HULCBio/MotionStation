/*
 *  IIR_DF1_DD_RT.C - DSP Allpole DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:45:31 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1_DD(  const real_T           *u,
                        real_T           *y,
                        real_T * const    mem_base,
                        int32_T               *mem_offset,
                        const int_T          numDelays,
                        const int_T          sampsPerChan,
                        const int_T          numChans,
                        const real_T * const b,
                        const int_T          ordNUM,
                        const real_T * const a,
                        const int_T          ordDEN,
                        const boolean_T      one_fpf)
{
    int_T k;
    int_T indexN = mem_offset[0];
    int_T indexD = mem_offset[1];
  
    real_T *filt_mem_num = mem_base;

    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T i = sampsPerChan;
        /* Beginning of denominator coefficient buffer for this channel */
        const real_T *den = a; 
        const real_T *num = b;

        real_T *filt_mem_den = filt_mem_num + ordNUM+1;
    
        /* circular buffer offsets relative to num/den state partitions in each channel */
        indexN = mem_offset[0];
        indexD = mem_offset[1];
 
        while (i--) {   /* frame loop */
            real_T psum;
            int_T  j;

            /* During frame-based processing and one-filter-per-frame */
            /* reset den for each sample of the same frame */
            if (one_fpf) { den = a; num = b; }

            /* Calculate partial sum for numerator */
            psum = *u * (*num++); /* use b[0] term */
            for (j=0; j<ordNUM; j++) {
                psum += filt_mem_num[indexN] * (*num++);
                if (++indexN > ordNUM) indexN = 0;  
            }
            filt_mem_num[indexN] = *u++;  /* Update circular buffer */

            /* Calculate partial sum for denominator */
            den++; /* get past a[0] term, assumed to be unity */
            for (j=0; j<ordDEN; j++) {
                psum -= filt_mem_den[indexD] * (*den++); 
                if (++indexD > ordDEN) indexD = 0;
            }
            /* Update circular buffer, and copy output value */
            *y++ = filt_mem_den[indexD] = psum;  

        } /* frame loop */

        /* Increment state to next channel */
        filt_mem_num += numDelays;
        filt_mem_den += numDelays;

    } /* channel loop */
    
    mem_offset[0] = indexN;
    mem_offset[1] = indexD;
}

/* [EOF] */
