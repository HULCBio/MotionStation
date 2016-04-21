/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_hypot.c    $Revision: 1.11 $	$Date: 2002/04/14 10:14:31 $
 *
 * Abstract:
 *      Implements "hypot" for use with the Fcn block expressions which
 *      is numerically stable.
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_hypot ==========================================================
 * Abstract:
 *	hypot(a,b) = sqrt(a^2 + b^2)
 */
real_T rt_hypot(real_T a, real_T b) 
{
    real_T t;			/* scales a & b */

    if (fabs(a) > fabs(b)) {    /* Case 1: a > b ==> t = b / a < 1.0 */
        t = b/a;
        return (fabs(a)*sqrt(1+t*t));
    } else { /* Case 2: a <= b ==> t = a / b <= 1.0 */
        if (b == 0.0) return (0.0);
        t = a/b;
        return (fabs(b)*sqrt(1+t*t));
    }
} /* end rt_hypot */


/* [EOF] rt_hypot.c */
