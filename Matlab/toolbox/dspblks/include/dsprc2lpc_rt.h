/*
 *  dsprc2lpc_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.1.4.3 $ $Date: 2004/04/12 23:12:13 $
 */

#ifndef dsprc2lpc_rt_h
#define dsprc2lpc_rt_h

#include "dsp_rt.h"

#ifdef DSPRC2LPC_EXPORTS
#define DSPRC2LPC_EXPORT EXPORT_FCN
#else
#define DSPRC2LPC_EXPORT extern
#endif

/* 
 * List of individual Poly2Lsp run-time functions:-
 *
 *  These routines do the necessary conversion of either 'RC to LPC' or 'LPC to RC'
 *
 *  D for real double precision
 *  R for real single precision
 *
 *  Rc2Lpc -> conversion from Reflection coefficient (RC) to Linear Predictive coefficients (LPC)
 *  Lpc2Rc -> conversion from Linear Predictive coefficients (LPC) to Reflection coefficient (RC)
 */
DSPRC2LPC_EXPORT void MWDSP_Rc2Lpc_D(const real_T   *rc,  real_T   *lpc, const int_T order);
DSPRC2LPC_EXPORT void MWDSP_Rc2Lpc_R(const real32_T *rc,  real32_T *lpc, const int_T order);
DSPRC2LPC_EXPORT void MWDSP_Lpc2Rc_D(const real_T   *lpc, real_T   *rc,  const int_T order);
DSPRC2LPC_EXPORT void MWDSP_Lpc2Rc_R(const real32_T *lpc, real32_T *rc,  const int_T order);

#endif /* dsprc2lpc_rt_h */

/* [EOF] dsprc2lpc_rt.h */
