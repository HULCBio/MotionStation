/*
 *  vfdly_clip_d_rt Helper function for Variable Fractional Delay block.
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 19:19:17 $
 *
 *  This function does two things:
 *   1 - it clips the floating-point value, *delay_point,
 *       to the limits [0, maxDelay], if the value exceeds
 *       these limits.  In particular, it does NOT change
 *       the value to be an integer-valued float.
 *       (Note that the index limits are 1-based.)
 *
 *   2 - it returns an int_T with the integer-valued part
 *       of the floating-point input, after it has been
 *       properly clipped in floating-point.
 */
#include "dspvfdly2_rt.h"

int_T MWDSP_Vfdly_Clip_D(
    const int_T maxDelay, 
    real_T *delay_point
    )
{
    if (*delay_point < 0) {
        *delay_point = 0.0;
    } else if (*delay_point > maxDelay) {
        *delay_point = (real_T)maxDelay;
    }
    return((int_T) *delay_point);  /* Integer part of interpolation index value */
}

/* [EOF] vfdly_clip_d_rt.c */
