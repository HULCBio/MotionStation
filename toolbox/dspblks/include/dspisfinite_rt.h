/*
 *  dspisfinite_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:11:58 $
 */
#ifndef dspisfinite_rt_h
#define dspisfinite_rt_h

#include "dsp_rt.h"

#ifdef DSPISFINITE_EXPORTS
#define DSPISFINITE_EXPORT EXPORT_FCN
#else
#define DSPISFINITE_EXPORT extern
#endif

DSPISFINITE_EXPORT int_T dspIsFinite(double x);
DSPISFINITE_EXPORT int_T dspIsFinite32(float x);

#endif  /* dspisfinite_rt_h */

/* [EOF] dspisfinite_rt.h */
