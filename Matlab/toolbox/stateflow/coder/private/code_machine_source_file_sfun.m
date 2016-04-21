function code_machine_source_file_sfun(fileNameInfo)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.7.2.1 $  $Date: 2004/04/13 03:12:39 $


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%  GLOBAL VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global gMachineInfo  gTargetInfo

   machine = gMachineInfo.machineId;

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineSourceFile);
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'wt');
   if file<3
     construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
     return;
   end

fprintf(file,'/* Include files */\n');
	if(~isempty(sf('get',gMachineInfo.parentTarget,'target.customCode')))
fprintf(file,'#define IN_SF_MACHINE_SOURCE 1\n');
	end
fprintf(file,'#include "%s"\n',fileNameInfo.machineHeaderFile);
	for i = 1:length(fileNameInfo.chartHeaderFiles)
fprintf(file,'#include "%s"\n',fileNameInfo.chartHeaderFiles{i});
	end

	file = dump_module(fileName,file,machine,'source');
    if file < 3
      return;
    end


fprintf(file,'/* SFunction Glue Code */\n');
fprintf(file,'unsigned int sf_%s_method_dispatcher(SimStruct *simstructPtr, const char *chartName, int_T method, void *data)\n',gMachineInfo.machineName);
fprintf(file,'{\n');
		for chart = gMachineInfo.charts
      	chartUniqueName = sf('CodegenNameOf',chart);
			chartName = [gMachineInfo.machineName,'/',sf('get',chart,'chart.name')];
			chartName(regexp(chartName,'\s')) = ' ';
			% G91382: Escape double quote characters
			chartName = strrep(chartName,'"','\"');
fprintf(file,'	if(!strcmp_ignore_ws(chartName,"%s/ SFunction ")) {\n',chartName);
fprintf(file,'	   %s_method_dispatcher(simstructPtr, method, data);\n',chartUniqueName);
fprintf(file,'      return 1;\n');
fprintf(file,'	}\n');
		end
fprintf(file,'	return 0;\n');
fprintf(file,'}\n');
fprintf(file,'unsigned int sf_%s_process_check_sum_call( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[20];\n');
fprintf(file,'	if (nrhs<1 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the checksum */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"sf_get_check_sum")) return 0;\n');
fprintf(file,'	plhs[0] = mxCreateDoubleMatrix( 1,4,mxREAL);\n');

		if gTargetInfo.codingLibrary
