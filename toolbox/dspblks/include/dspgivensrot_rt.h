/*
 *  dspgivensrot_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $ $Date: 2004/04/12 23:11:54 $
 */
#include "dsp_rt.h"

#ifdef DSPGIVENSROT_EXPORTS
#define DSPGIVENSROT_EXPORT EXPORT_FCN
#else
#define DSPGIVENSROT_EXPORT extern
#endif

 /*
 * rotg - construct Givens plane rotation 
 */
DSPGIVENSROT_EXPORT void rotg(real_T *x, real_T *y, real_T *c, real_T *s);

DSPGIVENSROT_EXPORT void rotg32(real32_T *x, real32_T *y, real32_T *c, real32_T *s);

/* [EOF] dspgivensrot_rt.h */
