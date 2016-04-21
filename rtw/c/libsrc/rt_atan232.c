/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_atan2.c
 *
 * Abstract:
 *      Implements single precision "atan2", guarding
 *      against a domain error if both input arguments 
 *      are equal to zero.
 *
 * $Revision: 1.4 $
 * $Date: 2002/04/14 10:17:22 $
 */

#include <math.h>
#include "rtlibsrc.h"

#if !defined(atan2f)
#define atan2f atan2
#else
#endif


/* Function: rt_atan232 ==========================================================
 * Abstract:
 *	Returns 0.0 if a==0.0 and b==0.0, otherwise returns atan2f(a,b).
 */
real32_T rt_atan232(real32_T a, real32_T b) 
{
    return((real32_T)( (a == 0.0F && b == 0.0F) ? 0.0F : atan2f(a,b) ));

} /* end rt_atan322 */


/* [EOF] rt_atan232.c */
