/*-
 * Function: powdi
 * Abstract:
 *
 *    Optimized version of pow when exponent is an integer number.
 *
 * Initial coding by A S Bozin
 * Copyright 1990-2002 The MathWorks, Inc.
 * $Revision: 1.4 $ $Date: 2002/04/11 12:18:05 $
 */
#include "tmwtypes.h"
#include <math.h>

real_T powdi(real_T x, int_T n)
{
    real_T powAns;
    uint_T u;

    /*
     * First executable statement
     */
    powAns = 1;
    if (n != 0) {
        if (n < 0) {
            n = -n;
            x = 1 / x;
        }
        for (u = n;;) {
            if (u & 01)
                powAns *= x;
            if (u >>= 1)
                x *= x;
            else
                break;
        }
    }
    return (powAns);                       /* Last card of powdi */
}
