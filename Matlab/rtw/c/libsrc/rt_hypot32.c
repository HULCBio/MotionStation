/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_hypot.c    $Revision: 1.3 $	$Date: 2002/06/27 15:32:49 $
 *
 * Abstract:
 *      Implements single precision "hypot" for use with the Fcn 
 *      block expressions which is numerically stable.
 */

#include <math.h>
#include "rtlibsrc.h"

#if !defined(fabsf)
#define fabsf    fabs
#endif
#if !defined(sqrtf)
#define sqrtf    sqrt
#endif


/* Function: rt_hypot ==========================================================
 * Abstract:
 *	hypot(a,b) = sqrt(a^2 + b^2)
 */
real32_T rt_hypot32(real32_T a, real32_T b) 
{
    real32_T t;			/* scales a & b */

    if (fabsf(a) > fabsf(b)) {    /* Case 1: a > b ==> t = b / a < 1.0 */
        t = b/a;
        return ((real32_T)(fabsf(a)*sqrtf(1.0F + t*t)));
    } else { /* Case 2: a <= b ==> t = a / b <= 1.0 */
        if (b == 0.0F) return (0.0F);
        t = a/b;
        return ((real32_T)(fabsf(b)*sqrtf(1.0F + t*t)));
    }
} /* end rt_hypot32 */


/* [EOF] rt_hypot32.c */
