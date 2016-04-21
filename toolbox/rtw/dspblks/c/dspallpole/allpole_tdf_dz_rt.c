/*
 *  ALLPOLE_TDF_DZ_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:19 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_TDF_DZ(const real_T          *u,
                          creal_T               *y,
                          creal_T * const       mem_base,
                          const int_T           numDelays,
                          const int_T           sampsPerChan,
                          const int_T           numChans,
                          const creal_T * const den,
                          const int_T           ordDEN,
                          const boolean_T       one_fpf)
{
    int_T k;

    /* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        const creal_T *dentmp = den;
        int_T         i    = sampsPerChan;
        while (i--) {
            creal_T *filt_mem  = mem_base + k * numDelays; /* state memory for this channel */
            creal_T *next_mem  = filt_mem + 1;
            int_T   j          = ordDEN;	

            dentmp++;  /* All denominator coeffs are assumed to be normalized
                       so that the algorithm starts at a[1] */

            /* Compute the output value
             * y[n] = x[n] + D0[n]
             */
            y->re     = *u++  + filt_mem->re;
            y->im     =              filt_mem->im;

            /* Update filter states
             *   D0[n+1] = D1[n] - y[n]*a1
             *   D1[n+1] = D2[n] - y[n]*a2
             *   ...
             */           
            while (j--) {
                filt_mem->re     = next_mem->re     - CMULT_RE(*y, *dentmp);
                (filt_mem++)->im = (next_mem++)->im - CMULT_IM(*y, *dentmp);
                ++dentmp;
            }
            y++;
            if (one_fpf) dentmp = den;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] allpole_tdf_DZ_rt.c */

