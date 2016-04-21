/* $Revision: 1.4.4.2 $ */
/* 
 *  DSPCHOL_RT Runtime functions for DSP Blockset Cholesky Factorization block.
 *
 *  Factorizes a positive definite matrix A into LL' where L is a lower
 *  triangular matrix.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#ifndef dspchol_rt_h
#define dspchol_rt_h

#include "dsp_rt.h"

#ifdef DSPCHOL_EXPORTS
#define DSPCHOL_EXPORT EXPORT_FCN
#else
#define DSPCHOL_EXPORT MWDSP_IDECL
#endif

/* 
 * Function naming glossary 
 * --------------------------- 
 * 
 * MWDSP = MathWorks DSP Blockset 
 * 
 * Data types - (describe inputs to functions, and outputs) 
 * R = real single-precision 
 * C = complex single-precision 
 * D = real double-precision 
 * Z = complex double-precision 
 */ 

/*
 * Function naming convention
 * ---------------------------
 *
 * MWDSP_Chol_<DType>
 *
 * 1) MWDSP is a prefix used with all Mathworks DSP runtime library functions
 * 2) The second field indicates that this function is implementing the 
 *    Cholesky factorization algorithm for decomposing a positive definite matrix
 *    A into LL' where L is a lower triangular matrix.
 * 4) The third field indicates the DataType of the input and output.
 *
 * For example MWDSP_Chol_Z takes input complex double matrix A,
 * and gives complex double as output.
 *
 */

DSPCHOL_EXPORT void MWDSP_Chol_Z(creal_T   *A, int_T n);
DSPCHOL_EXPORT void MWDSP_Chol_C(creal32_T *A, int_T n);
DSPCHOL_EXPORT void MWDSP_Chol_D(real_T    *A, int_T n);
DSPCHOL_EXPORT void MWDSP_Chol_R(real32_T  *A, int_T n);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspchol/chol_c_rt.c"
#include "dspchol/chol_d_rt.c"
#include "dspchol/chol_r_rt.c"
#include "dspchol/chol_z_rt.c"
#endif

#endif /* dspchol_rt_h */

/* [EOF] dspchol_rt.h */
