/*
 * dsp_iir_sim - DSP Blockset IIR Filter simulation support
 *
 *  Copyright 1995-2002 The MathWorks, Inc.
 *  $Revision: 1.6 $  $Date: 2002/04/14 20:36:33 $
 */

#ifndef dsp_iir_sim_h
#define dsp_iir_sim_h

#include "dsp_filtstruct_sim.h" /* contains definition of const DSPSIM_FilterArgsCache */
#include "dspiir_rt.h"          /* contains IIR filter run-time functions */

/*** IIR Filter Simulation Functions: ***/
/* DF2T functions: */
/* IIR DF2T Filter structure implementation (assumes 1st deno. coeff. to be unity) */
extern void DSPSIM_IIR_DF2T_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF1T Filter structure implementation (assumes 1st deno. coeff. to be unity) */
extern void DSPSIM_IIR_DF1T_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF2 Filter structure implementation (assumes 1st deno. coeff. to be unity) */
extern void DSPSIM_IIR_DF2_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF1 Filter structure implementation (assumes 1st deno. coeff. to be unity) */
extern void DSPSIM_IIR_DF1_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF2T Filter structure implementation 
 * Assumes 1st deno. coeff. to be non-unity and includes the appropriate scale
 * 1/a0 in the filter structure to account for the non-unity first den. coeff. 
 */
extern void DSPSIM_IIR_DF2T_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2T_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF1T Filter structure implementation 
 * Assumes 1st deno. coeff. to be non-unity and includes the appropriate scale
 * 1/a0 in the filter structure to account for the non-unity first den. coeff. 
 */
extern void DSPSIM_IIR_DF1T_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1T_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF2 Filter structure implementation 
 * Assumes 1st deno. coeff. to be non-unity and includes the appropriate scale
 * 1/a0 in the filter structure to account for the non-unity first den. coeff. 
 */
extern void DSPSIM_IIR_DF2_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF2_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

/* IIR DF1 Filter structure implementation 
 * Assumes 1st deno. coeff. to be non-unity and includes the appropriate scale
 * 1/a0 in the filter structure to account for the non-unity first den. coeff. 
 */
extern void DSPSIM_IIR_DF1_A0Scale_DD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_DZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_ZD(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_ZZ(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_RR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_RC(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_CR(const DSPSIM_FilterArgsCache *args);
extern void DSPSIM_IIR_DF1_A0Scale_CC(const DSPSIM_FilterArgsCache *args);

#endif /* dsp_iir_sim_h */

/* [EOF] dsp_iir_sim.h */
