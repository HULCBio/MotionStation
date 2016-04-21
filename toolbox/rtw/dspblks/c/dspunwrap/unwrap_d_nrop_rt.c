/* $Revision: 1.3.2.3 $ */
/*
 * unwrap_d_nrop_rt.c - Signal Processing Blockset Unwrap run-time function
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Specifications: 
 *      Not in-place Non-running
 * 
 * Double precision data types.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Unwrap_D_NROP(const real_T *u,
                               real_T *y, 
                         const real_T  cutoff,           
                               int_T   inCols,
                               int_T   inRows
                         )
{
    /* Unwrap along first non-singleton dimension*/
    while (inCols--)
    {
        real_T cumsum        = 0.0;  
        real_T dp_correction = 0.0;
        int_T  i;

        *y++ = *u++;  /* The first value is unchanged */

        for(i=0; i<(inRows-1); i++)
        {
            /* Incremental phase variations. (current - previous) */ 
            real_T dp = *u - *(u-1);  
            real_T dp_tmp   = (dp+DSP_PI)/DSP_TWO_PI; 
            real_T dp_floor = (int_T)((dp_tmp > 0.0) ? dp_tmp : (dp_tmp - 0.9999999999)); 
            real_T dp_shift = (dp + DSP_PI - DSP_TWO_PI * dp_floor) - DSP_PI; 
            
            /* Preserve variation sign for pi vs. -pi */ 
            if(dp_shift==-DSP_PI && dp>0.0)
                dp_shift = DSP_PI;

            /* Incremental phase corrections */ 
            dp_correction = dp_shift - dp;

            /* Ignore correction when incr. variation is not greater than CUTOFF */ 
            if((fabs(dp_correction) > cutoff))
                cumsum += dp_correction;

            *y++ = *u++ + cumsum;
        }
    }
}

/* [EOF] unwrap_d_nrop_rt.c */
