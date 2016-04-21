/* $Revision: 1.4.4.2 $ */
/* 
 *  DSPFBSUB_RT Runtime functions for DSP Blockset Forward/Backward Substitution block. 
 * 
 *  Solves LX = B(UX=B) where L(U) is a lower(upper)
 *  (or unit-lower(upper)) triangular matrix.
 * 
 *  Copyright 1995-2003 The MathWorks, Inc.
 *
 */ 

#ifndef dspfbsub_rt_h
#define dspfbsub_rt_h

#include "dsp_rt.h"

#ifdef DSPFBSUB_EXPORTS
#define DSPFBSUB_EXPORT EXPORT_FCN
#else
#define DSPFBSUB_EXPORT MWDSP_IDECL
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
 * MWDSP_FSub_<Unit-lower>_<L-DataType><B-DataType>_<X-DataType>
 *
 * 1) MWDSP is a prefix used with all Mathworks DSP runtime library functions
 * 2) The second field indicates that this function is implementing the Forward
 *    Substitution algorithm for solving the equation LX = B where L is
 *    a lower triangular matrix.
 * 3) The third filed indicates whether the input is a unit-lower
 *    triangular matrix.
 *    U - unit-lower, NU - not unit-lower
 * 4) The fourth field indicates the DataTypes of the inputs.
 *    Namely the lower triangular matrix L, and the RHS columns B.
 *    The first letter indicates the data type of L and the second
 *    letter indicates data type of B.
 * 5) The fifth field indicates the DataType of the output.
 *
 * For example MWDSP_FSub_NU_DZ_Z takes input real double matrix L,
 * complex double RHS value B and gives complex double as output
 * assuming input as not unit-lower.
 *
 */

/* Backward Substitution*/
/* Double Precision */
DSPFBSUB_EXPORT void MWDSP_BSub_NU_DD_D(
        const real_T *pU,
        const real_T *pb,
              real_T  *x,
        const int_T    N,
        const int_T    P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_DZ_Z(
        const real_T  *pU,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_ZD_Z(
        const creal_T *pU,
        const real_T  *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_ZZ_Z(
        const creal_T *pU,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_DD_D(
        const real_T *pU,
        const real_T *pb,
              real_T  *x,
        const int_T    N,
        const int_T    P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_DZ_Z(
        const real_T  *pU,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_ZD_Z(
        const creal_T *pU,
        const real_T  *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_ZZ_Z(
        const creal_T *pU,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );


/* Backward Substitution*/
/* Single Precision */
DSPFBSUB_EXPORT void MWDSP_BSub_NU_CC_C(
        const creal32_T *pU,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_CR_C(
        const creal32_T *pU,
        const real32_T  *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_RC_C(
        const real32_T  *pU,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_NU_RR_R(
        const real32_T *pU,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_CC_C(
        const creal32_T *pU,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_CR_C(
        const creal32_T *pU,
        const real32_T  *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_RC_C(
        const real32_T  *pU,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_BSub_U_RR_R(
        const real32_T *pU,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        );


/* Forward Substitution*/
/* Double Precision */
DSPFBSUB_EXPORT void MWDSP_FSub_NU_DD_D(
        const real_T *pL,
        const real_T *pb,
              real_T  *x,
        const int_T    N,
        const int_T    P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_DZ_Z(
        const real_T  *pL,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_ZD_Z(
        const creal_T *pL,
        const real_T  *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_ZZ_Z(
        const creal_T *pL,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_DD_D(
        const real_T  *pL,
        const real_T  *pb,
              real_T   *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_DZ_Z(
        const real_T  *pL,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_ZD_Z(
        const creal_T *pL,
        const real_T  *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_ZZ_Z(
        const creal_T *pL,
        const creal_T *pb,
              creal_T  *x,
        const int_T     N,
        const int_T     P
        );

/* Forward Substitution*/
/* Single Precision */
DSPFBSUB_EXPORT void MWDSP_FSub_NU_CC_C(
        const creal32_T *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_CR_C(
        const creal32_T *pL,
        const real32_T  *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_RC_C(
        const real32_T  *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_NU_RR_R(
        const real32_T *pL,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_CC_C(
        const creal32_T *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_CR_C(
        const creal32_T *pL,
        const real32_T  *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_RC_C(
        const real32_T  *pL,
        const creal32_T *pb,
              creal32_T  *x,
        const int_T       N,
        const int_T       P
        );
DSPFBSUB_EXPORT void MWDSP_FSub_U_RR_R(
        const real32_T *pL,
        const real32_T *pb,
              real32_T  *x,
        const int_T      N,
        const int_T      P
        );

#ifdef MWDSP_INLINE_DSPRTLIB
#include "dspfbsub/bsub_nu_cc_c_rt.c"
#include "dspfbsub/bsub_nu_cr_c_rt.c"
#include "dspfbsub/bsub_nu_dd_d_rt.c"
#include "dspfbsub/bsub_nu_dz_z_rt.c"
#include "dspfbsub/bsub_nu_rc_c_rt.c"
#include "dspfbsub/bsub_nu_rr_r_rt.c"
#include "dspfbsub/bsub_nu_zd_z_rt.c"
#include "dspfbsub/bsub_nu_zz_z_rt.c"
#include "dspfbsub/bsub_u_cc_c_rt.c"
#include "dspfbsub/bsub_u_cr_c_rt.c"
#include "dspfbsub/bsub_u_dd_d_rt.c"
#include "dspfbsub/bsub_u_dz_z_rt.c"
#include "dspfbsub/bsub_u_rc_c_rt.c"
#include "dspfbsub/bsub_u_rr_r_rt.c"
#include "dspfbsub/bsub_u_zd_z_rt.c"
#include "dspfbsub/bsub_u_zz_z_rt.c"
#include "dspfbsub/fsub_nu_cc_c_rt.c"
#include "dspfbsub/fsub_nu_cr_c_rt.c"
#include "dspfbsub/fsub_nu_dd_d_rt.c"
#include "dspfbsub/fsub_nu_dz_z_rt.c"
#include "dspfbsub/fsub_nu_rc_c_rt.c"
#include "dspfbsub/fsub_nu_rr_r_rt.c"
#include "dspfbsub/fsub_nu_zd_z_rt.c"
#include "dspfbsub/fsub_nu_zz_z_rt.c"
#include "dspfbsub/fsub_u_cc_c_rt.c"
#include "dspfbsub/fsub_u_cr_c_rt.c"
#include "dspfbsub/fsub_u_dd_d_rt.c"
#include "dspfbsub/fsub_u_dz_z_rt.c"
#include "dspfbsub/fsub_u_rc_c_rt.c"
#include "dspfbsub/fsub_u_rr_r_rt.c"
#include "dspfbsub/fsub_u_zd_z_rt.c"
#include "dspfbsub/fsub_u_zz_z_rt.c"
#endif

#endif /* dspfbsub_rt_h */

/* [EOF] dspfbsub_rt.h */
