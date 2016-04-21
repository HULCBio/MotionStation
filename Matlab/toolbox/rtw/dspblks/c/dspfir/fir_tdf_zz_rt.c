/*
 *  FIR_TDF_ZZ_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:44:55 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_FIR_TDF_ZZ(const creal_T         *u,
                      creal_T               *y,
                      creal_T * const       mem_base,
                      const int_T           numDelays,
                      const int_T           sampsPerChan,
                      const int_T           numChans,
                      const creal_T * const num,
                      const int_T           ordNUM,
                      const boolean_T       one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {

        const creal_T *numtmp  = num;
        int_T  i = sampsPerChan;

        while (i--) {
            creal_T *filt_mem   = mem_base + k * numDelays; /* state memory for this channel */
            creal_T *next_mem   = filt_mem + 1;

            /* Compute the output value
             * y[n] = x[n]*b0 + D0[n]
             */
            int_T   j = ordNUM;
            y->re     = CMULT_RE(*u, *numtmp) + filt_mem->re;
            (y++)->im = CMULT_IM(*u, *numtmp) + filt_mem->im;
            ++numtmp;

            /* Update filter states
             *   D0[n+1] = D1[n] + x[n]*b1
             *   D1[n+1] = D2[n] + x[n]*b2
             *   ...
             */             
            while (j--) {
                filt_mem->re     = next_mem->re     + CMULT_RE(*u, *numtmp);
                (filt_mem++)->im = (next_mem++)->im + CMULT_IM(*u, *numtmp);
                ++numtmp;
            }

            /* Get next channel input sample */
            u++;
            if (one_fpf) numtmp = num;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] fir_tdf_ZZ_rt.c */

