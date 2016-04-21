function code_debug_macros(fileNameInfo)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.6.5.2.1 $  $Date: 2004/04/13 03:12:38 $

	global gTargetInfo gMachineInfo

	if(~gTargetInfo.codingDebug)
		return;
	end

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.sfDebugMacrosFile);
   sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	tString  = '_sfTime_';
fprintf(file,'#ifndef __SF_DEBUG_MACROS_H__\n');
fprintf(file,'#define __SF_DEBUG_MACROS_H__\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_MACHINE_CALL(v1,v2,v3) sf_debug_call(%s,UNREASONABLE_NUMBER,UNREASONABLE_NUMBER,MACHINE_OBJECT,v1,v2,v3,(unsigned int) %s,-1,NULL,%s,1)\n',gMachineInfo.machineNumberVariableName,gMachineInfo.eventVariableName,tString);
fprintf(file,'#define _SFD_ME_CALL(v2,v3) _SFD_MACHINE_CALL(EVENT_OBJECT,v2,v3)\n');
fprintf(file,'#define _SFD_MD_CALL(v2,v3) _SFD_MACHINE_CALL(EVENT_OBJECT,v2,v3)\n');

fprintf(file,'extern unsigned int %s;\n',gMachineInfo.machineNumberVariableName);

fprintf(file,'#define _SFD_SET_DATA_VALUE_PTR(v1,v2)\\\n');
fprintf(file,'	sf_debug_set_instance_data_value_ptr(%s,CHARTINSTANCE_CHARTNUMBER,CHARTINSTANCE_INSTANCENUMBER,v1,(void *)(v2));\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'#define _SFD_UNSET_DATA_VALUE_PTR(v1)\\\n');
fprintf(file,'	sf_debug_unset_instance_data_value_ptr(%s,CHARTINSTANCE_CHARTNUMBER,CHARTINSTANCE_INSTANCENUMBER,v1);\n',gMachineInfo.machineNumberVariableName);

fprintf(file,'#define _SFD_DATA_RANGE_CHECK_MIN_MAX(dVal,dNum,dMin,dMax)\\\n');
fprintf(file,'                      sf_debug_data_range_error_wrapper_min_max(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             dNum,(double)(dVal),(double)dMin,(double)dMax)\n');

fprintf(file,'#define _SFD_DATA_RANGE_CHECK_MIN(dVal,dNum,dMin)\\\n');
fprintf(file,'                      sf_debug_data_range_error_wrapper_min(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             dNum,(double)(dVal),(double)dMin)\n');

fprintf(file,'#define _SFD_DATA_RANGE_CHECK_MAX(dVal,dNum,dMax)\\\n');
fprintf(file,'                      sf_debug_data_range_error_wrapper_max(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             dNum,(double)(dVal),(double)dMax)\n');

fprintf(file,'#define _SFD_DATA_RANGE_CHECK(dVal,dNum)\\\n');
fprintf(file,'                      sf_debug_data_range_wrapper(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             dNum,(double)(dVal))\n');

fprintf(file,'#define _SFD_ARRAY_BOUNDS_CHECK(v1,v2,v3,v4,v5) \\\n');
fprintf(file,'                      sf_debug_data_array_bounds_error_check(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),(int)(v2),(int)(v3),(int)(v4),(int)(v5))\n');

fprintf(file,'#define _SFD_EML_ARRAY_BOUNDS_CHECK(v1,v2,v3,v4,v5) \\\n');
fprintf(file,'                      sf_debug_eml_data_array_bounds_error_check(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),(int)(v2),(int)(v3),(int)(v4),(int)(v5))\n');
fprintf(file,'#define _SFD_INTEGER_CHECK(v1,v2) \\\n');
fprintf(file,'                      sf_debug_integer_check(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),(double)(v2))\n');
fprintf(file,'#define _SFD_CAST_TO_UINT8(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_uint8_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_UINT16(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_uint16_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_UINT32(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_uint32_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_INT8(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_int8_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_INT16(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_int16_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_INT32(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_int32_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_CAST_TO_SINGLE(v1) \\\n');
fprintf(file,'                      sf_debug_cast_to_real32_T(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'                                             (v1),0,0)\n');

fprintf(file,'#define _SFD_TRANSITION_CONFLICT(v1,v2) sf_debug_transition_conflict_error(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'v1,v2)\n');

fprintf(file,'#define _SFD_CHART_CALL(v1,v2,v3) sf_debug_call(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'CHART_OBJECT,v1,v2,v3,(unsigned int)%s,\\\n',gMachineInfo.eventVariableName);
fprintf(file,'0,NULL,%s,1)\n',tString);

fprintf(file,'#define _SFD_CC_CALL(v2,v3) _SFD_CHART_CALL(CHART_OBJECT,v2,v3)\n');
fprintf(file,'#define _SFD_CS_CALL(v2,v3) _SFD_CHART_CALL(STATE_OBJECT,v2,v3)\n');
fprintf(file,'#define _SFD_CT_CALL(v2,v3) _SFD_CHART_CALL(TRANSITION_OBJECT,v2,v3)\n');
fprintf(file,'#define _SFD_CE_CALL(v2,v3) _SFD_CHART_CALL(EVENT_OBJECT,v2,v3)\n');
fprintf(file,'#define _SFD_CD_CALL(v2,v3) _SFD_CHART_CALL(EVENT_OBJECT,v2,v3)\n');

fprintf(file,'#define _SFD_EML_CALL(v1,v2,v3) sf_debug_call(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'CHART_OBJECT,STATE_OBJECT,v1,v2,(unsigned int)%s,\\\n',gMachineInfo.eventVariableName);
fprintf(file,'v3,NULL,%s,1)\n',tString);


fprintf(file,'#define _SFD_CHART_COVERAGE_CALL(v1,v2,v3,v4) sf_debug_call(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'CHART_OBJECT,v1,v2,v3,(unsigned int) %s,\\\n',gMachineInfo.eventVariableName);
fprintf(file,'v4,NULL,%s,1)\n',tString);

fprintf(file,'#define _SFD_CCS_CALL(v2,v3,v4) _SFD_CHART_COVERAGE_CALL(STATE_OBJECT,v2,v3,v4)\n');
fprintf(file,'#define _SFD_CCT_CALL(v2,v3,v4) _SFD_CHART_COVERAGE_CALL(TRANSITION_OBJECT,v2,v3,v4)\n');

fprintf(file,'#define _SFD_CCP_CALL(v3,v4,v5) sf_debug_call(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'CHART_OBJECT,TRANSITION_OBJECT,TRANSITION_GUARD_COVERAGE_TAG,v3,(unsigned int) %s,\\\n',gMachineInfo.eventVariableName);
fprintf(file,'v4,NULL,%s,(unsigned int)(v5))\n',tString);

fprintf(file,'#define _SFD_STATE_TEMPORAL_THRESHOLD(v1,v2,v4) sf_debug_temporal_threshold(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'(unsigned int)(v1),(v2),STATE_OBJECT,(v4))\n');
fprintf(file,'#define _SFD_TRANS_TEMPORAL_THRESHOLD(v1,v2,v4) sf_debug_temporal_threshold(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'(unsigned int)(v1),(v2),TRANSITION_OBJECT,(v4))\n');

	if(sf('MatlabVersion')>=600)
fprintf(file,'#define CV_EVAL(v1,v2,v3,v4) cv_eval_point(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(boolean_T)(v4))\n');
fprintf(file,'#define CV_CHART_EVAL(v2,v3,v4) CV_EVAL(CHART_OBJECT,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_STATE_EVAL(v2,v3,v4) CV_EVAL(STATE_OBJECT,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_TRANSITION_EVAL(v1,v2) cv_eval_point(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  TRANSITION_OBJECT,(v1),0,((v2)!=0))\n');
	else
fprintf(file,'#define CV_EVAL(v1,v2,v3,v4) (v4)\n');
fprintf(file,'#define CV_CHART_EVAL(v2,v3,v4) (v4)\n');
fprintf(file,'#define CV_STATE_EVAL(v2,v3,v4) (v4)\n');
fprintf(file,'#define CV_TRANSITION_EVAL(v1,v2) (v2)\n');
	end
fprintf(file,'\n');
fprintf(file,'/* Coverage EML Macros */\n');
fprintf(file,'#define CV_EML_EVAL(v1,v2,v3,v4) cv_eml_eval(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(int)(v4))\n');
fprintf(file,'#define CV_EML_FCN(v2,v3) CV_EML_EVAL(CV_EML_FCN_CHECK,(v2),(v3),0)\n');
fprintf(file,'#define CV_EML_IF(v2,v3,v4) CV_EML_EVAL(CV_EML_IF_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_EML_FOR(v2,v3,v4) CV_EML_EVAL(CV_EML_FOR_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_EML_WHILE(v2,v3,v4) CV_EML_EVAL(CV_EML_WHILE_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_EML_SWITCH(v2,v3,v4) CV_EML_EVAL(CV_EML_SWITCH_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_EML_COND(v2,v3,v4) CV_EML_EVAL(CV_EML_COND_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'#define CV_EML_MCDC(v2,v3,v4) CV_EML_EVAL(CV_EML_MCDC_CHECK,(v2),(v3),(v4))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML(v1,v2,v3,v4,v5,v6,v7,v8) cv_eml_init_script(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5),(v6),(v7),(v8))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_FCN(v1,v2,v3,v4,v5,v6) cv_eml_init_fcn(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5),(v6))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_IF(v1,v2,v3,v4,v5,v6) cv_eml_init_if(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5),(v6))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_FOR(v1,v2,v3,v4,v5) cv_eml_init_for(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_WHILE(v1,v2,v3,v4,v5) cv_eml_init_while(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_MCDC(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10) cv_eml_init_mcdc(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5),(v6),(v7),(v8),(v9),(v10))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_EML_SWITCH(v1,v2,v3,v4,v5,v6,v7,v8) cv_eml_init_switch(\\\n');
fprintf(file,'       %s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'		  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'		  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'		  (v1),(v2),(v3),(v4),(v5),(v6),(v7),(v8))\n');
fprintf(file,'\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_SET_DATA_PROPS(dataNumber,dataScope,isInputData,isOutputData,dataType,numDims,dimArray,isFixedPoint,bias,slope,exponent,dataName,isComplex)\\\n');
fprintf(file,' sf_debug_set_chart_data_props(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	(dataNumber),(dataScope),(isInputData),(isOutputData),\\\n');
fprintf(file,'	(dataType),(numDims),(dimArray),(isFixedPoint),(bias),(slope),(exponent),(dataName),(isComplex))\n');
fprintf(file,'#define _SFD_STATE_INFO(v1,v2,v3)\\\n');
fprintf(file,'	sf_debug_set_chart_state_info(%s,CHARTINSTANCE_CHARTNUMBER,(v1),(v2),(v3))\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'#define _SFD_CH_SUBSTATE_INDEX(v1,v2)\\\n');
fprintf(file,'	sf_debug_set_chart_substate_index(%s,CHARTINSTANCE_CHARTNUMBER,(v1),(v2))\n',gMachineInfo.machineNumberVariableName);

fprintf(file,'#define _SFD_ST_SUBSTATE_INDEX(v1,v2,v3)\\\n');
fprintf(file,'   sf_debug_set_chart_state_substate_index(%s,CHARTINSTANCE_CHARTNUMBER,(v1),(v2),(v3))\n',gMachineInfo.machineNumberVariableName);

fprintf(file,'#define _SFD_ST_SUBSTATE_COUNT(v1,v2)\\\n');
fprintf(file,'	sf_debug_set_chart_state_substate_count(%s,CHARTINSTANCE_CHARTNUMBER,(v1),(v2))\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'#define _SFD_STATE_COV_WTS(v1,v2,v3,v4)\\\n');
fprintf(file,'	sf_debug_set_instance_state_coverage_weights(%s,CHARTINSTANCE_CHARTNUMBER,CHARTINSTANCE_INSTANCENUMBER,(v1),(v2),(v3),(v4))\n',gMachineInfo.machineNumberVariableName);

fprintf(file,'#define _SFD_STATE_COV_MAPS(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10) \\\n');
fprintf(file,' sf_debug_set_chart_state_coverage_maps(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'   (v1),(v2),(v3),(v4),(v5),(v6),(v7),(v8),(v9),(v10))\n');

fprintf(file,'#define _SFD_TRANS_COV_WTS(v1,v2,v3,v4,v5) \\\n');
fprintf(file,'	sf_debug_set_instance_transition_coverage_weights(%s,CHARTINSTANCE_CHARTNUMBER,CHARTINSTANCE_INSTANCENUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'   (v1),(v2),(v3),(v4),(v5))\n');

fprintf(file,'#define 	_SFD_TRANS_COV_MAPS(v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13) \\\n');
fprintf(file,'	sf_debug_set_chart_transition_coverage_maps(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'      (v1),\\\n');
fprintf(file,'		(v2),(v3),(v4),\\\n');
fprintf(file,'		(v5),(v6),(v7),\\\n');
fprintf(file,'		(v8),(v9),(v10),\\\n');
fprintf(file,'		(v11),(v12),(v13))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_DATA_CHANGE_EVENT_COUNT(v1,v2) \\\n');
fprintf(file,'	sf_debug_set_number_of_data_with_change_event_for_chart(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	(v1),(v2))\n');
fprintf(file,'#define _SFD_STATE_ENTRY_EVENT_COUNT(v1,v2) \\\n');
fprintf(file,'	sf_debug_set_number_of_states_with_entry_event_for_chart(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	(v1),(v2))\n');
fprintf(file,'#define _SFD_STATE_EXIT_EVENT_COUNT(v1,v2) \\\n');
fprintf(file,'	sf_debug_set_number_of_states_with_exit_event_for_chart(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	(v1),(v2))\n');
fprintf(file,'#define _SFD_EVENT_SCOPE(v1,v2)\\\n');
fprintf(file,'	sf_debug_set_chart_event_scope(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	CHARTINSTANCE_CHARTNUMBER,(v1),(v2))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CH_SUBSTATE_COUNT(v1) \\\n');
fprintf(file,'	sf_debug_set_chart_substate_count(%s,CHARTINSTANCE_CHARTNUMBER,(v1))\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'#define _SFD_CH_SUBSTATE_DECOMP(v1) \\\n');
fprintf(file,'	sf_debug_set_chart_decomposition(%s,CHARTINSTANCE_CHARTNUMBER,(v1))\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_CHART(v1,v2,v3,v4)\\\n');
fprintf(file,' sf_debug_cv_init_chart(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	CHARTINSTANCE_INSTANCENUMBER,(v1),(v2),(v3),(v4))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_STATE(v1,v2,v3,v4,v5,v6,v7,v8)\\\n');
fprintf(file,'	sf_debug_cv_init_state(%s,CHARTINSTANCE_CHARTNUMBER,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	CHARTINSTANCE_INSTANCENUMBER,(v1),(v2),(v3),(v4),(v5),(v6),(v7),(v8))\n');
fprintf(file,'\n');
fprintf(file,'#define _SFD_CV_INIT_TRANS(v1,v2,v3,v4,v5,v6)\\\n');
fprintf(file,'     sf_debug_cv_init_trans(%s,\\\n',gMachineInfo.machineNumberVariableName);
fprintf(file,'	  CHARTINSTANCE_CHARTNUMBER,\\\n');
fprintf(file,'	  CHARTINSTANCE_INSTANCENUMBER,\\\n');
fprintf(file,'	  (v1),(v2),(v3),(v4),(v5),(v6))\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
	fclose(file);
