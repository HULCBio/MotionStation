/*
 *  IIR_DF1_ZD_RT.C - DSP Allpole DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:45:35 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_IIR_DF1_ZD(const creal_T           *u,
                                    creal_T           *y,
                                    creal_T * const    mem_base,
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
    int_T indexN    = mem_offset[0];
    int_T indexD    = mem_offset[1];
    int_T LenNum    = ordNUM + 1;
  
    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T      i   = sampsPerChan;
        /* Beginning of denominator coefficient buffer for this channel */
        const real_T *den = a; 
        const real_T *num = b;  
    
        /* state memory for this channel */
        creal_T       *filt_mem_num = mem_base + k * numDelays; 
        creal_T       *filt_mem_den = filt_mem_num + LenNum; 

        /* circular buffer offset relative to root in each channel */
        indexN    = mem_offset[0];
        indexD    = mem_offset[1];
   
        while (i--) {   /* frame loop */
            creal_T  psum = {0.0, 0.0};
            creal_T *current_mem;
            int_T j;

            /* During frame-based processing and one-filter-per-frame */
            /* reset den for each sample of the same frame */
            if (one_fpf) { den = a; num = b; }

            psum.re = *num   *  (*u).re;
            psum.im = *num++ *  (*u).im; 

            /* Calculate partial sum for numerator */
            for (j=0; j<ordNUM; j++) {
                current_mem = filt_mem_num +indexN;
                psum.re += *num    *  (*current_mem).re;
                psum.im += *num++  *  (*current_mem).im;
                indexN++;   
                if (indexN > ordNUM) indexN = 0;  
            }
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            current_mem       = filt_mem_num + indexN;
            (*current_mem).re = (*u).re;
            (*current_mem).im = (*u++).im; 

            /* Calculate partial sum for denominator */
            den++;
            for (j=0; j<ordDEN; j++) {
                current_mem = filt_mem_den + indexD;
                psum.re -= *den   *  (*current_mem).re;
                psum.im -= *den++ *  (*current_mem).im;  
                indexD++;  
                if (indexD > ordDEN) indexD = 0;  
            }
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            current_mem       = filt_mem_den +indexD;
            (*current_mem).re = psum.re;
            (*current_mem).im = psum.im;
             

            /* Compute the output value */
            (*y).re   = psum.re;
            (*y++).im = psum.im;


        } /* frame loop */
    } /* channel loop */
    
    mem_offset[0]=indexN;
    mem_offset[1]=indexD;
}

/* [EOF] */
