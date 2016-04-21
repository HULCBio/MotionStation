/* 
 *  dspldl_rt.h   Runtime functions for DSP Blockset LDL Factorization block. 
 * 
 *  Factorizes a square Hermitian Positive defintre matrix A into a 
 *  lower triangular matrix L and a diagonal matrix D such that A=LDL'
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.3.4.2 $  $Date: 2004/04/12 23:11:59 $ 
 */ 
#ifndef dspldl_rt_h 
#define dspldl_rt_h 

#include "dsp_rt.h" 

#ifdef DSPLDL_EXPORTS
#define DSPLDL_EXPORT EXPORT_FCN
#else
#define DSPLDL_EXPORT MWDSP_IDECL
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
 
/* Function naming convention 
 * -------------------------- 
 * 
 * MWDSP_ldl_<DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
 *    2) The second field LDL_ indicates that this function is implementing the 
 *       LDL Factorization algorithm. 
 *    3) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       MWDSP_ldl_D is the LDL Factorization run time function for  
 *       double precision Real inputs. 
 */ 

DSPLDL_EXPORT void MWDSP_LDL_D(  
       real_T *A,        /* Output Matrix */
       real_T *V,        /* Intermediate array */
       int_T   n,        /* Number of square matrix rows (or columns)*/
       boolean_T *state  /* Boolean signaling positive definiteness */
);

DSPLDL_EXPORT void MWDSP_LDL_R( 
       real32_T *A,      /* Output Matrix */
       real32_T *V,      /* Intermediate array */
       int_T     n,      /* Number of square matrix rows (or columns)*/
       boolean_T *state  /* Boolean signaling positive definiteness */
);
 
DSPLDL_EXPORT void MWDSP_LDL_Z(  
       creal_T  *A,      /* Output Matrix */
       creal_T  *V,      /* Intermediate array */
       int_T     n,      /* Number of square matrix rows (or columns)*/ 
       boolean_T *state  /* Boolean signaling positive definiteness */
); 

DSPLDL_EXPORT void MWDSP_LDL_C( 
       creal32_T  *A,    /* Output Matrix */
       creal32_T  *V,    /* Intermediate array */
       int_T       n,    /* Number of square matrix rows (or columns)*/ 
       boolean_T *state  /* Boolean signaling positive definiteness */
);    

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspldl/ldl_c_rt.c"
#include "dspldl/ldl_d_rt.c"
#include "dspldl/ldl_r_rt.c"
#include "dspldl/ldl_z_rt.c"
#endif

#endif /*  dspldl_rt_h */ 

/* [EOF] dspldl_rt.h */ 
