/* $Revision: 1.3.2.3 $ */
/*
 * unwrap_r_rops_rt.c - Signal Processing Blockset Unwrap run-time function
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Specifications: 
 *      Not in-place
 *      Sample-based running, > 1 channel:
 * 
 * Single precision data types.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Unwrap_R_ROPS(const real32_T *u,
                               real32_T *y, 
                               real32_T *prev,
                               real32_T *pcumsum,
                         const real32_T cutoff,
                               int_T    numChans,
                               boolean_T *firstime
                        )
{
    int_T   i;

    /* Need to initialize state here because we need access to the input values,
     * which are not available during mdlStart or mdlInitialConditions. 
     */    
    if(*firstime) 
    {
        real32_T   *cumsum = pcumsum;
        real32_T  *prevptr = prev;
        const real32_T *in = u;
        for (i=0; i < numChans; i++)
        {
            *cumsum++ = 0.0F;
            *prevptr++   = *in++;
        }
        *firstime = 0;
    }

    for(i=0; i<numChans; i++) 
    {
        real32_T cumsum        = *pcumsum;
        real32_T dp_correction = 0.0F;
        real32_T dp;

        dp = *u - *prev; 
 
        {
            real32_T dp_tmp   = (dp+(real32_T)DSP_PI)/(real32_T)DSP_TWO_PI; 
            real32_T dp_floor = (real32_T)(int_T)((dp_tmp > 0.0F) ? dp_tmp : (dp_tmp - 0.99999F)); 
            real32_T dp_shift = (dp + (real32_T)DSP_PI - (real32_T)DSP_TWO_PI * dp_floor) - (real32_T)DSP_PI; 
     
            /* Preserve variation sign for pi vs. -pi */ 
            if(dp_shift==-(real32_T)DSP_PI && dp>0.0F)
                dp_shift = (real32_T)DSP_PI;            

            /* Incremental phase corrections */ 
            dp_correction = dp_shift - dp;      

            /* Ignore correction when incr. variation is not greater than CUTOFF */ 
            if((FABS32(dp_correction) > cutoff))
                cumsum += dp_correction;
        }
        *prev++    = *u;    /* Save last value in frame     */
        *y++       = *u++ + cumsum;       
        *pcumsum++ = cumsum; /* Save cumsum for each channel */
    }            
}

/* [EOF] unwrap_r_rops_rt.c */

