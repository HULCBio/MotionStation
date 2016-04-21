/* $Revision: 1.3 $ */
/* 
 *  DSP_CHOL_SIM Simulation mid-level functions for DSP Blockset 
 *  Cholesky factorization
 * 
 * Decomposes input matrix A into LL' where L is lower triangular.
 * 
 * Copyright 1995-2002 The MathWorks, Inc.
 *
 */ 

#ifndef dsp_chol_sim_h
#define dsp_chol_sim_h

/* CholArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 */ 

typedef struct {
    void      *out;     /* Pointer for input matrix A */
    int_T        N;     /* Dimension of input matrix A */
} CholArgsCache;

/* 
 * Function naming glossary 
 * --------------------------- 
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
 * Chol_B_<DType>
 *
 * 1) The first field indicates that this function is implementing the 
 *    Cholesky factorization algorithm for decomposing a positive definite matrix
 *    A into LL' where L is a lower triangular matrix.
 * 2) The second field indicates that the run-time function returns a boolean
 *    indicating the positive definiteness of the input.
 *    Note that this is indicated specifically to differentiate these functions
 *    from run-time functions which return void.
 * 3) The third field indicates the DataType of the input and output.
 *
 * For example Chol_B_Z takes input complex double matrix A,
 * and gives complex double as output and returns a boolean indicating the
 * positive definiteness of the input matrix.
 *
 */

extern boolean_T Chol_B_D(CholArgsCache *args);
extern boolean_T Chol_B_Z(CholArgsCache *args);
extern boolean_T Chol_B_R(CholArgsCache *args);
extern boolean_T Chol_B_C(CholArgsCache *args);

#endif  /* dsp_chol_sim_h */

/* [EOF] dsp_chol_sim.h */
