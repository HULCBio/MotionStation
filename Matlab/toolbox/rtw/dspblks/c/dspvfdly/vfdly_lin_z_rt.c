/*
 *  vfdly_lin_z_rt Run-time function for Variable Fractional Delay block.
 *
 *  This function implements the case of Linear interpolation mode, 
 *  Date-type is :- double-precision, complex
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $  $Date: 2004/04/12 23:49:46 $
 */

#include "dspvfdly2_rt.h"

EXPORT_FCN void MWDSP_Vfdly_Lin_Z(
     const creal_T * const buffptr, 
     const int_T          buflen, 
     creal_T             **yptr, 
     int_T                ti,
     const int_T          buffstart, 
     const real_T         frac)

{
    const real_T frac1 = 1 - frac;
    const creal_T  *in_curr = buffptr;  /* Store new input samples: */
    ti = buffstart - ti;
    if (ti < 0) ti += buflen;
    in_curr += ti; /* Get pointer into buffer */

    if (ti > 0) {
        /* The two points are adjacent in memory: */
        (*yptr)->re   = in_curr[0].re * frac1 + in_curr[-1].re * frac;
        ((*yptr)++)->im = in_curr[0].im * frac1 + in_curr[-1].im * frac;
    } else {
        /* The two points are at the end and start of buffer: */
        (*yptr)->re   = in_curr[0].re * frac1 + in_curr[buflen-1].re * frac;
        ((*yptr)++)->im = in_curr[0].im * frac1 + in_curr[buflen-1].im * frac;
    }
}

/* [EOF] vfdly_lin_z_rt.c */

