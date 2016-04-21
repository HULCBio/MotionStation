

#include "mech_std.h"
#if defined(MATLAB_MEX_FILE)
#include "matrix.h"
#include <math.h>
/*
 * Function that returns Eps value
 */
real_T pmGetEps(void)
{
    return mxGetEps();
}

/*
 * Function that returns PI value
 */
real_T pmGetPI(void)
{
    static real_T pi = 0.0;
    if (pi == 0.0) {
        pi = 4 * atan(1.0);
    }
    return pi;
}

#if !defined(DBL_MAX)
#error "DBL_MAX not defined"
#endif

/*
 * Get RealMax
 */
real_T pmGetRealMax(void)
{
    return DBL_MAX;
}

#if !defined(DBL_MIN)
#error "DBL_MIN not defined"
#endif

/*
 * Get RealMin
 */
real_T pmGetRealMin(void)
{
    return DBL_MIN;
}
#else
#include "rt_matrx.h"
#include "rtlibsrc.h"
/*
 * Function that returns Eps value
 */
real_T pmGetEps(void)
{
    return rt_mxGetEps();
}

/*
 * Function that returns PI value
 */
real_T pmGetPI(void)
{
    return RT_PI;
}

#if !defined(DBL_MAX)
#error "DBL_MAX not defined"
#endif

/*
 * Get RealMax
 */
real_T pmGetRealMax(void)
{
    return DBL_MAX;
}

#if !defined(DBL_MIN)
#error "DBL_MIN not defined"
#endif

/*
 * Get RealMin
 */
real_T pmGetRealMin(void)
{
    return DBL_MIN;
}
#endif

/* EOF */






