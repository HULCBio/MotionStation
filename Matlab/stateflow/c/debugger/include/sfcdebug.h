/*
 *   SFCDEBUG.H  Stateflow debugger API header file.
 *
 *   Copyright 1995-2004 The MathWorks, Inc.
 *
 *   $Revision: 1.25.4.7 $  $Date: 2004/04/14 23:54:41 $
 */


#include <setjmp.h>
#include "mex.h"
#include "tmwtypes.h"
#include "../../mex/include/sfc_mex.h"

#ifndef SF_DEBUG_H
#define SF_DEBUG_H

#define UNREASONABLE_NUMBER 999999
#define SF_MAX_CALL_STACK_SIZE 1000

typedef enum {
	OR_STATE, 
	AND_STATE, 
	FUNC_STATE, 
	GROUP_STATE 
} SfStateType;


typedef enum {
	CLUSTER_STATE, 
	SET_STATE
} SfDecomposition;

#ifndef CV_EML_CHECK_TYPE_DEF
#define CV_EML_CHECK_TYPE_DEF

typedef enum {
    CV_EML_FCN_CHECK = 0,
    CV_EML_IF_CHECK,
    CV_EML_FOR_CHECK,
    CV_EML_WHILE_CHECK,
    CV_EML_COND_CHECK,
    CV_EML_MCDC_CHECK,
    CV_EML_SWITCH_CHECK,
    CV_EML_CHECK_CNT
}SfCvEmlCheckType;

#endif

typedef enum {
	 MACHINE_OBJECT=0
	,CHART_OBJECT=1
	,TARGET_OBJECT=2
	,INSTANCE_OBJECT=3
	,STATE_OBJECT=4
	,TRANSITION_OBJECT=5
	,JUNCTION_OBJECT=6
	,EVENT_OBJECT=7
	,DATA_OBJECT=8
	,SIMDATA_OBJECT=9
	,NOTE_OBJECT=10
	,UNDO_OBJECT=11
	,ERROR_OBJECT=12
	,NULL_OBJECT=13
} SfDebugObjectType;

typedef enum {
	 STATE_ENTER_ENTRY_FUNCTION_TAG=0
	,STATE_BEFORE_ENTRY_ACTION_TAG
	,STATE_DURING_ENTRY_ACTION_TAG
	,STATE_AFTER_ENTRY_ACTION_TAG

	,STATE_ENTER_DURING_FUNCTION_TAG
	,STATE_BEFORE_DURING_ACTION_TAG
	,STATE_DURING_DURING_ACTION_TAG
	,STATE_AFTER_DURING_ACTION_TAG
	
	,STATE_ENTER_EXIT_FUNCTION_TAG
	,STATE_BEFORE_EXIT_ACTION_TAG
	,STATE_DURING_EXIT_ACTION_TAG
	,STATE_AFTER_EXIT_ACTION_TAG

	,STATE_ENTRY_COVERAGE_TAG
	,STATE_DURING_COVERAGE_TAG
	,STATE_EXIT_COVERAGE_TAG
	,STATE_ACTIVE_TAG
	,STATE_INACTIVE_TAG
	,TOTAL_STATE_TAGS

	,TRANSITION_BEFORE_PROCESSING_TAG =0
	,TRANSITION_WHEN_VALID_TAG
	,TRANSITION_BEFORE_COND_ACTION_TAG
	,TRANSITION_DURING_COND_ACTION_TAG
	,TRANSITION_AFTER_COND_ACTION_TAG
	,TRANSITION_BEFORE_TRANS_ACTION_TAG
	,TRANSITION_DURING_TRANS_ACTION_TAG
	,TRANSITION_AFTER_TRANS_ACTION_TAG
	,TRANSITION_AFTER_PROCESSING_TAG
	,TRANSITION_ACTIVE_TAG
	,TRANSITION_INACTIVE_TAG
	,TRANSITION_TRIGGER_COVERAGE_TAG
	,TRANSITION_GUARD_COVERAGE_TAG
	,TRANSITION_TRANSITION_ACTION_COVERAGE_TAG
	,TRANSITION_CONDITION_ACTION_COVERAGE_TAG
	,TRANSITION_DECISION_COVERAGE_TAG
	,TOTAL_TRANSITION_TAGS

	,EVENT_ENTER_BROADCAST_FUNCTION_TAG=0
	,EVENT_BEFORE_BROADCAST_TAG
	,EVENT_AFTER_BROADCAST_TAG
	,TOTAL_EVENT_TAGS

	,CHART_ENTER_SFUNCTION_TAG=0
	,CHART_ENTER_GATEWAY_FUNCTION_TAG
	,CHART_ENTER_ENTRY_FUNCTION_TAG
	,CHART_ENTER_DURING_FUNCTION_TAG
	,CHART_ENTER_EXIT_FUNCTION_TAG
	,CHART_RETURN_TO_SIMULINK_TAG
	,TOTAL_CHART_TAGS

	,EXIT_OUT_OF_FUNCTION_TAG=999	
} SfDebugTagType;

