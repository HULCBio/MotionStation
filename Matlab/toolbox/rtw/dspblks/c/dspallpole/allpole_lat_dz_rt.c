/*
 *  AllPole_Lat_DZ_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:03 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_Lat_DZ(const real_T          *u,
                          creal_T               *y,
                          creal_T               *mem_first,
                          const int_T           sampsPerChan,
                          const int_T           numChans,
                          const creal_T * const K_first,
                          const int_T           ordK,
                          const boolean_T       one_fpf)
{
    const int_T    ordKMinusOne = ordK - 1;
    creal_T       *mem_last     = (creal_T *)mem_first + ordKMinusOne;
    const creal_T *K_last       = (const creal_T *)K_first + ordKMinusOne; 
    int_T          k;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T         i  = sampsPerChan;
        const creal_T *K = K_last; 

        /* Loop over each sample time */
        while (i--) {
            creal_T *g = mem_last;
            int_T    j = ordKMinusOne;
            creal_T  f;

            f.re = *u++ - CMULT_RE(*K, *g);
            f.im = -CMULT_IM(*K, *g);
            --K;
            while(j--) {
                --g;
                f.re -= CMULT_RE(*K, *g);
                f.im -= CMULT_IM(*K, *g);
                (g + 1)->re = CMULT_YCONJ_RE(f, *K) + g->re;
                (g + 1)->im = CMULT_YCONJ_IM(f, *K) + g->im;
                --K;
            }
            *y++ = *g = f;

            /* Go to last coefficient in next set */
            if (one_fpf) K  = K_last;
            else         K += 2*ordK;
        }
        mem_last += ordK;
    } /* channel loop */
}

/* [EOF] AllPole_Lat_DZ_rt.c */

