/*
 *  FIR_TDF_DD_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:50 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_TDF_DD(const real_T         *u,
                      real_T               *y,
                      real_T * const       mem_base,
                      const int_T          numDelays,
                      const int_T          sampsPerChan,
                      const int_T          numChans,
                      const real_T * const num,
                      const int_T          ordNUM,
                      const boolean_T      one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {

        const real_T *numtmp   = num;
        int_T i = sampsPerChan;
        
        while (i--) {
            real_T  *filt_mem   = mem_base + k * numDelays; /* state memory for this channel */
            real_T  *next_mem   = filt_mem + 1;
            int_T j    = ordNUM;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            *y++  = *u * (*numtmp++) + *filt_mem;

            /* Update filter states
             *   D0[n+1] = D1[n] + x[n]*b1
             *   D1[n+1] = D2[n] + x[n]*b2
             *   ...
             */
            while (j--) *filt_mem++ = *next_mem++ + *u * (*numtmp++);

            /* Get next channel input sample */
            u++;
            if (one_fpf) numtmp = num;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] FIR_TDF_DD_rt.c */

