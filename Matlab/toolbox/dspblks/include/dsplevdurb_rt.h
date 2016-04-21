/* 
 *  dsplevdurb_rt.h   Runtime functions for DSP Blockset Levinson-Durbin block. 
 * 
 *  Solves the Hermitian Toeplitz system of equations using the Levinson-Durbin
 *  recursion. 
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:12:00 $ 
 */ 
#ifndef dsplevdurb_rt_h 
#define dsplevdurb_rt_h 

#include "dsp_rt.h" 

#ifdef DSPLEVDURB_EXPORTS
#define DSPLEVDURB_EXPORT EXPORT_FCN
#else
#define DSPLEVDURB_EXPORT MWDSP_IDECL
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
 * MWDSP_LevDurb_<OutputOptions>_<Optional: Chk>_<DataType> 
 * 
 *    1) MWDSP_ is a prefix used with all Mathworks DSP runtime library 
 *       functions. 
 *    2) The second field indicates that this function is implementing the 
 *       Levinson-Durbin algorithm. 
 *    3) The third field is a string indicating output options in terms of 
 *       number of outputs as well as the nature of each output:  
 *       A   - One output, LPC filter coefficients 
 *       AK  - Two outputs, LPC filter coefficients and Reflection coefficients 
 *       AP  - Two outputs, LPC filter coefficients and Prediction error energy 
 *       AKP - Three outputs, LPC filter coefficients, Reflection coefficients 
 *       and Prediction error energy 
 *    4) The last field enumerates the data type from the above list. 
 *       Single/double precision and complexity are specified within a single letter. 
 *       The data types of the input and output are the same. 
 * 
 *    Examples: 
 *       MWDSP_LevDurb_AKP_Z is the Levinson Durbin run time function for  
 *       double precision complex inputs. Three outputs (A, K, and P) are computed. 
 */ 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_A_D(  
       const real_T *u,   /* *u   Input pointer */ 
             real_T *y_A, /* *y_A A output pointer */ 
       const int_T   N    /* N    Input array length */
);

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AK_D( 
       const real_T *u,   /* *u   Input pointer */ 
             real_T *y_A, /* *y_A A output pointer */ 
             real_T *y_K, /* *y_K K output pointer */ 
       const int_T   N   /* N    Input array length */ 
);
 
DSPLEVDURB_EXPORT void MWDSP_LevDurb_AP_D(  
       const real_T *u,   /* *u   Input pointer */ 
             real_T *y_A, /* *y_A A output pointer */ 
             real_T *y_P, /* *y_P P output pointer  */ 
       const int_T   N    /* N    Input array length */ 
    ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AKP_D( 
       const real_T *u,   /* *u   Input pointer      */ 
             real_T *y_A, /* *y_A A output pointer   */ 
             real_T *y_K, /* *y_K K output pointer   */ 
             real_T *y_P, /* *y_P P output pointer   */ 
       const int_T   N    /* N    Input array length */ 
    ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_A_R(  
       const real32_T *u,   /* *u   Input pointer */ 
             real32_T *y_A, /* *y_A A output pointer */ 
       const int_T     N    /* N    Input array length */ 
);

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AK_R( 
       const real32_T *u,   /* *u   Input pointer */ 
             real32_T *y_A, /* *y_A A output pointer*/ 
             real32_T *y_K, /* *y_K K output pointer */ 
       const int_T     N    /* N    Input array length */ 
    ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AP_R(  
       const real32_T *u,   /* *u   Input pointer */ 
             real32_T *y_A, /* *y_A A output pointer */ 
             real32_T *y_P, /* *y_P P output pointer  */ 
       const int_T     N    /* N    Input array length */     
       ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AKP_R( 
       const real32_T *u,   /* *u   Input pointer */ 
             real32_T *y_A, /* *y_A A output pointer */ 
             real32_T *y_K, /* *y_K K output pointer */ 
             real32_T *y_P, /* *y_P P output pointer  */ 
       const int_T     N    /* N    Input array length */ 
       ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_A_Z( 
       const creal_T *u,   /* *u   Input pointer */ 
             creal_T *y_A, /* *y_A   A output pointer */ 
       const int_T    N    /* N    Input array length */ 
); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AK_Z( 
       const creal_T *u,   /* *u   Input pointer */ 
             creal_T *y_A, /* *y_A A output pointer */ 
             creal_T *y_K, /* *y_K K output pointer */ 
       const int_T    N   /* N    Input array length */ 
    );
 
DSPLEVDURB_EXPORT void MWDSP_LevDurb_AP_Z( 
       const creal_T *u,   /* *u   Input pointer */ 
             creal_T *y_A, /* *y_A   A output pointer */ 
             real_T  *y_P, /* *y_P P output pointer  */ 
       const int_T    N    /* N    Input array length */ 
       ); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AKP_Z( 
       const creal_T *u,   /* *u   Input pointer */ 
             creal_T *y_A, /* *y_A A output pointer */ 
             creal_T *y_K, /* *y_K K output pointer */ 
             real_T  *y_P, /* *y_P P output pointer  */ 
       const int_T    N    /* N    Input array length */ 
); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_A_C( 
       const creal32_T *u,     /* *u    Input pointer      */ 
             creal32_T *y_A,   /* *y_A  A output pointer   */
       const int_T      N      /*  N    Input array length */                             
); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AK_C( 
       const creal32_T *u,   /* *u   Input pointer */ 
             creal32_T *y_A, /* *y_A A output pointer */ 
             creal32_T *y_K, /* *y_K K output pointer */ 
       const int_T      N    /* N    Input array length */ 
); 

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AP_C( 
       const creal32_T *u,   /* *u   Input pointer */ 
             creal32_T *y_A, /* *y_A A output pointer */ 
             real32_T  *y_P, /* *y_P P output pointer  */ 
       const int_T      N    /* N    Input array length */ 
    );

DSPLEVDURB_EXPORT void MWDSP_LevDurb_AKP_C(  
       const creal32_T *u,   /* *u   Input pointer */ 
             creal32_T *y_A, /* *y_A A output pointer */ 
             creal32_T *y_K, /* *y_K K output pointer */ 
             real32_T  *y_P, /* *y_P P output pointer  */ 
       const int_T      N    /* N    Input array length */ 
       ); 

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dsplevdurb/levdurb_a_c_rt.c"
#include "dsplevdurb/levdurb_a_d_rt.c"
#include "dsplevdurb/levdurb_a_r_rt.c"
#include "dsplevdurb/levdurb_a_z_rt.c"
#include "dsplevdurb/levdurb_ak_c_rt.c"
#include "dsplevdurb/levdurb_ak_d_rt.c"
#include "dsplevdurb/levdurb_ak_r_rt.c"
#include "dsplevdurb/levdurb_ak_z_rt.c"
#include "dsplevdurb/levdurb_akp_c_rt.c"
#include "dsplevdurb/levdurb_akp_d_rt.c"
#include "dsplevdurb/levdurb_akp_r_rt.c"
#include "dsplevdurb/levdurb_akp_z_rt.c"
#include "dsplevdurb/levdurb_ap_c_rt.c"
#include "dsplevdurb/levdurb_ap_d_rt.c"
#include "dsplevdurb/levdurb_ap_r_rt.c"
#include "dsplevdurb/levdurb_ap_z_rt.c"
#endif

#endif /*  dsplevdurb_rt_h */ 

/* [EOF] dsplevdurb_rt.h */ 

