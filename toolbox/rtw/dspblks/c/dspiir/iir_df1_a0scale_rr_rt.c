/*
 *  IIR_DF1_RR_A0SCALE_RT.C - DSP Allpole DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:45:26 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1_A0Scale_RR(const real32_T           *u,
                                    real32_T           *y,
                                    real32_T * const    mem_base,
                                    int32_T               *mem_offset,
                                    const int_T          numDelays,
                                    const int_T          sampsPerChan,
                                    const int_T          numChans,
                                    const real32_T * const b,
                                    const int_T          ordNUM,
                                    const real32_T * const a,
                                    const int_T          ordDEN,
                                    const boolean_T      one_fpf)
{
    int_T k;
    int_T indexN    = mem_offset[0];
    int_T indexD    = mem_offset[1];
    int_T LenNum    = ordNUM + 1;
  
    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T      i   = sampsPerChan;
        /* Beginning of denominator coefficient buffer for this channel */
        const real32_T *den = a; 
        const real32_T *num = b;  
        real32_T  over_a0   =  1.0F / *den;
    
        /* state memory for this channel */
        real32_T       *filt_mem_num = mem_base + k * numDelays; 
        real32_T       *filt_mem_den = filt_mem_num + LenNum; 

        /* circular buffer offset relative to root in each channel */
        indexN    = mem_offset[0];
        indexD    = mem_offset[1];
   
        while (i--) {   /* frame loop */
            real32_T  psum = 0.0F;
            real32_T *current_mem;
            int_T j;

            /* During frame-based processing and one-filter-per-frame */
            /* reset den for each sample of the same frame */
            if (one_fpf) { den = a; num = b; }
            else         over_a0 = 1.0F / *den; 

            psum = *u * (*num++);

            /* Calculate partial sum for numerator */
            for (j=0; j<ordNUM; j++) {
                current_mem = filt_mem_num +indexN;
                psum  += *current_mem * (*num++);
                indexN++;   
                if (indexN > ordNUM) indexN = 0;  
            }
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            current_mem   = filt_mem_num + indexN;
            *current_mem  = *u++;

            /* Calculate partial sum for denominator */
            den++;
            for (j=0; j<ordDEN; j++) {
                current_mem = filt_mem_den + indexD;
                psum  -= *current_mem * (*den++); 
                indexD++;  
                if (indexD > ordDEN) indexD = 0;  
            }
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            current_mem   = filt_mem_den +indexD;
            *current_mem  = psum * over_a0; 

            /* Compute the output value */
            *y++          =  psum * over_a0; 


        } /* frame loop */
    } /* channel loop */
    
    mem_offset[0]=indexN;
    mem_offset[1]=indexD;
}

/* [EOF] */

