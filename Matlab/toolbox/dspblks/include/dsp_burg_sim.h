/* 
 *  DSP_BURG_SIM Simulation support functions for DSP Blockset 
 *  Burg AR Estimator block. 
 * 
 *  Estimates AR coefficients for the given input signal using Burg method.
 * 
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.2 $  $Date: 2002/04/14 20:37:41 $ 
 */ 

#ifndef dsp_burg_sim_h
#define dsp_burg_sim_h

#include "dsp_rt.h"

/* MWDSP_BurgArgsCache is a structure used to contain parameters/arguments 
 * for each of the individual runtime functions listed below. 
 * 
 * Note that not all members of this structure have to be defined 
 * for every runtime function.  Please refer to the description in the 
 * comments before each function prototype for more specific details. 
 */ 

typedef struct {
    int_T       order;        /* AR burg estimator order  */
    int_T       N;            /* Input data dimension*/
    void       *Acoef;        /* AR coefficients -- output */
    void       *Kcoef;        /* Reflection coefficients -- output */
    void       *E;            /* Prediction Error -- output */
    const void *in;           /* Input data pointer */
    void       *anew;         /* Storage space for intermediate AR coeffients */
    void       *ferr;         /* Storage space for forward error */
    void       *berr;         /* Storage space for backward error */
} MWDSP_BurgArgsCache;


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
 * Burg_<outputoption>_<DataType>
 *
 * 1) The first field indicates that this function is implementing the Burg
 *    algorithm. 
 * 2) The second field is a string indicating the nature of the output options
 *
 *      K   - Only reflection coefficients are sent to output.
 *            This represents output option "K" only.
 *      A   - Only prediction coefficients are sent to output.
 *            This represents output option "A" only.
 *      AK  - Refelction and prediction coefficients are sent to output.
 *            This represents output option "A and K".
 *
 *            In the functions with second field "A" the args cache member
 *      variable RCcoef will not be used. This variable would not have
 *      been initialized in this case.
 *
 *            In the functions with second field "K" the args cache member
 *      variable Acoef will not be used. This variable would not have
 *      been initialized in this case.
 */

extern void Burg_K_D(MWDSP_BurgArgsCache *args);
extern void Burg_K_R(MWDSP_BurgArgsCache *args);
extern void Burg_K_Z(MWDSP_BurgArgsCache *args);
extern void Burg_K_C(MWDSP_BurgArgsCache *args);

extern void Burg_A_D(MWDSP_BurgArgsCache *args);
extern void Burg_A_R(MWDSP_BurgArgsCache *args);
extern void Burg_A_Z(MWDSP_BurgArgsCache *args);
extern void Burg_A_C(MWDSP_BurgArgsCache *args);

extern void Burg_AK_D(MWDSP_BurgArgsCache *args);
extern void Burg_AK_R(MWDSP_BurgArgsCache *args);
extern void Burg_AK_Z(MWDSP_BurgArgsCache *args);
extern void Burg_AK_C(MWDSP_BurgArgsCache *args);

#endif /* dsp_burg_sim_h */

/* [EOF] dsp_burg_sim.h */

