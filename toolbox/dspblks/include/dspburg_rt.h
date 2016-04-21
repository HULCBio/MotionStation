/* 
 *  DSPBURG_RT Runtime functions for DSP Blockset Burg AR Estimator block. 
 * 
 *  Estimates AR coefficients for the given input signal using Burg method.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.4.4.2 $  $Date: 2004/04/12 23:11:41 $ 
 */ 

#ifndef dspburg_rt_h
#define dspburg_rt_h

#include "dsp_rt.h"

#ifdef DSPBURG_EXPORTS
#define DSPBURG_EXPORT EXPORT_FCN
#else
#define DSPBURG_EXPORT MWDSP_IDECL
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


/*
 * Function naming convention
 * ---------------------------
 *
 * MWDSP_Burg_<outputoption>_<DataType>
 *
 * 1)  MWDSP is a prefix used with all Mathworks DSP runtime library functions
 * 2) The second field indicates that this function is implementing the Burg
 *    algorithm. 
 * 3) The third field is a string indicating the nature of the output options
 *
 *      K   - Only reflection coefficients are sent to output.
 *            This represents output option "K" only.
 *      A   - Only prediction coefficients are sent to output.
 *            This represents output option "A" only.
 *      AK  - Refelction and prediction coefficients are sent to output.
 *            This represents output option "A and K".
 *
 *            In the functions with third field "A" the args cache member
 *      variable RCcoef will not be used. This variable would not have
 *      been initialized in this case.
 *
 *            In the functions with third field "K" the args cache member
 *      variable Acoef will not be used. This variable would not have
 *      been initialized in this case.
 */

DSPBURG_EXPORT void MWDSP_Burg_K_D(const int_T   N,             /* Input array length */
                           const int_T   order,         /* Order of estimation */
                           const real_T *u,             /* Input pointer */
                                 real_T *ef,            /* Intermediate variable */
                                 real_T *eb,            /* Intermediate variable */
                                 real_T *Kcoef,         /* A - Output pointer */
                                 real_T *Error
                           );
DSPBURG_EXPORT void MWDSP_Burg_K_R(const int_T     N,             /* Input array length */
                           const int_T     order,         /* Order of estimation */
                           const real32_T *u,             /* Input pointer */
                                 real32_T *ef,            /* Intermediate variable */
                                 real32_T *eb,            /* Intermediate variable */
                                 real32_T *Kcoef,         /* A - Output pointer */
                                 real32_T *Error
                           ); 
DSPBURG_EXPORT void MWDSP_Burg_K_Z(const int_T    N,             /* Input array length */
                           const int_T    order,         /* Order of estimation */
                           const creal_T *u,             /* Input pointer */
                                 creal_T *ef,            /* Intermediate variable */
                                 creal_T *eb,            /* Intermediate variable */
                                 creal_T *Kcoef,         /* A - Output pointer */
                                 real_T  *Error
                           ); 
DSPBURG_EXPORT void MWDSP_Burg_K_C(const int_T      N,             /* Input array length */
                           const int_T      order,         /* Order of estimation */
                           const creal32_T *u,             /* Input pointer */
                                 creal32_T *ef,            /* Intermediate variable */
                                 creal32_T *eb,            /* Intermediate variable */
                                 creal32_T *Kcoef,         /* A - Output pointer */
                                 real32_T  *Error
                           ); 

DSPBURG_EXPORT void MWDSP_Burg_A_D(const int_T   N,             /* Input array length */
                           const int_T   order,         /* Order of estimation */
                           const real_T *u,            /* Input pointer */
                                 real_T *ef,           /* Intermediate variable */
                                 real_T *eb,           /* Intermediate variable */
                                 real_T *anew,         /* Intermediate AR coeffients */
                                 real_T *Acoef,        /* A - Output pointer */
                                 real_T *Error
                           ); 
DSPBURG_EXPORT void MWDSP_Burg_A_R(const int_T     N,             /* Input array length */
                           const int_T     order,         /* Order of estimation */
                           const real32_T *u,            /* Input pointer */
                                 real32_T *ef,           /* Intermediate variable */
                                 real32_T *eb,           /* Intermediate variable */
                                 real32_T *anew,         /* Intermediate AR coeffients */
                                 real32_T *Acoef,        /* A - Output pointer */
                                 real32_T *Error
                           ); 
