/*
 *  ALLPOLE_DF_DD_RT.C - DSP Allpole DF filter runtime helper function.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.2.3 $  $Date: 2004/04/12 23:40:54 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_DF_DD( 
                       const real_T         *u,
                       real_T               *y,
                       real_T  * const       mem_base,
                       int32_T                *offset_mem,
                       const int_T           numDelays,
                       const int_T           sampsPerChan,
                       const int_T           numChans,
                       const real_T  * const a,
                       const boolean_T       one_fpf)
{
    int_T k;
    int_T indexD    = *offset_mem;
    int_T stateLen = numDelays +1;

    /* Loop over each input channel */
    for (k=0; k < numChans; k++) {   /* channel loop */
        int_T i        = sampsPerChan;
        /* Beginning of denominator coefficient buffer for this channel */
        const real_T *den = a;  

        /* state memory for this channel */
        real_T *filt_mem = mem_base + k*stateLen; 

        /* circular buffer offset relative to root in each channel */
        indexD    = *offset_mem;  

        while (i--) {   /* frame loop */
            real_T  psumDEN = *u++; 
            int_T j;

            den++;
            /* Calculate partial sum for denominator and numerator */
            for (j=0; j<numDelays; j++) {
                psumDEN -= *den++ * filt_mem[indexD++];  
                if (indexD > numDelays) indexD = 0;  
            }
            
            /* Circular buffer magic: */
            /* update entire buffer by writing to only one element! */
             filt_mem[indexD]= psumDEN;

            /* Compute the output value */
            *y++ = psumDEN; 

            /* During frame-based processing and one-filter-per-frame */
            /* reset den for each sample of the same frame */
            if (one_fpf) den = a;

        } /* frame loop */
    } /* channel loop */
    *offset_mem=indexD;
}

/* [EOF] */



