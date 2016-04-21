/*
 *  dsprc2ac_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.4.3 $ $Date: 2004/04/12 23:12:12 $
 */

#ifndef dsprc2ac_rt_h
#define dsprc2ac_rt_h

#include "dsp_rt.h"

#ifdef DSPRC2AC_EXPORTS
#define DSPRC2AC_EXPORT EXPORT_FCN
#else
#define DSPRC2AC_EXPORT extern
#endif

/* 
 * List of individual LPC/RC to AC functions:-
 */

DSPRC2AC_EXPORT void MWDSP_Rc2Ac_D(const real_T    *rc,  const real_T   *perr, real_T   *ac, real_T *lpcmtrx, const int_T order);
DSPRC2AC_EXPORT void MWDSP_Rc2Ac_R(const real32_T  *rc,  const real32_T *perr, real32_T *ac, real32_T *lpcmtrx, const int_T order);
DSPRC2AC_EXPORT void MWDSP_Lpc2Ac_D(const real_T   *lpc, const real_T   *perr, real_T   *ac, real_T *lpcmtrx, const int_T order);
DSPRC2AC_EXPORT void MWDSP_Lpc2Ac_R(const real32_T *lpc, const real32_T *perr, real32_T *ac, real32_T *lpcmtrx, const int_T order);

#endif /* dsprc2ac_rt_h */

/* [EOF] dsprc2ac_rt.h */
