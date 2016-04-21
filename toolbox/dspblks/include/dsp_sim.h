/*
 *  dsp_sim.h
 *  CMEX S-Fcn simulation support library for DSP Blockset
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.27.4.3 $ $Date: 2004/04/12 23:11:34 $
 */

#ifndef dsp_sim_h
#define dsp_sim_h

/* The following file has simulation-platform-specific
 * compiler flag magic.  It also includes "tmwtypes.h".
 * Include this file FIRST before including anything else,
 * otherwise if tmwtypes.h is included later it may not
 * contain the right compiler flag magic...
 */
#include "version.h"

#ifdef DSP_SIM_COMMON_EXPORTS
#define DSP_COMMON_SIM_EXPORT EXPORT_FCN
#else
#define DSP_COMMON_SIM_EXPORT extern
#endif

#ifdef __cplusplus
#include <complex>
using namespace std;
#include "dsp_math.hpp"
#endif

/* DSP Blockset runtime support is C only,
 * hence this file is NOT in the 'extern "C"'
 */
#define  MWDSPSIMONLY_DO_NOT_INCLUDE_RTWTYPES_H
#include "dsp_rt.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Common simulation-only support functions */
#include "simstruc.h"              /* Simulink (simulation-only) support API  */
#include "dsp_sfcn_param_sim.h"    /* DSP Blockset S-fcn parameter handling   */
#include "dsp_ts_err.h"            /* DSP Blockset S-fcn sample time support  */
#include "dsp_ismultirate_sim.h"   /* DSP Blockset S-fcn multi-rate support   */
#include "dsp_mtrx_err.h"          /* DSP Blockset S-fcn matrix/frame support */
#include "dsp_cplx_err.h"          /* DSP Blockset S-fcn complexity support   */
#include "dsp_dtype_err.h"         /* DSP Blockset S-fcn data type support    */
#include "dsp_fixpt_err.h"         /* DSP Blockset S-fcn fixed-point support  */
#include "dsp_rtp_sim.h"           /* DSP Blockset S-fcn Run Time Param sppt  */
#include "dsp_dtype_convert_sim.h" /* DSP Blockset S-fcn data type conversion */

/*
 * ----------------------------------------------------------
 * Error handling within DSP Blockset
 * ----------------------------------------------------------
 */
#define THROW_ERROR(S,MSG) {ssSetErrorStatus(S,MSG); return;}
#define ANY_ERRORS(S)      (ssGetErrorStatus(S) != NULL)
#define RETURN_IF_ERROR(S) {if (ANY_ERRORS(S)) return;}

/*
 * ----------------------------------------------------------
 * DWork handling for non-built-in datatypes
 * ----------------------------------------------------------
 */
#define DspSetDWorkUsedAsDState(S, DWORK_INDEX, USAGE_ENUM)             \
    if ((ssGetDWorkDataType(S, DWORK_INDEX)) < SS_NUM_BUILT_IN_DTYPE) { \
       ssSetDWorkUsedAsDState(S, DWORK_INDEX, USAGE_ENUM);              \
    } else {                                                            \
       ssSetDWorkUsedAsDState(S, DWORK_INDEX, SS_DWORK_USED_AS_DWORK);  \
    }

/*
 * S-fcn parameter setup/registration (source located in dsp_sim.c):
 */
DSP_COMMON_SIM_EXPORT boolean_T registerSFunctionParams(SimStruct *S, int_T numParams);

/*
 * Use the following as the first line in mdlInitializeSizes(), eg:
 *
 *  static void mdlInitializeSizes(SimStruct *S)
 *  {
 *      REGISTER_SFCN_PARAMS(S, NUM_ARGS)
 *      ...
 *  }
 */
#define REGISTER_SFCN_PARAMS(S, numParams) {if(!registerSFunctionParams(S, numParams)) return;}

/* Use the following to determine:
 *
 * 1) If Simulink/RTW are currently in the initial phases of code generation
 *    (i.e. running portions of the S-function prior to generating code)
 *
 * OR
 *
 * 2) If Simulink is currently running portions of the S-function for
 *    modes other than RTW code generation (i.e. simulation or sizes calls only).
 *
 * NOTE: This is NOT the same as using MATLAB_MEX_FILE.
 */
#define SL_SFCN_IN_RTW_CODEGEN_MODES(S)     ((boolean_T)((ssGetSimMode(S) == SS_SIMMODE_RTWGEN) || (ssGetSimMode(S) == SS_SIMMODE_EXTERNAL)))
#define SL_SFCN_NOT_IN_RTW_CODEGEN_MODES(S) ((boolean_T)((ssGetSimMode(S) == SS_SIMMODE_NORMAL) || (ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY)))

/* Checking if input and output ARE sharing memory space */
#define INPORT_AND_OUTPORT_SHARE_BUFFER(S,inPortIdx,outPortIdx) \
        (boolean_T)(ssGetInputPortBufferDstPort(S,inPortIdx) == outPortIdx)

/*
 * Memory allocation for Simulink S-Functions
 *
 * These functions force the allocation to be persistent,
 * so that MATLAB does not release the allocation when
 * the function that allocates the memory returns.
 *
 * For example, if you called mxCalloc during mdlStart,
 * then at the exit of mdlStart Simulink will free the memory.
 * Thus, if you attempt to use the memory pointer during
 * mdlOutputs, you will be accessing unallocated memory.
 * All C-MEX S-Functions should only call slCalloc/slFree.
 */
DSP_COMMON_SIM_EXPORT void *slCalloc(
	SimStruct *S,
	const int_T count,
	const int_T size);

DSP_COMMON_SIM_EXPORT void *slMalloc(
	SimStruct *S,
	const int_T size);

DSP_COMMON_SIM_EXPORT void slFree(void *ptr);


/* helper function used by a few S-Functions to get the next power of 2 */
DSP_COMMON_SIM_EXPORT int_T getNextPow2(int_T inValue);

/*
 * ----------------------------------------------------------
 * SFcnCache macros
 * ----------------------------------------------------------
 */
#define GetSFcnCache(S, SFcnCache) ((SFcnCache *)ssGetUserData(S))

#define CallocSFcnCache(S, SFcnCache) (ssSetUserData(S, slCalloc(S,1,sizeof(SFcnCache))))

#define FreeSFcnCache(S, SFcnCache) \
{                                   \
    slFree(ssGetUserData(S));       \
    ssSetUserData(S, NULL);         \
}


#ifdef __cplusplus
}
#endif

#endif  /* dsp_sim_h */

/* [EOF] dsp_sim.h */
