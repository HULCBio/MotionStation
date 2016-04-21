/*
 *  FIR_DF_RC_RT.C - DSP FIR DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.3 $  $Date: 2004/04/12 23:44:36 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_DF_RC(const real32_T         *u,
                           creal32_T        *y,
                           creal32_T * const mem_base,
                           int32_T            *mem_offset,
                     const int_T             numDelays,
                     const int_T             sampsPerChan,
                     const int_T             numChans,
                     const creal32_T * const b,
                     const boolean_T         one_fpf)
{
    int_T k;
    int_T indexN    = *mem_offset;
    const int_T ordNUM = numDelays - 1;
  
    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T i = sampsPerChan;
        /* Beginning of coefficient buffer for this channel */
        const creal32_T *num = b;
    
        /* state memory for this channel */
        creal32_T *filt_mem = mem_base + k * numDelays; 

        /* circular buffer offset relative to root in each channel */
        indexN = *mem_offset;

        while (i--) {   /* frame loop */
            creal32_T psum;
            int_T j;

            /* During one-filter-per-frame process reset num for each sample */
            if (one_fpf) num = b;

            psum.re = *u * (num->re);
            psum.im = *u * ((num++)->im);

            for (j=indexN; j < ordNUM; j++) {
                psum.re += CMULT_RE(*(filt_mem+j), *num);
                psum.im += CMULT_IM(*(filt_mem+j), *num);
                num++;
            }
            for (j=0; j < indexN; j++) {
                psum.re += CMULT_RE(*(filt_mem+j), *num);
                psum.im += CMULT_IM(*(filt_mem+j), *num);
                num++;
            }
            if (ordNUM && (--indexN < 0)) indexN = ordNUM-1;
            
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            (filt_mem + indexN)->re = *u++;
            (filt_mem + indexN)->im = 0.0F;

            /* Compute the output value */
            *y++ = psum;

        } /* frame loop */
    } /* channel loop */
    
    *mem_offset = indexN;
}

/* [EOF] FIR_DF_RC_RT.C */
 
