/* $Revision: 1.2 $ */
/* 
 *  DSP_SVD_SIM  Economy-sized Singular Value Decomposition
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 */

#ifndef dsp_svd_sim_h
#define dsp_svd_sim_h

#include "dsp_rt.h"

/* DSPSIM_SVDArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 * 
 * Note that not all members of this structure have to be defined 
 * for every runtime function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 

typedef struct {
    const void *pA;             /* Input poiner */
          void *pX;             /* temp work area */
          void *pS;
          void *pU;             /* output pointer for U */
          void *pV;             /* output pointer for V */
          void *pe;
          void *pOS;            /* output pointer for S */
          void *pwork;
          int_T M;              /* Rows in input */
          int_T N;              /* columns in input */
          int_T Mnew;           /* rows in input if M >= N */
          int_T Nnew;           /* columns in input if M >= N */
          int_T wantv;          /* whether U and V are required */
} DSPSIM_SVDArgsCache;


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
 * DSPSIM_SVD_<DataType>
 *
 * 1) DSPSIM is a prefix used with DSP simulation helper functions
 * 1) The first field indicates that this function is implementing the SVD
 *    algorithm. 
 * 2) The second field is a string indicating the nature of the data type
 *
 */

extern int_T DSPSIM_SVD_D(DSPSIM_SVDArgsCache *args);
extern int_T DSPSIM_SVD_R(DSPSIM_SVDArgsCache *args);
extern int_T DSPSIM_SVD_Z(DSPSIM_SVDArgsCache *args);
extern int_T DSPSIM_SVD_C(DSPSIM_SVDArgsCache *args);

#endif /* dsp_svd_sim_h */

/* [EOF] dsp_svd_sim.h */