typedef enum {
	 TRANSITION_CONFLICT_TAG
	,DATA_RANGE_TAG
} SfDebugErrorTagType;


#if defined(MATLAB_MEX_FILE) && !defined(_SF_NO_DEBUG_)

extern unsigned int sf_debug_initialize_machine(char *machineName,
												char *targetName,
												unsigned int isLibrary,
												unsigned int totalChartCount,
												unsigned int totalDataCount,
												unsigned int totalEventCount,
												unsigned int totalDataChangeEventCount);
extern unsigned int sf_debug_initialize_chart(	unsigned int machineNumber,
										unsigned int chartFileNumber,
										unsigned int totalStateCount,
										unsigned int totalTransitionCount,
										unsigned int totalDataCount,
										unsigned int totalEventCount,
										unsigned int totalDataChangeEventCount,
										unsigned int totalStateEntryEventCount,
										unsigned int totalStateExitEventCount,
										unsigned int *chartNumberPtr,
										unsigned int *instanceNumberPtr,
										const char *instancePathName,
										void *simStructPtr);
extern unsigned int sf_debug_call(unsigned int machineNumber,
					unsigned int chartNumber,
					unsigned int instanceNumber,
					SfDebugObjectType parentObjectType,
					SfDebugObjectType objectType,
					SfDebugTagType tagType,
					unsigned int objectNumber,
					unsigned int activeEventNumber,
					int optionalInteger,
					void *optionalPointer,
					double simulationTime,
					unsigned int retValue);

/* Prototype for new coverage */
extern unsigned int cv_eval_point(unsigned int machineNumber,
					unsigned int chartNumber,
					unsigned int instanceNumber,
					SfDebugObjectType objectType,
					unsigned int objectNumber,
					unsigned int objectIndex,
					unsigned int retValue);

/* Prototypes for EML Model Coverage */
extern int cv_eml_eval( unsigned int machineNumber,
					    unsigned int chartNumber,
					    unsigned int instanceNumber,
					    SfCvEmlCheckType checkType,
					    unsigned int objectNumber,
					    unsigned int objectIndex,
					    int retValue);

extern void cv_eml_init_script(unsigned int machineNumber,
                               unsigned int chartNumber,   
                               unsigned int instanceNumber,
                               unsigned int stateNumber,
                               unsigned int fcnCnt,   
                               unsigned int ifCnt,    
                               unsigned int switchCnt,
                               unsigned int forCnt,   
                               unsigned int whileCnt, 
                               unsigned int condCnt,  
                               unsigned int mcdcCnt);

extern void cv_eml_init_fcn(unsigned int machineNumber, 
                            unsigned int chartNumber,   
                            unsigned int instanceNumber,
                            unsigned int stateNumber,
                            unsigned int fcnIdx,
                            const char *name,
                            int charStart,     
                            int charExprEnd,   
                            int charEnd);      
                                
extern void cv_eml_init_if(unsigned int machineNumber, 
                           unsigned int chartNumber,   
                           unsigned int instanceNumber,
                           unsigned int stateNumber,
                           unsigned int ifIdx,
                           int charStart,     
                           int charExprEnd,   
                           int charElseStart, 
                           int charEnd);      
                                
extern void cv_eml_init_for(unsigned int machineNumber, 
                            unsigned int chartNumber,   
                            unsigned int instanceNumber,
                            unsigned int stateNumber,
                            unsigned int ifIdx,
                            int charStart,     
                            int charExprEnd,   
                            int charEnd);      
                                
extern void cv_eml_init_while(unsigned int machineNumber, 
                              unsigned int chartNumber,   
                              unsigned int instanceNumber,
                              unsigned int stateNumber,
                              unsigned int ifIdx,
                              int charStart,     
                              int charExprEnd,   
                              int charEnd);      
                                