fprintf(file,'	if(nrhs>2 && mxIsChar(prhs[1])) {\n');
fprintf(file,'		mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'		commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'		if(!strcmp(commandName,"library")) {\n');
fprintf(file,'			char machineName[100];\n');
fprintf(file,'			mxGetString(prhs[2], machineName,sizeof(machineName)/sizeof(char));\n');
fprintf(file,'			machineName[(sizeof(machineName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'			if(!strcmp(machineName,"%s")){\n',gMachineInfo.machineName);
			checksumVector = sf('get',gMachineInfo.target,'target.checksumNew');
			for i=1:4
fprintf(file,'				((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'			}else{\n');
fprintf(file,'				return 0;\n');
fprintf(file,'			}\n');
fprintf(file,'		}\n');
fprintf(file,'	}else {\n');
fprintf(file,'		return 0;\n');
fprintf(file,'	}\n');
fprintf(file,'\n');
		else
fprintf(file,'	if(nrhs>1 && mxIsChar(prhs[1])) {\n');
fprintf(file,'		mxGetString(prhs[1], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'		commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'		if(!strcmp(commandName,"machine")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.checksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
		   end
fprintf(file,'		}else if(!strcmp(commandName,"exportedFcn")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.exportedFcnChecksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else if(!strcmp(commandName,"makefile")) {\n');
			checksumVector = sf('get',gMachineInfo.machineId,'machine.makefileChecksum');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else if(nrhs==3 && !strcmp(commandName,"chart")) {\n');
fprintf(file,'			unsigned int chartFileNumber;\n');
fprintf(file,'			chartFileNumber = (unsigned int)mxGetScalar(prhs[2]);\n');
fprintf(file,'			switch(chartFileNumber) {\n');
			for chart = gMachineInfo.charts
         	chartUniqueName = sf('CodegenNameOf',chart);
				chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			case %.15g:\n',chartFileNumber);
fprintf(file,'			{\n');
fprintf(file,'				extern void sf_%s_get_check_sum(mxArray *plhs[]);\n',chartUniqueName);
fprintf(file,'				sf_%s_get_check_sum(plhs);\n',chartUniqueName);
fprintf(file,'				break;\n');
fprintf(file,'			}\n');
fprintf(file,'\n');
			end
fprintf(file,'			default:\n');
			for i=1:4
fprintf(file,'				((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(0.0);\n',(i-1));
			end
fprintf(file,'			}\n');
fprintf(file,'		}else if(!strcmp(commandName,"target")) {\n');
			checksumVector = sf('get',gMachineInfo.target,'target.checksumSelf');
			for i=1:4
fprintf(file,'			((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'		}else {\n');
fprintf(file,'			return 0;\n');
fprintf(file,'		}\n');
fprintf(file,'	} else{\n');
			checksumVector = sf('get',gMachineInfo.target,'target.checksumNew');
			for i=1:4
fprintf(file,'				((real_T *)mxGetPr((plhs[0])))[%.15g] = (real_T)(%.15gU);\n',(i-1),checksumVector(i));
			end
fprintf(file,'	}\n');
		end
fprintf(file,'	return 1;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
fprintf(file,'\n');
fprintf(file,'unsigned int sf_%s_autoinheritance_info( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] )\n',gMachineInfo.machineName);
fprintf(file,'{\n');
fprintf(file,'#ifdef MATLAB_MEX_FILE\n');
fprintf(file,'	char commandName[32];\n');
fprintf(file,'	if (nrhs<2 || !mxIsChar(prhs[0]) ) return 0;\n');
fprintf(file,'%s\n',sf_comment('/* Possible call to get the autoinheritance_info */'));
fprintf(file,'	mxGetString(prhs[0], commandName,sizeof(commandName)/sizeof(char));\n');
fprintf(file,'	commandName[(sizeof(commandName)/sizeof(char)-1)] = ''\\0'';\n');
fprintf(file,'	if(strcmp(commandName,"get_autoinheritance_info")) return 0;\n');
fprintf(file,'{\n');
fprintf(file,'			unsigned int chartFileNumber;\n');
fprintf(file,'			chartFileNumber = (unsigned int)mxGetScalar(prhs[1]);\n');
fprintf(file,'			switch(chartFileNumber) {\n');
			for chart = gMachineInfo.charts
         	chartUniqueName = sf('CodegenNameOf',chart);
			chartFileNumber = sf('get',chart,'chart.chartFileNumber');
fprintf(file,'			case %.15g:\n',chartFileNumber);
fprintf(file,'			{\n');
fprintf(file,'				extern mxArray *sf_%s_get_autoinheritance_info(void);\n',chartUniqueName);
fprintf(file,'				plhs[0] = sf_%s_get_autoinheritance_info();\n',chartUniqueName);
fprintf(file,'				break;\n');
fprintf(file,'			}\n');
fprintf(file,'\n');
			end
fprintf(file,'			default:\n');
fprintf(file,'             plhs[0] = mxCreateDoubleMatrix(0,0,mxREAL);\n');
fprintf(file,'			}\n');
fprintf(file,'}\n');
fprintf(file,'	return 1;\n');
fprintf(file,'#else\n');
fprintf(file,'	return 0;\n');
fprintf(file,'#endif\n');
fprintf(file,'}\n');
   if gTargetInfo.codingDebug
fprintf(file,'void  %s_debug_initialize(void)\n',gMachineInfo.machineName);
fprintf(file,'{\n');
	   code_machine_debug_initialization(file);
fprintf(file,'}\n');
	end

fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

