/* $Revision: 1.3.2.3 $ */
/*
 * unwrap_d_nrip_rt.c - Signal Processing Blockset Unwrap run-time function
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Specifications: 
 *      In-place algorithm non-running
 * 
 * Double precision data types.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Unwrap_D_NRIP(      real_T *y,
                         const real_T cutoff,
                               int_T  inCols,
                               int_T  inRows
                        )
{
    while (inCols--)
    {
        real_T cumsum        = 0.0;  
        real_T dp_correction = 0.0;
        real_T prev          = *y++;
        int_T  i;
        
        for(i=0; i<(inRows-1); i++) 
        { 
            /* Incremental phase variations */ 
            real_T dp = *y - prev;
            
            real_T dp_tmp   = (dp+DSP_PI)/DSP_TWO_PI; 
            real_T dp_floor = (int_T)((dp_tmp > 0.0) ? dp_tmp : (dp_tmp - 0.9999999999));
            real_T dp_shift = (dp + DSP_PI - DSP_TWO_PI * dp_floor) - DSP_PI; 
            
            /* Preserve variation sign for pi vs. -pi */ 
            if (dp_shift==-DSP_PI && dp>0.0)
                dp_shift = DSP_PI;            

            /* Incremental phase corrections */ 
            dp_correction = dp_shift - dp;
                                                
            /* Ignore correction when incr. variation is not greater than CUTOFF */ 
            if ((fabs(dp_correction) > cutoff))
                cumsum += dp_correction;

            prev  = *y;
            *y++ += cumsum;
        }  /* for inRows */
    } /* for inCols */
}

/* [EOF] unwrap_d_nrip_rt.c */