extern void cv_eml_init_mcdc( unsigned int machineNumber,
                              unsigned int chartNumber,   
                              unsigned int instanceNumber,
                              unsigned int stateNumber,
                              unsigned int mcdcIdx,
                              int charStart,
                              int charEnd,
                              unsigned int condCnt,
                              unsigned int firstCondIdx,
                              int *condStart,
                              int *condEnd,
                              unsigned int pfxLength,
                              int *pfixExpr);
                                
extern void cv_eml_init_switch( unsigned int machineNumber,
                                unsigned int chartNumber,   
                                unsigned int instanceNumber,
                                unsigned int stateNumber,
                                unsigned int switchIdx,
                                int charStart,         
                                int charExprEnd,       
                                int charEnd,           
                                unsigned int caseCnt,  
                                int *caseStart,        
                                int *caseExprEnd); 


extern void sf_debug_error(const char *msg,... );
extern void sf_debug_terminate(void);
extern void sf_debug_terminate_instance(unsigned int machineNumber, unsigned int chartNumber, unsigned int instanceNumber);
extern unsigned int sf_debug_is_uninterruptible(void);
extern void sf_debug_store_current_state_configuration(unsigned int machineNumber,unsigned int chartNumber,unsigned int instanceNumber);
extern void sf_debug_restore_previous_state_configuration(unsigned int machineNumber,unsigned int chartNumber,unsigned int instanceNumber);
extern void sf_debug_restore_previous_state_configuration2(unsigned int machineNumber,unsigned int chartNumber,unsigned int instanceNumber);
extern void sf_debug_reset_current_state_configuration(unsigned int machineNumber,unsigned int chartNumber,unsigned int instanceNumber);


extern void sf_debug_set_number_of_data_with_change_event_for_machine(unsigned int machineNumber,unsigned int index,unsigned int dataNumber);

extern void sf_debug_set_machine_event_thresholds(unsigned int machineNumber,
										   unsigned int machineThreshold,
										   unsigned int dataChangeThreshold);
extern void sf_debug_set_machine_event_scope(unsigned int machineNumber,
									  unsigned int eventNumber,
									  unsigned int eventScope);
extern void sf_debug_set_machine_data_thresholds(unsigned int machineNumber,
										 unsigned int machineDataThreshold);
extern void sf_debug_set_machine_data_scope(unsigned int machineNumber,
									 unsigned int dataNumber,
									 unsigned int dataScope);
extern void sf_debug_set_machine_data_name(unsigned int machineNumber,
									unsigned int dataNumber,
									const char *dataName);
extern void sf_debug_set_machine_data_size(unsigned int machineNumber,
									unsigned int dataNumber,
									unsigned int numDimensions,
									unsigned int *dimVector);
void sf_debug_set_machine_data_type(unsigned int machineNumber,
                                    unsigned int dataNumber,
                                    unsigned int dataType,
									unsigned int isComplex,
                                    unsigned int isFixedPoint,
                                    double bias,
                                    double slope,
                                    int exponent);
void sf_debug_set_chart_data_props(unsigned int machineNumber,
									unsigned int chartNumber,
                                    unsigned int offsetDataNumber,
                                    unsigned int dataScope,
                                    unsigned int isInputData,
                                    unsigned int isOutputData,
                                    unsigned int dataType,
                                    unsigned int numDimensions,
                                    unsigned int *dimVector,
                                    unsigned int isFixedPoint,
                                    double bias,
                                    double slope,
                                    int exponent,
									const char *dataName,
									unsigned int isComplex
                                    );
void sf_debug_push_symbol_scope(unsigned int numEntry);
void sf_debug_pop_symbol_scope();
void sf_debug_symbol_scope_add_symbol(const char *name,
							SfDataType type,
							unsigned int numDims,
							unsigned int m,
							unsigned int n,
							unsigned int isFixpt,
							double slope,
							int exponent,
							double bias,
							unsigned int isComplex,
                            SfIndexScheme indexScheme,
							const void *basePtr);
extern void sf_debug_set_chart_event_scope(unsigned int machineNumber,
									unsigned int chartNumber,
									unsigned int offsetEventNumber,
									unsigned int eventScope);
extern void sf_debug_set_machine_data_value_ptr(unsigned int machineNumber,
											unsigned int dataNumber, 
											void *dataValuePtr);
extern void sf_debug_set_instance_data_value_ptr(	unsigned int machineNumber,
									unsigned int chartNumber,
									unsigned int instanceNumber,
									unsigned int offsetDataNumber,
									void *dataValuePtr);
extern void sf_debug_unset_instance_data_value_ptr(unsigned int machineNumber,
												unsigned int chartNumber,
												unsigned int instanceNumber,
												unsigned int dataNumber);

