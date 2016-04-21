/*
 * Header file DSPINTSIGNEXT_RT.H
 *
 * Runtime C code and macros for integer sign extension
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/06/03 15:54:09 $
 */

#ifndef _DSPINTSIGNEXT_RT_
#define _DSPINTSIGNEXT_RT_

#include "dsp_rt.h"

#ifdef __cplusplus
extern "C" {
#endif

/* MWDSP_SignExtendInt32 function
 *
 * Use to sign extend less-than-32-bit twos-complement integers
 * stored in an int32_T "bucket" to model <= 32-bit word length
 * signed value operations on platforms supporting 32-bit arithmetic.
 *
 *   valPtr       - less-than-32-bit twos-complement integer value
 *                  to sign extend (stored in an int32_T "bucket").
 *
 *   signBitIndex - the emulated twos-complement signed integer WORD LENGTH,
 *                  or alternatively the ***ONE-based*** MSB "sign bit" index
 *                  (i.e. 2 to 32, inclusive) in the integers being emulated.
 *
 * Note that for performance reasons none of the input parameters are checked.
 * "valPtr" is assumed to be valid and "signBitIndex" range assumed as [2 32].
 */
void MWDSP_SignExtendInt32(int32_T *valPtr, int signBitIndex);


#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspintsignext/dspint32signext_rt.c"
#endif

#ifdef __cplusplus
} // close brace for extern C from above
#endif

#endif /* _DSPINTSIGNEXT_RT_ */

/* [EOF] */
