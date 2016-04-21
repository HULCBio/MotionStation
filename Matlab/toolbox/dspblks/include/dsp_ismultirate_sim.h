/*
 * dsp_ismultirate_sim.h
 *
 * DSP Blockset helper function.
 *
 * Check if a block is multirate.
 *
 * If any port has a different sample time,
 * then a block is considered multirate.
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:11:26 $
 */

#ifndef dsp_ismultirate_sim_h
#define dsp_ismultirate_sim_h

#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif


DSP_COMMON_SIM_EXPORT boolean_T isInputMultiRate(SimStruct *S, int_T numIn);
DSP_COMMON_SIM_EXPORT boolean_T isOutputMultiRate(SimStruct *S, int_T numOut);
DSP_COMMON_SIM_EXPORT boolean_T isBlockMultiRate(SimStruct *S, int_T numIn, int_T numOut);
DSP_COMMON_SIM_EXPORT boolean_T isModelMultiTasking(SimStruct *S);

#endif /* dsp_ismultirate_sim_h */

/* [EOF] dsp_ismultirate_sim.h */
