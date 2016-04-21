/*
 *  INTERP_LIN_R_RT Helper function for window block.
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.5.2.2 $  $Date: 2004/04/12 23:46:28 $
 */
#include "dspinterp_rt.h"

EXPORT_FCN void MWDSP_Interp_Lin_R(real32_T *y, const real32_T * const u, const real32_T *iptr, const int_T nSamps, 
                        int_T nChans, const int_T nSampsI, const int_T nChansI)
{
    int_T offset = 0;
   
    while(nChans-- > 0) {         /* Loop over channels in input data */
        int_T nSampsI_tmp = nSampsI;
        while(nSampsI_tmp-- > 0) {    /* Loop over interp points in channel */
            real32_T    t  = *iptr++;
            int_T       ti; 

            if (t < 1.0F) {
                t = 1.0F;
            } else if (t > nSamps) {
                t = (real32_T)nSamps;
            }
            ti = (int_T)t;    /* Integer part of interpolation index value */
            
            if (ti == nSamps) {
                *y++ = u[offset + ti - 1];
            } else {
                real32_T frac = t - ti;
                *y++ = u[offset + ti-1] * (1-frac)
                          + u[offset + ti  ] * frac;
            }
        } /* sample loop */
        if (nChansI == 1) iptr -= nSampsI;
        offset += nSamps;  /* next channel of input data */
    } /* channel loop */
}


/* [EOF] interp_lin_r_rt.c */
