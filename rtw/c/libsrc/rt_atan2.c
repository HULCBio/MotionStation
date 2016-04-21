/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_atan2.c
 *
 * Abstract:
 *      Implements "atan2" with gaurd against domain error if both input
 *      arguments are equal to zero.
 *
 * $Revision: 1.5 $
 * $Author: batserve $
 * $Date: 2002/04/14 10:14:40 $
 */

#include <math.h>
#include "rtlibsrc.h"

/* Function: rt_atan2 ==========================================================
 * Abstract:
 *	Returns 0.0 if a==0.0 and b==0.0, otherwise returns atan2(a,b).
 */
real_T rt_atan2(real_T a, real_T b) 
{

    if (a == 0.0 && b == 0.0) {
        return(0.0);
    } else {
        return(atan2(a,b));
    }

} /* end rt_atan2 */


/* [EOF] rt_atan2.c */
