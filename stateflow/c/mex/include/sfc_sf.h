/*
 *   SFC_SF.H  Stateflow S-Function header file.
 *
 *   Copyright 1995-2004 The MathWorks, Inc.
 *
 *   $Revision: 1.18.4.8 $  $Date: 2004/04/14 23:54:47 $
 */

#ifndef _SFC_SF_H_
#define _SFC_SF_H_


#ifndef FORCE_S_FUNCTION_LEVEL_ONE
#define S_FUNCTION_LEVEL 2
#endif

#if S_FUNCTION_LEVEL==2
#define MDL_RTW
#define MDL_INITIALIZE_CONDITIONS
#define MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#define MDL_DISABLE
#define MDL_ENABLE
#define MDL_START
#endif



#include <math.h>
#include "simstruc.h"

#include "mex.h"
#define real_T double
#define int_T int

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*VoidFunctionPtr)( void * chartInstance);

typedef struct {
	unsigned int isEMLChart;
	void				*chartInstance;
	char sFunctionName[mxMAXNAM];
	unsigned int chartInitialized;
	void (*sFunctionGateway)(void *chartInstance);
	void (*restoreLastMajorStepConfiguration)  (void *chartInstance);
	void (*restoreBeforeLastMajorStepConfiguration)  (void *chartInstance);
	void (*storeCurrentConfiguration)  (void *chartInstance);
	void (*initializeChart) (void* chartInstance);
	void (*terminateChart) (void *chartInstance);
	void (*enableChart) (void *chartInstance);
	void (*disableChart) (void *chartInstance);
	void (*mdlRTW)(SimStruct *S);
	void (*mdlSetWorkWidths)(SimStruct *S);
	void (*mdlStart)(SimStruct *S);
} ChartInfoStruct; 

extern BuiltInDTypeId sf_get_sl_type_from_ml_type(mxClassID mlType);

extern void mdlInitializeSizes(SimStruct *S);
extern void mdlInitializeSampleTimes(SimStruct *S);
extern void mdlTerminate(SimStruct * S);
extern void mdlInitializeConditions(SimStruct *S);
extern void mdlOutputs(SimStruct *S, int_T tid);
extern void mdlRTW(SimStruct *S);
extern void mdlSetWorkWidths(SimStruct *S);
extern void mdlEnable(SimStruct *S);
extern void mdlDisable(SimStruct *S);
extern void mdlStart(SimStruct *S);


extern unsigned int sf_is_chart_inlinable(const char *machineName,
								   unsigned int chartFileNumber);
extern unsigned int sf_is_chart_instance_optimized_out(const char *machineName,
								                unsigned int chartFileNumber);

extern void sf_mark_chart_reusable_outputs(SimStruct *S,
                                           const char *machineName,
								           unsigned int chartFileNumber,
								           unsigned numOutputData);
extern void sf_mark_chart_expressionable_inputs(SimStruct *S, 
                                         const char *machineName,
										unsigned int chartFileNumber,
										unsigned numInputData);
extern char *sf_chart_instance_typedef_name(const char *machineName,
								   unsigned int chartFileNumber);
extern unsigned int sim_mode_is_rtw_gen(SimStruct *S);
extern DTypeId sf_get_fixpt_data_type_id(SimStruct *S,
                                  int baseType,
                                  int exponent,
                                  double slope,
                                  double bias);

extern unsigned int sf_mex_listen_for_ctrl_c(SimStruct *S);
extern unsigned int sf_mex_listen_for_ctrl_c_force(SimStruct *S);
extern mxArray *sf_mex_get_sfun_param(SimStruct *S, int_T paramIndex);
extern unsigned int sf_is_chart_multi_instanced(const char *machineName,
								   unsigned int chartFileNumber);
extern void sf_call_output_fcn_call(SimStruct *S, 
							 int eventIndex, 
							 const char *eventName,
							 int checkForInitialization);
extern void sf_clear_rtw_identifier(SimStruct *S);
extern void sf_set_rtw_identifier(SimStruct *S);
extern void sf_write_symbol_mapping(SimStruct *S, 
							 const char *machineName,
							 unsigned int chartFileNumber);
extern void sf_call_output_fcn_enable(SimStruct *S, 
							 int eventIndex, 
							 const char *eventName,
                             int checkForInitialization);
extern void sf_call_output_fcn_disable(SimStruct *S, 
							 int eventIndex, 
							 const char *eventName,
                             int checkForInitialization);


#define SF_SIM_RUNNING 0
#define SF_SIM_STOPPED 1
#define SF_SIM_PAUSED 2

/* work around the buggy macro in simstruc.h until it is fixed */
#define cdrGetOutputPortReusable(S,port) \
  ( (S)->portInfo.outputs[(port)].attributes.optimOpts != \
   SS_NOT_REUSABLE_AND_GLOBAL )


#ifdef __cplusplus
}
#endif

#endif

