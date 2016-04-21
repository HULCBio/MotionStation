/* $Revision: 1.3.2.3 $ */
/*
 * unwrap_r_nrop_rt.c - Signal Processing Blockset Unwrap run-time function
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Specifications: 
 *      Not in-place 
 *      non-running
 * 
 * Single precision data types.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Unwrap_R_NROP(const real32_T *u,
                               real32_T *y, 
                         const real32_T cutoff,           
                               int_T    inCols,
                               int_T    inRows
                        )
{
    /* Unwrap along first non-singleton dimension*/
    while(inCols--)
    {
        real32_T cumsum        = 0.0F;  
        real32_T dp_correction = 0.0F;
        int_T i;

        *y++ = *u++;  /* The first value is unchanged */

        for(i=0; i<(inRows-1); i++)
        {
            /* Incremental phase variations. (current - previous) */ 
            real32_T dp = *u - *(u-1);  
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

            *y++ = *u++ + cumsum;
        }
    }
}

/* [EOF] unwrap_r_nrop_rt.c */

