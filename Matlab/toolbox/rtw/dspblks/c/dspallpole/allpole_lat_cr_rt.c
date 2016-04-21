/*
 *  AllPole_Lat_CR_RT.C - Filter block runtime helper function
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:41:01 $
 */
#include "dsp_rt.h"

EXPORT_FCN void MWDSP_AllPole_Lat_CR(const creal32_T        *u,
                          creal32_T              *y,
                          creal32_T              *mem_first,
                          const int_T            sampsPerChan,
                          const int_T            numChans,
                          const real32_T * const K_first,
                          const int_T            ordK,
                          const boolean_T        one_fpf)
{
    const int_T     ordKMinusOne = ordK - 1;
    creal32_T      *mem_last     = (creal32_T *)mem_first + ordKMinusOne;
    const real32_T *K_last       = (const real32_T *)K_first + ordKMinusOne; 
    int_T           k;

    /* Loop over each channel */
    for (k=0; k < numChans; k++) {
        int_T         i = sampsPerChan;
        const real32_T *K = K_last;

        /* Loop over each sample */
        while (i--) {
            creal32_T *g   = mem_last;
            creal32_T  f   = *u++;
        int_T      j   = ordKMinusOne;

            f.re = f.re - *K   * g->re;
            f.im = f.im - *K-- * g->im;
            while(j--) {
                f.re -= *K * (--g)->re;
                f.im -= *K * g->im;
                (g+1)->re = f.re * *K   + g->re;
                (g+1)->im = f.im * *K-- + g->im;
            }
            *y++ = *g = f;

            /* Go to last coefficient in next set */
            if (one_fpf) K  = K_last;
            else         K += 2*ordK;
        }
        mem_last += ordK;
    } /* channel loop */
}

/* [EOF] MWDSP_AllPole_Lat_CR_rt.c */

