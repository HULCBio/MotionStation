/*
 *  ALLPOLE_DF_RC_RT.C - DSP Allpole DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:56 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_DF_RC(
                       const real32_T      *u,
                       creal32_T           *y,
                       creal32_T    * const mem_base,
                       int32_T               *offset_mem,
                       const int_T          numDelays,
                       const int_T          sampsPerChan,
                       const int_T          numChans,
                       const creal32_T  * const a,
                       const boolean_T      one_fpf)
{
    int_T k;
    int_T indexD    = *offset_mem;
    int_T stateLen = numDelays +1;

    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T i        = sampsPerChan;
        /* Beginning of denominator coefficient buffer for this channel */
        const creal32_T *den = a;  

        /* state memory for this channel */
        creal32_T *filt_mem = mem_base + k*stateLen; 

        /* circular buffer offset relative to root in each channel */
        indexD    = *offset_mem;  
       
        while (i--) {   /* frame loop */
            creal32_T  psumDEN = {0.0F, 0.0F};
            int_T j;
            creal32_T *current_mem;
                
            psumDEN.re = *u++; 
            psumDEN.im = 0.0F;
            
            den++;
            /* Calculate partial sum for denominator and numerator */
            for (j=0; j<numDelays; j++) {
                current_mem = filt_mem + indexD;
                psumDEN.re -= CMULT_RE(*den,*current_mem);
                psumDEN.im -= CMULT_IM(*den,*current_mem);  
                den++; indexD++;  
                if (indexD > numDelays) indexD = 0;  
            }
            
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
            current_mem       = filt_mem + indexD;
            (*current_mem).re = psumDEN.re;
            (*current_mem).im = psumDEN.im;
             

            /* Compute the output value */
            (*y).re   = psumDEN.re;
            (*y++).im = psumDEN.im; 

            /* During frame-based processing and one-filter-per-frame */
            /* reset den for each sample of the same frame */
            if (one_fpf) den = a;

        } /* frame loop */
    } /* channel loop */
    *offset_mem=indexD;
}

/* [EOF] */




