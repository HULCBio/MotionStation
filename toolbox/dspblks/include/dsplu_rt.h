/* 
 *  dsplu_rt.h   Runtime functions for DSP Blockset LU Factorization block. 
 * 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:12:04 $ 
 */ 
#ifndef dsplu_rt_h 
#define dsplu_rt_h 

#include "dsp_rt.h" 

#ifdef DSPLU_EXPORTS
#define DSPLU_EXPORT EXPORT_FCN
#else
#define DSPLU_EXPORT MWDSP_IDECL
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
 * MWDSP_lu_<DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
 *    2) The second field indicates that this function is implementing the 
 *       LU Factorization algorithm. 
 *    3) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type is indicated. 
 * 
 *    Examples: 
 *       MWDSP_lu_D is the LU Factorization run time function for  
 *       double precision Real inputs. 
 */ 

DSPLU_EXPORT void MWDSP_lu_D( 
             real_T *A,
             real_T *piv,
       const int_T   n,
             boolean_T *singular
);

DSPLU_EXPORT void MWDSP_lu_R( 
             real32_T *A,
             real32_T *piv,
       const int_T     n,
             boolean_T *singular
);
 
DSPLU_EXPORT void MWDSP_lu_Z(  
             creal_T  *A,
             real_T   *piv,
       const int_T     n,
             boolean_T *singular
); 

DSPLU_EXPORT void MWDSP_lu_C( 
             creal32_T  *A,
             real32_T   *piv,
       const int_T       n,
             boolean_T *singular
);

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsplu/lu_c_rt.c"
#include "dsplu/lu_d_rt.c"
#include "dsplu/lu_r_rt.c"
#include "dsplu/lu_z_rt.c"
#endif

#endif /*  dsplu_rt_h */ 

/* [EOF] dsplu_rt.h */ 
