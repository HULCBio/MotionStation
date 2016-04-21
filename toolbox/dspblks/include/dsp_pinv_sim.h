/* $Revision: 1.2 $ */
/* 
 *  DSP_PINV_SIM  
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef dsp_pinv_sim_h
#define dsp_pinv_sim_h

#include "dsp_rt.h"

/* DSPSIM_PINVArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 */ 

typedef struct {
    const void *pA;             /* Input poiner */
          void *pX;             /* temp work area */
          void *pS;             /* output pointer for S in svd */
          void *pU;             /* output pointer for U */
          void *pV;             /* output pointer for V */
          void *pe;             /* temp space for svd */
          void *pO;             /* output pointer */
          void *pwork;          /* temp space for svd */
          int_T M;              /* Rows in input */
          int_T N;              /* columns in input */
} DSPSIM_PINVArgsCache;

typedef int_T (*PINVFcn)(DSPSIM_PINVArgsCache *args);

typedef struct {
    DSPSIM_PINVArgsCache args;
    PINVFcn              PINVFcnPtr; /* Pointer to rt-function */
} SFcnCache;

/* 
 * Function naming glossary 
 * --------------------------- 
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
 * DSPSIM_PINV_<DataType>
 *
 * 1) DSPSIM is a prefix used with DSP simulation helper functions
 * 1) The second field indicates that this function is used in implementing the
 *    Pseudo inverse algorithm. 
 * 2) The third field is a string indicating the nature of the data type
 *
 */

extern int_T DSPSIM_PINV_D(DSPSIM_PINVArgsCache *args);
extern int_T DSPSIM_PINV_R(DSPSIM_PINVArgsCache *args);
extern int_T DSPSIM_PINV_Z(DSPSIM_PINVArgsCache *args);
extern int_T DSPSIM_PINV_C(DSPSIM_PINVArgsCache *args);

#endif /* dsp_pinv_sim_h */

/* [EOF] dsp_pinv_sim.h */