extern void sf_debug_set_number_of_data_with_change_event_for_chart(unsigned int machineNumber,
																	unsigned int chartNumber, 
																	unsigned int index,
																	unsigned int dataNumber);

extern void sf_debug_set_number_of_states_with_entry_event_for_chart(unsigned int machineNumber,
																	unsigned int chartNumber, 
																	unsigned int index,
																	unsigned int stateNumber);

extern void sf_debug_set_number_of_states_with_exit_event_for_chart(unsigned int machineNumber,
																	unsigned int chartNumber, 
																	unsigned int index,
																	unsigned int stateNumber);

extern void sf_debug_set_chart_disable_implicit_casting(unsigned int machineNumber,
												unsigned int chartNumber,
												unsigned int disableImplicitCasting);
extern void sf_debug_set_chart_event_thresholds(unsigned int machineNumber,
												unsigned int chartNumber,
												unsigned int dataChangeThreshold,
												unsigned int stateEntryThreshold,
												unsigned int stateExitThreshold);
extern unsigned int sf_debug_is_uninterruptible(void);
extern void sf_debug_set_instance_transition_coverage_weights(unsigned int machineNumber,
									   unsigned int chartNumber, 
									   unsigned int instanceNumber,
									   unsigned int transitionNumber,
									   unsigned int trigger,
									   unsigned int guard,
									   unsigned int conditionAction,
									   unsigned int transitionAction);

extern void sf_debug_set_chart_transition_coverage_maps(  unsigned int machineNumber,
									   unsigned int chartNumber,
									   unsigned int transitionNumber,
									   unsigned int triggerMapCount,
									   unsigned int *triggerMapStart,
									   unsigned int *triggerMapEnd,
									   unsigned int guardMapCount,
									   unsigned int *guardMapStart,
									   unsigned int *guardMapEnd,
									   unsigned int conditionActionMapCount,
									   unsigned int *conditionActionMapStart,
									   unsigned int *conditionActionMapEnd,
									   unsigned int transitionActionMapCount,
									   unsigned int *transitionActionMapStart,
									   unsigned int *transitionActionMapEnd);

extern void sf_debug_set_chart_state_coverage_maps(unsigned int machineNumber,
									   unsigned int chartNumber,
									   unsigned int stateNumber,
									   unsigned int entryMapCount,
									   unsigned int *entryMapStart,
									   unsigned int *entryMapEnd,
									   unsigned int duringMapCount,
									   unsigned int *duringMapStart,
									   unsigned int *duringMapEnd,
									   unsigned int exitMapCount,
									   unsigned int *exitMapStart,
									   unsigned int *exitMapEnd);

extern void sf_debug_set_instance_state_coverage_weights(unsigned int machineNumber,
									   unsigned int chartNumber, 
									   unsigned int instanceNumber,
									   unsigned int stateNumber,
									   unsigned int entry,
									   unsigned int during,
									   unsigned int exit);
extern void sf_debug_set_chart_state_info(unsigned int machineNumber,
									unsigned int chartNumber,
									unsigned int stateNumber,
									unsigned int decomposition,
									unsigned int type);
extern void sf_debug_set_chart_decomposition(unsigned int machineNumber,
									   unsigned int chartNumber,
									   unsigned int decomposition);
extern void sf_debug_set_chart_substate_count(unsigned int machineNumber,
									   unsigned int chartNumber,
									   unsigned int substateCount);
extern void sf_debug_set_chart_substate_index(unsigned int machineNumber,
											 unsigned int chartNumber,
											 unsigned int substateIndex,
											 unsigned int substateNumber);
extern void sf_debug_set_chart_state_substate_count(unsigned int machineNumber,
											 unsigned int chartNumber,
											 unsigned int stateNumber,
											 unsigned int substateCount);
extern void sf_debug_set_chart_state_substate_index(unsigned int machineNumber,
											 unsigned int chartNumber,
											 unsigned int stateNumber,
											 unsigned int subStateIndex,
											 unsigned int subStateNumber);
extern void sf_debug_data_range_error(unsigned int machineNumber, 
							   unsigned int chartNumber, 
							   unsigned int instanceNumber, 
							   unsigned int dataNumber);
double sf_debug_data_range_error_wrapper_min_max(unsigned int machineNumber, 
							   unsigned int chartNumber, 
							   unsigned int instanceNumber, 
							   unsigned int dataNumber,
                               double dataValue,
                               double dataMin,
                               double dataMax);
