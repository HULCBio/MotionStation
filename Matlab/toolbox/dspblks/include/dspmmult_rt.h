/*
 *  dspmmult_rt.h
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:12:05 $
 */

#ifndef dspmmult_rt_h
#define dspmmult_rt_h

#include "dsp_rt.h"

#ifdef DSPMMULT_EXPORTS
#define DSPMMULT_EXPORT EXPORT_FCN
#else
#define DSPMMULT_EXPORT MWDSP_IDECL
#endif

/*
 * Function naming glossary
 * ---------------------------
 *
 * MWDSP = MathWorks DSP Blockset
 *
 * Data types - (describe inputs to functions, not outputs)
 * R = real single-precision
 * C = complex single-precision
 * D = real double-precision
 * Z = complex double-precision
 */
DSPMMULT_EXPORT void MWDSP_MatMult_RR(
    real32_T *y,
    const real32_T *A,
    const real32_T *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_RC(
    creal32_T *y,
    const real32_T  *A,
    const creal32_T *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_CR(
    creal32_T *y,
    const creal32_T *A,
    const real32_T  *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_CC(
    creal32_T *y,
    const creal32_T *A,
    const creal32_T *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_DD(
    real_T *y,
    const real_T *A,
    const real_T *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_DZ(
    creal_T *y,
    const real_T  *A,
    const creal_T *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_ZD(
    creal_T *y,
    const creal_T *A,
    const real_T  *B,
    const int dims[3]);

DSPMMULT_EXPORT void MWDSP_MatMult_ZZ(
    creal_T *y,
    const creal_T *A,
    const creal_T *B,
    const int dims[3]);


#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspmmult/matmult_cc_rt.c"
#include "dspmmult/matmult_cr_rt.c"
#include "dspmmult/matmult_dd_rt.c"
#include "dspmmult/matmult_dz_rt.c"
#include "dspmmult/matmult_rc_rt.c"
#include "dspmmult/matmult_rr_rt.c"
#include "dspmmult/matmult_zd_rt.c"
#include "dspmmult/matmult_zz_rt.c"
#endif

#endif /* dspmmult_rt_h */

/* [EOF] dspmmult_rt.h */
