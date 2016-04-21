/* 
 * dspsvd_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.8.4.3 $  $Date: 2004/04/12 23:12:16 $
 *
 * Abstract:
 *   Header file for svd functions
 */

#ifndef dspsvd_rt_h
#define dspsvd_rt_h

#include "dsp_rt.h"

#ifdef DSPSVD_EXPORTS
#define DSPSVD_EXPORT EXPORT_FCN
#else
#define DSPSVD_EXPORT extern
#endif

/* Maximum number of iterations */
#define MAXIT 75

/*
 * Singular value decomposition
 */

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


/*
 * Function naming convention
 * ---------------------------
 *
 * MWDSP_SVD_<DataType>
 *
 * 1) MWDSP is a prefix used with all Mathworks DSP runtime library functions
 *
 * 2) The second field indicates that this function is implementing the SVD
 *    algorithm. 
 *
 * 3) The third field is a string indicating the nature of the data type
 *
 */

DSPSVD_EXPORT int_T MWDSP_SVD_D(real_T *x,             /*Input matrix*/
                                 int_T n,       /* M < N ? N : M*/
                                 int_T p,       /* M < N ? M : N*/
                                 real_T *s,     /* output svd */
                                 real_T *e,     /* scratch space for svd algorithm*/
                                 real_T *work,  /* scratch space for svd algorithm*/
                                 real_T *u,     /* output pointer for u*/
                                 real_T *v,     /* output pointer for v*/
                                 int_T wantv);  /* whether u and v is needed*/

DSPSVD_EXPORT int_T MWDSP_SVD_Z(creal_T *x,
                                 int_T n,
                                 int_T p,
                                 creal_T *s,
                                 creal_T *e,
                                 creal_T *work,
                                 creal_T *u,
                                 creal_T *v,
                                 int_T wantv);

DSPSVD_EXPORT int_T MWDSP_SVD_R(real32_T *x,
                                 int_T n,
                                 int_T p,
                                 real32_T *s,
                                 real32_T *e,
                                 real32_T *work,
                                 real32_T *u,
                                 real32_T *v,
                                 int_T wantv);

DSPSVD_EXPORT int_T MWDSP_SVD_C(creal32_T *x,
                                 int_T n,
                                 int_T p,
                                 creal32_T *s,
                                 creal32_T *e,
                                 creal32_T *work,
                                 creal32_T *u,
                                 creal32_T *v,
                                 int_T wantv);

DSPSVD_EXPORT void MWDSP_SVD_Copy_Z(const creal_T *pA, creal_T *pX, const int_T M, const int_T N);
DSPSVD_EXPORT void MWDSP_SVD_Copy_D(const real_T *pA, real_T *pX, const int_T M, const int_T N);
DSPSVD_EXPORT void MWDSP_SVD_Copy_C(const creal32_T *pA, creal32_T *pX, const int_T M, const int_T N);
DSPSVD_EXPORT void MWDSP_SVD_Copy_R(const real32_T *pA, real32_T *pX, const int_T M, const int_T N);

DSPSVD_EXPORT void MWDSP_SVD_CopyOutput_Z(real_T *pOS, creal_T *pS, int_T P);
DSPSVD_EXPORT void MWDSP_SVD_CopyOutput_D(real_T *pOS, real_T *pS, int_T P);
DSPSVD_EXPORT void MWDSP_SVD_CopyOutput_C(real32_T *pOS, creal32_T *pS, int_T P);
DSPSVD_EXPORT void MWDSP_SVD_CopyOutput_R(real32_T *pOS, real32_T *pS, int_T P);

#endif /* dspsvd_rt_h */

/* [EOF] dspsvd_rt.h */