double sf_debug_data_range_error_wrapper_min(unsigned int machineNumber, 
							   unsigned int chartNumber, 
							   unsigned int instanceNumber, 
							   unsigned int dataNumber,
                               double dataValue,
                               double dataMin);
double sf_debug_data_range_error_wrapper_max(unsigned int machineNumber, 
							   unsigned int chartNumber, 
							   unsigned int instanceNumber, 
							   unsigned int dataNumber,
                               double dataValue,
                               double dataMax);

extern int sf_debug_data_array_bounds_error_check( unsigned int machineNumber, 
											unsigned int chartNumber, 
											unsigned int instanceNumber, 
											unsigned int dataNumber,
											int indexValue,
											int firstIndex,
											int lastIndex,
											int dimension);

extern int sf_debug_eml_data_array_bounds_error_check( unsigned int machineNumber, 
											unsigned int chartNumber, 
											unsigned int instanceNumber, 
											const char *dataName,
											int indexValue,
											int firstIndex,
											int lastIndex,
											int dimension);

extern double sf_debug_integer_check( unsigned int machineNumber,
                                      unsigned int chartNumber,
                                      unsigned int instanceNumber,
                                      const char *dataName,
                                      double value);

extern void sf_debug_transition_conflict_error(unsigned int machineNumber,
										unsigned int chartNumber,
										unsigned int instanceNumber,
										unsigned int *transitionList, 
										unsigned int numTransitions);
unsigned int sf_debug_temporal_threshold(unsigned int machineNumber,
										unsigned int chartNumber,
										unsigned int instanceNumber,
										unsigned int threshold,
										unsigned int width,
										SfDebugObjectType objectType,
										unsigned int  objectNumber);
extern unsigned int sf_debug_data_range_check_enabled(void);
extern unsigned int sf_debug_transition_conflict_check_enabled(void);
extern void sf_debug_transition_conflict_check_begin(void);
extern void sf_debug_transition_conflict_check_end(void);
 
/* macro to prototype 7 nearly identical functions */
#define SF_DEBUG_CAST_TO_TYPE_PROTO(TYPE,type)              \
type sf_debug_cast_to_ ## type (unsigned int machineNumber,  \
							   unsigned int chartNumber,    \
							   unsigned int instanceNumber, \
							   double dataValue,            \
							   unsigned int srcType,        \
							   int stateOrTransId);

SF_DEBUG_CAST_TO_TYPE_PROTO( SF_SINGLE, real32_T)
SF_DEBUG_CAST_TO_TYPE_PROTO(   SF_INT8, int8_T)
SF_DEBUG_CAST_TO_TYPE_PROTO(  SF_UINT8, uint8_T)
SF_DEBUG_CAST_TO_TYPE_PROTO(  SF_INT16, int16_T)
SF_DEBUG_CAST_TO_TYPE_PROTO( SF_UINT16, uint16_T)
SF_DEBUG_CAST_TO_TYPE_PROTO(  SF_INT32, int32_T)
SF_DEBUG_CAST_TO_TYPE_PROTO( SF_UINT32, uint32_T)
#undef SF_DEBUG_CAST_TO_TYPE_PROTO

extern double sf_debug_data_range_wrapper(unsigned int machineNumber, 
							   unsigned int chartNumber, 
							   unsigned int instanceNumber, 
							   unsigned int dataNumber,
                               double dataValue);


extern void sf_debug_cv_init_trans(unsigned int machineNumber,
								unsigned int chartNumber,
								unsigned int instanceNumber,
								unsigned int transitionNumber,
								int predicateCnt, 
                                unsigned int *txtStartIdx, 
                                unsigned int *txtEndIdx,
                                unsigned int postFixPredicateTreeCount,
                                int *postFixPredicateTree);


extern void sf_debug_cv_init_chart(unsigned int machineNumber,
								unsigned int chartNumber,
								unsigned int instanceNumber,
								unsigned int substateCnt,
								bool hasDuringSwitch,
								bool hasExitSwitch,
								bool hasHistSwitch);

					
extern void sf_debug_cv_init_state(unsigned int machineNumber,
								unsigned int chartNumber,
								unsigned int instanceNumber,
								unsigned int stateNumber,
								unsigned int substateCnt,
								bool hasDuringSwitch,
								bool hasExitSwitch,
								bool hasHistSwitch,
                                unsigned int onDecCnt,
                                unsigned int *decStartInd,
                                unsigned int *decEndInd);
extern void sf_debug_overflow_detection(bool isDivByZero);

#else



#endif /* MATLAB_MEX_FILE */

#endif /* SF_DEBUG_H */






