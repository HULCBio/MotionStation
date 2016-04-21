/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_nrand.c     $Revision: 1.4 $     $Date: 2002/04/14 10:14:58 $
 *
 * Abstract:
 *      Real-Time Workshop Normal Random Number generator
 *      routines for use with real-time (fixed-step) and nonreal-time
 *      (variable-step) generated code.
 */

#include <math.h>
#include "rtlibsrc.h"


/* Function: rt_NormalRand ====================================================
 * Abstract:
 *      Normal (Gaussian) random number generator also known as mlUrandn in
 *      MATLAB V4.
 */
real_T rt_NormalRand(uint_T *seed)
{
    real_T sr, si, t;
 
    do {
        sr = 2.0 * rt_Urand(seed) - 1.0;
        si = 2.0 * rt_Urand(seed) - 1.0;
        t  = sr * sr + si * si;
    } while (t > 1.0);
 
    return(sr * sqrt((-2.0 * log(t)) / t));
} /* end rt_NormalRand */


/* [EOF] rt_nrand.c */