DSPBURG_EXPORT void MWDSP_Burg_A_Z(const int_T    N,             /* Input array length */
                           const int_T    order,         /* Order of estimation */
                           const creal_T *u,             /* Input pointer */
                                 creal_T *ef,            /* Intermediate variable */
                                 creal_T *eb,            /* Intermediate variable */
                                 creal_T *anew,          /* Intermediate AR coeffients */
                                 creal_T *Acoef,         /* A - Output pointer */
                                 real_T  *Error
                           ); 
DSPBURG_EXPORT void MWDSP_Burg_A_C(const int_T      N,             /* Input array length */
                           const int_T      order,         /* Order of estimation */
                           const creal32_T *u,             /* Input pointer */
                                 creal32_T *ef,            /* Intermediate variable */
                                 creal32_T *eb,            /* Intermediate variable */
                                 creal32_T *anew,          /* Intermediate AR coeffients */
                                 creal32_T *Acoef,         /* A - Output pointer */
                                 real32_T  *Error
                           ); 

DSPBURG_EXPORT void MWDSP_Burg_AK_D(const int_T   N,             /* Input array length */
                            const int_T   order,         /* Order of estimation */
                            const real_T *u,                /* Input pointer */
                                  real_T *ef,               /* Intermediate variable */
                                  real_T *eb,               /* Intermediate variable */
                                  real_T *anew,             /* Intermediate AR coeffients */
                                  real_T *Acoef,            /* A - Output pointer */
                                  real_T *Kcoef,            /* A - Output pointer */
                                  real_T *Error
                            );
DSPBURG_EXPORT void MWDSP_Burg_AK_R(const int_T     N,             /* Input array length */
                            const int_T     order,         /* Order of estimation */
                            const real32_T *u,           /* Input pointer */
                                  real32_T *ef,          /* Intermediate variable */
                                  real32_T *eb,          /* Intermediate variable */
                                  real32_T *anew,        /* Intermediate AR coeffients */
                                  real32_T *Acoef,       /* A - Output pointer */
                                  real32_T *Kcoef,       /* A - Output pointer */
                                  real32_T *Error
                            );
DSPBURG_EXPORT void MWDSP_Burg_AK_Z(const int_T    N,             /* Input array length */
                            const int_T    order,         /* Order of estimation */
                            const creal_T *u,             /* Input pointer */
                                  creal_T *ef,            /* Intermediate variable */
                                  creal_T *eb,            /* Intermediate variable */
                                  creal_T *anew,          /* Intermediate AR coeffients */
                                  creal_T *Acoef,         /* A - Output pointer */
                                  creal_T *Kcoef,         /* A - Output pointer */
                                  real_T  *Error
                            );
DSPBURG_EXPORT void MWDSP_Burg_AK_C(const int_T      N,             /* Input array length */
                            const int_T      order,         /* Order of estimation */
                            const creal32_T *u,             /* Input pointer */
                                  creal32_T *ef,            /* Intermediate variable */
                                  creal32_T *eb,            /* Intermediate variable */
                                  creal32_T *anew,          /* Intermediate AR coeffients */
                                  creal32_T *Acoef,         /* A - Output pointer */
                                  creal32_T *Kcoef,         /* A - Output pointer */
                                  real32_T  *Error
                            );

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspburg/burg_a_c_rt.c"
#include "dspburg/burg_a_d_rt.c"
#include "dspburg/burg_a_r_rt.c"
#include "dspburg/burg_a_z_rt.c"
#include "dspburg/burg_ak_c_rt.c"
#include "dspburg/burg_ak_d_rt.c"
#include "dspburg/burg_ak_r_rt.c"
#include "dspburg/burg_ak_z_rt.c"
#include "dspburg/burg_k_c_rt.c"
#include "dspburg/burg_k_d_rt.c"
#include "dspburg/burg_k_r_rt.c"
#include "dspburg/burg_k_z_rt.c"
#endif

#endif /* dspburg_rt_h */

/* [EOF] dspburg_rt.h */
