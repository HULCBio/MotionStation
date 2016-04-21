/* $Revision: 1.2.4.3 $ */
/* 
 * dsppinv_rt.h
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision:
 *
 * Abstract:
 *   Header file for pseudoinverse run-time functions
 */

#ifndef dsppinv_rt_h
#define dsppinv_rt_h

#include "dsp_rt.h"

#ifdef DSPPINV_EXPORTS
#define DSPPINV_EXPORT EXPORT_FCN
#else
#define DSPPINV_EXPORT extern
#endif

/*
 * Pseudoinverse
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
 * MWDSP_PINV_<DataType>
 *
 * 1) MWDSP is a prefix used with all Mathworks DSP runtime library functions
 *
 * 2) The second field indicates that this function is used in
 *    implementing the Pseudo inverse.
 *
 * 3) The third field is a string indicating the nature of the data type
 *
 */

DSPPINV_EXPORT void MWDSP_PINV_D(real_T *pS, real_T *pU, real_T *pV, real_T *pX, int_T M, int_T N);
DSPPINV_EXPORT void MWDSP_PINV_R(real32_T *pS, real32_T *pU, real32_T *pV, real32_T *pX, int_T M, int_T N);
DSPPINV_EXPORT void MWDSP_PINV_Z(creal_T *pS, creal_T *pU, creal_T *pV, creal_T *pX, int_T M, int_T N);
DSPPINV_EXPORT void MWDSP_PINV_C(creal32_T *pS, creal32_T *pU, creal32_T *pV, creal32_T *pX, int_T M, int_T N);

#endif /* dsppinv_rt_h */

/* [EOF] dsppinv_rt.h */
