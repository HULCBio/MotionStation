/*
 * dsp_ts_sim.h
 *
 * DSP Blockset helper function.
 *
 * Query input/output port sample time information.
 *
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:11:36 $
 */

#ifndef dsp_ts_sim_h
#define dsp_ts_sim_h

#include "simstruc.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif


/*--------------------------------------------------------------
 * BLOCK: SAMPLE TIME INHERITED
 */

DSP_COMMON_SIM_EXPORT boolean_T isBlockTsInherited(SimStruct *S, int_T sti);

/*--------------------------------------------------------------
 * BLOCK: CONTINUOUS SAMPLE TIME
 * Includes continuous (0) and variable sample times (-2). 
 */

DSP_COMMON_SIM_EXPORT boolean_T isBlockContinuous(SimStruct *S, int_T sti);

/*--------------------------------------------------------------
 * BLOCK: DISCRETE SAMPLE TIME
 */

DSP_COMMON_SIM_EXPORT boolean_T isBlockDiscrete(SimStruct *S, int_T sti);

/*--------------------------------------------------------------
 * PORT-BASED:
 */

DSP_COMMON_SIM_EXPORT boolean_T areAllInputPortsDiscreteSampleTime(SimStruct *S);

DSP_COMMON_SIM_EXPORT boolean_T areAllInputPortsContOrConstSampleTime(SimStruct *S);

DSP_COMMON_SIM_EXPORT boolean_T areAllInputPortsSameBehaviorSampleTime(SimStruct *S);

/*--------------------------------------------------------------
 * OFFSET
 */


#endif /* dsp_ts_sim_h */

/* [EOF] dsp_ts_sim.h */
