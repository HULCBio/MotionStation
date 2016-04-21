function code_machine_registry_file(fileNameInfo)
% CODE_MACHINE_REGISTRY_FILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.6.2.1 $  $Date: 2004/04/13 03:12:38 $

	global gTargetInfo gMachineInfo

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineRegistryFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
		return;
	end

fprintf(file,'#include "%s"\n',fileNameInfo.machineHeaderFile);
	if gTargetInfo.codingDebug
fprintf(file,'#include "sfcdebug.h"\n');
	end
	
	if gTargetInfo.codingSFunction
fprintf(file,'#define PROCESS_MEX_SFUNCTION_CMD_LINE_CALL\n');
fprintf(file,'unsigned int sf_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'	extern unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
			for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'	extern unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',fileNameInfo.linkMachines{i});
			end                                                                                              
fprintf(file,'                                                                                                       \n');
fprintf(file,'	if(sf_%s_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;                         \n',gMachineInfo.machineName);
			for i=1:length(fileNameInfo.linkMachines)                                                        
fprintf(file,'	if(sf_%s_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;         \n',fileNameInfo.linkMachines{i});
			end                                                                                              
fprintf(file,'	return 0;                                                                                           \n');
fprintf(file,'}                                                                                                      \n');

fprintf(file,'unsigned int sf_process_autoinheritence_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'	extern unsigned int sf_%s_autoinheritance_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n',gMachineInfo.machineName);
fprintf(file,'	if(sf_%s_autoinheritance_info(nlhs,plhs,nrhs,prhs)) return 1;                         \n',gMachineInfo.machineName);
fprintf(file,'	return 0;                                                                                           \n');
fprintf(file,'}                                                                                                      \n');

fprintf(file,'unsigned int sf_mex_unlock_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) \n');
fprintf(file,'{\n');
fprintf(file,'	char commandName[20];\n');
fprintf(file,'	if (nrhs<1 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the checksum */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"sf_mex_unlock")) return 0;\n');
fprintf(file,'   while(mexIsLocked()) {\n');
fprintf(file,'      mexUnlock();\n');
fprintf(file,'   }\n');
fprintf(file,'   return(1);\n');
fprintf(file,'}\n');


   if gTargetInfo.codingDebug
fprintf(file,'extern unsigned int sf_debug_api( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] );\n');
	end
	if(gTargetInfo.codingSFunction)
fprintf(file,'static unsigned int ProcessMexSfunctionCmdLineCall(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])\n');
	else
fprintf(file,'unsigned int fsm_process_mex_cmd_line_call(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])\n');
	end
fprintf(file,'{\n');
		if(gTargetInfo.codingDebug)
fprintf(file,'	if(sf_debug_api(nlhs,plhs,nrhs,prhs)) return 1;\n');
		end
fprintf(file,'	if(sf_process_check_sum_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'	if(sf_mex_unlock_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'	if(sf_process_autoinheritence_call(nlhs,plhs,nrhs,prhs)) return 1;\n');
fprintf(file,'	return 0;\n');
fprintf(file,'}\n');
fprintf(file,'static unsigned int sfMachineGlobalTerminatorCallable = 0;\n');
fprintf(file,'static unsigned int sfMachineGlobalInitializerCallable = 1;\n');

fprintf(file,'extern unsigned int sf_%s_method_dispatcher(SimStruct *S, const char *chartName, int_T method, void *data);\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern unsigned int sf_%s_method_dispatcher(SimStruct *S, const char *chartName, int_T method, void *data);\n',fileNameInfo.linkMachines{i});
		end		
fprintf(file,'unsigned int sf_machine_global_method_dispatcher(SimStruct *simstructPtr, const char *chartName, int_T method, void *data)\n');
fprintf(file,'{\n');
fprintf(file,'	if(sf_%s_method_dispatcher(simstructPtr,chartName,method,data)) return 1;\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'	if(sf_%s_method_dispatcher(simstructPtr,chartName,method,data)) return 1;\n',fileNameInfo.linkMachines{i});
		end
fprintf(file,'	return 0;\n');
fprintf(file,'}\n');

fprintf(file,'extern void %s_terminator(void);\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_terminator(void);\n',fileNameInfo.linkMachines{i});
		end
fprintf(file,'void sf_machine_global_terminator(void)\n');
fprintf(file,'{\n');
fprintf(file,'	if(sfMachineGlobalTerminatorCallable) {\n');
fprintf(file,'		sfMachineGlobalTerminatorCallable = 0;\n');
fprintf(file,'		sfMachineGlobalInitializerCallable = 1;\n');
fprintf(file,'		%s_terminator();\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'		%s_terminator();\n',fileNameInfo.linkMachines{i});
		end
		
		if gTargetInfo.codingDebug
fprintf(file,'	sf_debug_terminate();\n');
		end

fprintf(file,'	}\n');
fprintf(file,'	return;\n');
fprintf(file,'}\n');
fprintf(file,'extern void %s_initializer(void);\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_initializer(void);\n',fileNameInfo.linkMachines{i});
		end
      if(gTargetInfo.codingDebug)
fprintf(file,'extern void %s_debug_initialize(void);\n',gMachineInfo.machineName);
         for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'extern void %s_debug_initialize(void);\n',fileNameInfo.linkMachines{i});
         end
      end
fprintf(file,'void sf_machine_global_initializer(void)\n');
fprintf(file,'{\n');
fprintf(file,'	if(sfMachineGlobalInitializerCallable) {\n');
fprintf(file,'		sfMachineGlobalInitializerCallable = 0;\n');
fprintf(file,'		sfMachineGlobalTerminatorCallable =1;\n');
	   if(gTargetInfo.codingDebug)
fprintf(file,'     %s_debug_initialize();\n',gMachineInfo.machineName);
      end        
fprintf(file,'		%s_initializer();\n',gMachineInfo.machineName);
		for i=1:length(fileNameInfo.linkMachines)
		   if(gTargetInfo.codingDebug)
fprintf(file,'     %s_debug_initialize();\n',fileNameInfo.linkMachines{i});
         end        
fprintf(file,'		%s_initializer();\n',fileNameInfo.linkMachines{i});
		end
fprintf(file,'	}\n');
fprintf(file,'	return;\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'#define PROCESS_MEX_SFUNCTION_EVERY_CALL\n');
fprintf(file,'\n');
fprintf(file,'unsigned int ProcessMexSfunctionEveryCall(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[]);\n');
fprintf(file,'\n');
fprintf(file,'#include "simulink.c"      %s\n',sf_comment('/* MEX-file interface mechanism */'));
fprintf(file,'\n');
fprintf(file,'static void sf_machine_load_sfunction_ptrs(SimStruct *S)\n');
fprintf(file,'{\n');
fprintf(file,'    ssSetmdlInitializeSampleTimes(S,__mdlInitializeSampleTimes);\n');
fprintf(file,'    ssSetmdlInitializeConditions(S,__mdlInitializeConditions);\n');
fprintf(file,'    ssSetmdlOutputs(S,__mdlOutputs);\n');
fprintf(file,'    ssSetmdlTerminate(S,__mdlTerminate);\n');
fprintf(file,'    ssSetmdlRTW(S,__mdlRTW);\n');
fprintf(file,'    ssSetmdlSetWorkWidths(S,__mdlSetWorkWidths);\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_HASSIMULATIONCONTEXTIO)\n');
fprintf(file,'    ssSetmdlSimulationContextIO(S,__mdlSimulationContextIO);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_START)\n');
fprintf(file,'    ssSetmdlStart(S,__mdlStart);\n');
fprintf(file,'#endif\n');
fprintf(file,'    \n');
fprintf(file,'#if defined(RTW_GENERATED_ENABLE)\n');
fprintf(file,'    ssSetRTWGeneratedEnable(S,__mdlEnable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(RTW_GENERATED_DISABLE)\n');
fprintf(file,'    ssSetRTWGeneratedDisable(S,__mdlDisable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_ENABLE)\n');
fprintf(file,'    ssSetmdlEnable(S,__mdlEnable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_DISABLE)\n');
fprintf(file,'    ssSetmdlDisable(S,__mdlDisable);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_SIM_STATUS_CHANGE)\n');
fprintf(file,'    ssSetmdlSimStatusChange(S,__mdlSimStatusChange);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_EXT_MODE_EXEC)\n');
fprintf(file,'    ssSetmdlExtModeExec(S,__mdlExtModeExec);\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
fprintf(file,'#if defined(MDL_UPDATE)\n');
fprintf(file,'    ssSetmdlUpdate(S,__mdlUpdate);\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'unsigned int ProcessMexSfunctionEveryCall(int_T nlhs, mxArray *plhs[], int_T nrhs, const mxArray *prhs[])\n');
fprintf(file,'{\n');
fprintf(file,'   if (nlhs < 0) {\n');
fprintf(file,'      SimStruct *S = (SimStruct *)plhs[_LHS_SS];\n');
fprintf(file,'      int_T flag = (int_T)(*(real_T*)mxGetPr(prhs[_RHS_FLAG]));\n');
fprintf(file,'      if (flag == SS_CALL_MDL_SET_WORK_WIDTHS) {\n');
fprintf(file,'         sf_machine_load_sfunction_ptrs(S);\n');
fprintf(file,'      }\n');
fprintf(file,'   }\n');
fprintf(file,'   return 0;\n');
fprintf(file,'}\n');
	end
	
	fclose(file);
	try_indenting_file(fileName);

