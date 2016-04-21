/*
 *  FIR_DF1_ZZ_RT.C - DSP FIR DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:44:39 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_DF_ZZ(const creal_T        *u,
                            creal_T        *y,
                            creal_T * const mem_base,
                            int32_T          *mem_offset,
                      const int_T           numDelays,
                      const int_T           sampsPerChan,
                      const int_T           numChans,
                      const creal_T * const b,
                      const boolean_T       one_fpf)
{
    int_T k;
    int_T indexN    = *mem_offset;
    const int_T ordNUM = numDelays - 1;
  
    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T i = sampsPerChan;
        /* Beginning of coefficient buffer for this channel */
        const creal_T *num = b;
    
        /* state memory for this channel */
        creal_T *filt_mem = mem_base + k * numDelays; 

        /* circular buffer offset relative to root in each channel */
        indexN = *mem_offset;

        while (i--) {   /* frame loop */
            creal_T  psum;
            int_T j;

            /* During one-filter-per-frame process reset num for each sample */
            if (one_fpf) num = b;

            psum.re = CMULT_RE(*u, *num);
            psum.im = CMULT_IM(*u, *num);
            num++;

            for (j=indexN; j < ordNUM; j++) {
                psum.re  += CMULT_RE(*(filt_mem+j), *num);
                psum.im  += CMULT_IM(*(filt_mem+j), *num);
                num++;
            }
            for (j=0; j < indexN; j++) {
                psum.re  += CMULT_RE(*(filt_mem+j), *num);
                psum.im  += CMULT_IM(*(filt_mem+j), *num);
                num++;
            }
            if (ordNUM && (--indexN < 0)) indexN = ordNUM-1;
            
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            *(filt_mem + indexN) = *u++;

            /* Compute the output value */
            *y++ = psum;

        } /* frame loop */
    } /* channel loop */
    
    *mem_offset = indexN;
}

/* [EOF] FIR_DF1_ZZ_RT.C */
 
