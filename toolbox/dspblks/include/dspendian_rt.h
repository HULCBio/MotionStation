/*
 *  dspendian_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.2.4.3 $ $Date: 2004/04/12 23:11:45 $
 */
#ifndef dspendian_rt_h
#define dspendian_rt_h

#include "dsp_rt.h"

#ifdef DSPENDIAN_EXPORTS
#define DSPENDIAN_EXPORT EXPORT_FCN
#else
#define DSPENDIAN_EXPORT extern
#endif

DSPENDIAN_EXPORT int_T isLittleEndian(void);

#endif  /* dspendian_rt_h */

/* [EOF] dspendian_rt.h */
