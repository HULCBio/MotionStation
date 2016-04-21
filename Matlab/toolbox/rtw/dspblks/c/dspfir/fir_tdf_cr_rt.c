/*
 *  FIR_TDF_CR_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:49 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_TDF_CR(const creal32_T         *u,
                      creal32_T               *y,
                      creal32_T * const       mem_base,
                      const int_T             numDelays,
                      const int_T             sampsPerChan,
                      const int_T             numChans,
                      const real32_T * const  num,
                      const int_T             ordNUM,
                      const boolean_T         one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
                
        const real32_T  *numtmp  = num;
        int_T  i = sampsPerChan;
        
        while (i--) {
            creal32_T *filt_mem   = mem_base + k * numDelays; /* state memory for this channel */
            creal32_T *next_mem   = filt_mem + 1;
            int_T   j = ordNUM;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            y->re     = u->re * *numtmp    + filt_mem->re;
            (y++)->im = u->im * *numtmp++  + filt_mem->im;

            /* Update filter states
             *   D0[n+1] = D1[n] + x[n]*b1
             *   D1[n+1] = D2[n] + x[n]*b2
             *   ...
             */            
            while (j--) {
                filt_mem->re     = next_mem->re     + u->re  * *numtmp;
                (filt_mem++)->im = (next_mem++)->im + u->im  * *numtmp++;
            }

            /* Get next channel input sample */
            u++;
            if (one_fpf) numtmp = num;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] fir_tdf_cr_rt.c */

