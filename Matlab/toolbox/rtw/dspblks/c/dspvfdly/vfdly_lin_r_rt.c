/*
 *  vfdly_lin_r_rt Run-time function for Variable Fractional Delay block.
 *
 *  This function implements the case of Linear interpolation mode, 
 *  Date-type is :- single-precision, real 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:49:45 $
 */

#include "dspvfdly2_rt.h"

EXPORT_FCN void MWDSP_Vfdly_Lin_R(
     const real32_T * const buffptr, 
     const int_T            buflen, 
     real32_T             **yptr, 
     int_T                  ti,
     const int_T            buffstart, 
     const real32_T         frac)

{
    const real32_T  *in_curr = buffptr;  /* Store new input samples: */
    ti = buffstart - ti;
    if (ti < 0) ti += buflen;
    in_curr += ti; /* Get pointer into buffer */

    if (ti > 0) {
        /* The two points are adjacent in memory: */
        *(*yptr)++ = in_curr[0]*(1-frac) + in_curr[-1]*frac;
    } else {
        /* The two points are at the end and start of buffer: */
        *(*yptr)++ = in_curr[0]*(1-frac) + in_curr[buflen-1]*frac;
    }
}

/* [EOF] vfdly_lin_r_rt.c */

