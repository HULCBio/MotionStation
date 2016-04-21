/* $Revision: 1.3.2.3 $ */
/*
 * unwrap_d_ripf_rt.c - Signal Processing Blockset Unwrap run-time function
 *
 * The Unwrap block unwraps radian phases in the input 
 * vector by replacing absolute jumps greater than the 
 * specified Tolerance with their 2*pi complement. 
 * 
 * Specifications: 
 *      In-place algorithm
 *      Frame-based running
 * 
 * Double precision data types.
 * 
 * Copyright 1995-2003 The MathWorks, Inc.
 *
 */

#include "dsp_rt.h"

EXPORT_FCN void MWDSP_Unwrap_D_RIPF(      real_T    *y,
                               real_T    *prev,
                               real_T    *pcumsum,                          
                         const real_T     cutoff,
                               int_T      inCols,
                               int_T      inRows,
                               boolean_T *firstime
                        )
{
    int_T j;
    
    /* Need to initialize state here because we need access to the input values,
     * which are not available during mdlStart or mdlInitialConditions. 
     */
    if(*firstime)
    {
        int_T i;
        real_T  *cumsum = pcumsum;
        real_T *prevptr = prev;
        real_T *in = y;
        for (i=0; i < inCols; i++)
        {
            *cumsum++  = 0.0;
            *prevptr++ = *in;
             in       += inRows;
        }
        *firstime = 0;
    }

    for(j=0; j<inCols; j++)
    {
        real_T cumsum        = *pcumsum;
        real_T y_prev        = *prev;
        real_T dp_correction = 0.0; 
        int_T i;

        for(i=0; i<inRows; i++)
        {
            real_T dp = *y - y_prev;

            real_T dp_tmp   = (dp+DSP_PI)/DSP_TWO_PI;
            real_T dp_floor = (int_T)((dp_tmp > 0.0) ? dp_tmp : (dp_tmp - 0.9999999999));
            real_T dp_shift = (dp + DSP_PI - DSP_TWO_PI * dp_floor) - DSP_PI;
            /* Preserve variation sign for pi vs. -pi */
            if (dp_shift==-DSP_PI && dp>0.0)
                dp_shift = DSP_PI;

            /* Incremental phase corrections */
            dp_correction = dp_shift - dp;

            /* Ignore correction when incr. variation is not greater than CUTOFF */
            if((fabs(dp_correction) > cutoff))
                cumsum += dp_correction;

            y_prev = *y;
            *y++  += cumsum;
        }
        *prev++    = y_prev;  /* Save last value in frame     */
        *pcumsum++ = cumsum;  /* Save cumsum for each channel */
    }
}

/* [EOF] unwrap_d_ripf_rt.c */

