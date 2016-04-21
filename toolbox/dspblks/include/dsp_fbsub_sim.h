/* $Revision: 1.3 $ */
/* 
 *  DSP_FBSUB_SIM Simulation mid-level functions for DSP Blockset 
 *  Forward/Backward Substitution blocks. 
 * 
 *  Solves LX = B where L is a lower (or unit-lower) triangular matrix.
 *  Solves UX = B where U is a upper (or unit-upper) triangular matrix.
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *
 */ 

#ifndef dsp_fbsub_sim_h
#define dsp_fbsub_sim_h

/* MWDSP_FSubArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 */ 

typedef struct {
    int_T             P;     /* Number of RHS in B*/
    const void    *inlu;     /* Input data pointer for matrix L*/
    const void     *inb;     /* Input data pointer for RHS B*/
    void           *out;     /* Output pointer - solutions */
    int_T             N;     /* Dimension of matrix L*/
} FBSubArgsCache;

/*
 * Function naming convention
 * ---------------------------
 *
 * (F/B)Sub_<Unit-lower>_<L-DataType><B-DataType>_<X-DataType>
 *
 * 1) The second field indicates that this function is implementing the Forward
 *    Substitution algorithm for solving the equation LX = B where L is
 *    a lower triangular matrix.
 * 2) The third filed indicates whether the input is a unit-lower
 *    triangular matrix.
 *    U - unit-lower, NU - not unit-lower
 * 3) The fourth field indicates the DataTypes of the inputs.
 *    Namely the lower triangular matrix L, and the RHS columns B.
 *    The first letter indicates the data type of L and the second
 *    letter indicates data type of B.
 * 4) The fifth field indicates the DataType of the output.
 *
 * For example FSub_NU_DZ_Z takes input real double matrix L,
 * complex double RHS value B and gives complex double as output
 * assuming input as not unit-lower.
 *
 */

extern void FSub_U_DD_D(FBSubArgsCache *args);
extern void FSub_U_DZ_Z(FBSubArgsCache *args);
extern void FSub_U_ZD_Z(FBSubArgsCache *args);
extern void FSub_U_ZZ_Z(FBSubArgsCache *args);
extern void FSub_NU_DD_D(FBSubArgsCache *args);
extern void FSub_NU_DZ_Z(FBSubArgsCache *args);
extern void FSub_NU_ZD_Z(FBSubArgsCache *args);
extern void FSub_NU_ZZ_Z(FBSubArgsCache *args);
extern void FSub_U_RR_R(FBSubArgsCache *args);
extern void FSub_U_RC_C(FBSubArgsCache *args);
extern void FSub_U_CR_C(FBSubArgsCache *args);
extern void FSub_U_CC_C(FBSubArgsCache *args);
extern void FSub_NU_RR_R(FBSubArgsCache *args);
extern void FSub_NU_RC_C(FBSubArgsCache *args);
extern void FSub_NU_CR_C(FBSubArgsCache *args);
extern void FSub_NU_CC_C(FBSubArgsCache *args);
extern void BSub_U_DD_D(FBSubArgsCache *args);
extern void BSub_U_DZ_Z(FBSubArgsCache *args);
extern void BSub_U_ZD_Z(FBSubArgsCache *args);
extern void BSub_U_ZZ_Z(FBSubArgsCache *args);
extern void BSub_NU_DD_D(FBSubArgsCache *args);
extern void BSub_NU_DZ_Z(FBSubArgsCache *args);
extern void BSub_NU_ZD_Z(FBSubArgsCache *args);
extern void BSub_NU_ZZ_Z(FBSubArgsCache *args);
extern void BSub_U_RR_R(FBSubArgsCache *args);
extern void BSub_U_RC_C(FBSubArgsCache *args);
extern void BSub_U_CR_C(FBSubArgsCache *args);
extern void BSub_U_CC_C(FBSubArgsCache *args);
extern void BSub_NU_RR_R(FBSubArgsCache *args);
extern void BSub_NU_RC_C(FBSubArgsCache *args);
extern void BSub_NU_CR_C(FBSubArgsCache *args);
extern void BSub_NU_CC_C(FBSubArgsCache *args);

#endif  /* dsp_fbsub_sim_h */

/* [EOF] dsp_fbsub_sim.h */
