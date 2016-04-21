/*
 *  ALLPOLE_TDF_DD_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:18 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_TDF_DD(const real_T         *u,
                               real_T               *y,
                               real_T * const       mem_base,
                               const int_T          numDelays,
                               const int_T          sampsPerChan,
                               const int_T          numChans,
                               const real_T * const den,
                               const int_T          ordDEN,
                               const boolean_T      one_fpf)
{
    int_T k;

/* Loop over each input channel: */
    for (k=0; k < numChans; k++) {
        const real_T *dentmp = den;
        int_T        i    = sampsPerChan;
        while (i--) {
            real_T  *filt_mem   = mem_base + k * numDelays; /* state memory for this channel */
            real_T  *next_mem   = filt_mem + 1;
            int_T   j           = ordDEN;  

            dentmp++;  /* All denominator coeffs are assumed to be normalized
                       so that the algorithm starts at a[1] */
        
            /* Compute the output value
             * y[n] = x[n] + D0[n]
             */
            *y = *u++ + *filt_mem;
            
            /* Update filter states
             *   D0[n+1] = D1[n] - y[n]*a1
             *   D1[n+1] = D2[n] - y[n]*a2
             *   ...
             */ 
            while (j--) *filt_mem++ = *next_mem++ - *y * *dentmp++;
            y++;
            if (one_fpf) dentmp = den;

        } /* frame loop */
    } /* channel loop */
}

/* [EOF] allpole_tdf_DD_rt.c */

