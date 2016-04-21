/* 
 *  dsppolyval_rt.h   Runtime functions for DSP Blockset Polynomial Evaluation block. 
 * 
 * 
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:12:09 $ 
 */ 
#ifndef dsppolyval_rt_h 
#define dsppolyval_rt_h 

#include "dsp_rt.h" 

#ifdef DSPPOLYVAL_EXPORTS
#define DSPPOLYVAL_EXPORT EXPORT_FCN
#else
#define DSPPOLYVAL_EXPORT MWDSP_IDECL
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
 * MWDSP_polyval_<DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
 *    2) The second field indicates that this function is implementing the 
 *       Polynomial Evaluation algorithm. 
 *    3) The third field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The input data type and coefficient data type are indicated. 
 * 
 *    Examples: 
 *       MWDSP_polyval_DD is the Polynomial Evaluation run time function for  
 *       double precision Real inputs and double precision Real coefficients. 
 */ 

DSPPOLYVAL_EXPORT void MWDSP_polyval_DD(  
       const real_T *u,   /* *u   Input pointer */
             real_T *y, /* *y output pointer */
       const real_T *pCoeffs, /*  *pCoeffs pointer to coefficients */
       const int_T   N,    /* N    Number of coefficients*/
       const int_T   n     /* n Width of INPORT1*/ 
);

DSPPOLYVAL_EXPORT void MWDSP_polyval_RR( 
       const real32_T *u,    
             real32_T *y,  
       const real32_T *pCoeffs,  
       const int_T     N,
       const int_T     n    
);
 
DSPPOLYVAL_EXPORT void MWDSP_polyval_DZ(  
       const real_T  *u,    
             creal_T *y,  
       const creal_T *pCoeffs,    
       const int_T    N,
       const int_T    n     
    ); 

DSPPOLYVAL_EXPORT void MWDSP_polyval_RC( 
       const real32_T  *u,    
             creal32_T *y,  
       const creal32_T *pCoeffs,    
       const int_T      N,
       const int_T      n    
    );    

DSPPOLYVAL_EXPORT void MWDSP_polyval_ZD(  
       const creal_T *u,    
             creal_T *y,  
       const real_T  *pCoeffs,        
       const int_T    N,
       const int_T    n     
);

DSPPOLYVAL_EXPORT void MWDSP_polyval_CR( 
       const creal32_T *u,    
             creal32_T *y,  
       const real32_T  *pCoeffs,      
       const int_T      N,
       const int_T      n     
    ); 

DSPPOLYVAL_EXPORT void MWDSP_polyval_ZZ(  
       const creal_T *u,    
             creal_T *y,  
       const creal_T *pCoeffs,  
       const int_T    N,
       const int_T    n    
       ); 

DSPPOLYVAL_EXPORT void MWDSP_polyval_CC( 
       const creal32_T *u,   
             creal32_T *y,  
       const creal32_T *pCoeffs,  
       const int_T      N,
       const int_T      n       
       ); 

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsppolyval/polyval_cc_rt.c"
#include "dsppolyval/polyval_cr_rt.c"
#include "dsppolyval/polyval_dd_rt.c"
#include "dsppolyval/polyval_dz_rt.c"
#include "dsppolyval/polyval_rc_rt.c"
#include "dsppolyval/polyval_rr_rt.c"
#include "dsppolyval/polyval_zd_rt.c"
#include "dsppolyval/polyval_zz_rt.c"
#endif

#endif /*  dsppolyval_rt_h */ 

/* [EOF] dsppolyval_rt.h */ 
