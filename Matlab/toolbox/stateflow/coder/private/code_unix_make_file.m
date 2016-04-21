function code_unix_make_file(fileNameInfo)
% CODE_UNIX_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.8.2.1 $  $Date: 2004/04/13 03:12:39 $
	
	global gMachineInfo gTargetInfo
	code_machine_objlist_file(fileNameInfo);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.unixMakeFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	DOLLAR = '$';
fprintf(file,'#--------------------------- Tool Specifications -------------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Modify the following macros to reflect the tools you wish to use for\n');
fprintf(file,'# compiling and linking your code.\n');
fprintf(file,'#\n');
	if(length(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'include $fileNameInfo.userMakefiles{i}\n');
		end
	end
	if(gTargetInfo.codingMakeDebug)
fprintf(file,'CC = %s/bin/mex -g\n',matlabroot);
	else
fprintf(file,'CC = %s/bin/mex\n',matlabroot);
	end
fprintf(file,'LD = %s(CC)\n',DOLLAR);
fprintf(file,' \n');
fprintf(file,'MACHINE     = %s\n',gMachineInfo.machineName);
fprintf(file,'TARGET      = %s\n',gMachineInfo.targetName);
	if length(gMachineInfo.charts)
fprintf(file,'CHART_SRCS 	= \\\n');
		for chart=gMachineInfo.charts(1:end-1)
			chartNumber = sf('get',chart,'chart.number');
fprintf(file,'		%s\\\n',fileNameInfo.chartSourceFiles{chartNumber+1});
		end
			chartNumber = sf('get',gMachineInfo.charts(end),'chart.number');
fprintf(file,'		%s\n',fileNameInfo.chartSourceFiles{chartNumber+1});
	else
fprintf(file,'CHART_SRCS =\n');
	end
fprintf(file,'MACHINE_SRC	= %s\n',fileNameInfo.machineSourceFile);
	if(~gTargetInfo.codingLibrary & gTargetInfo.codingSFunction)
fprintf(file,'MACHINE_REG = %s\n',fileNameInfo.machineRegistryFile);
	else
fprintf(file,'MACHINE_REG = \n');
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingMEX
fprintf(file,'MEX_WRAPPER = %s\n',fileNameInfo.mexWrapperFile);
	else
fprintf(file,'MEX_WRAPPER =\n');
	end

   	userAbsSources = {};
   	userSources    = {};
   	for i=1:length(fileNameInfo.userAbsSources)
   		[pathStr, nameStr, extStr] = fileparts(fileNameInfo.userAbsSources{i});
   		extStr = lower(extStr);
   		if(strcmp(extStr, '.c') || strcmp(extStr,'.cpp'))
   			userAbsSources{end+1} = fileNameInfo.userAbsSources{i};
   			userSources{end+1}    = fileNameInfo.userSources{i};
   		else
   			error(['Unrecognized file extension: ' extStr]);
   		end
   	end

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.unixMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',fullfile(sf('Root'),'..','..','..'));
fprintf(file,'BUILDARGS   = \n');
	

fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
fprintf(file,' \n');
	userIncludeDirString = '';
	if(length(fileNameInfo.userIncludeDirs))
		for i = 1:length(fileNameInfo.userIncludeDirs)
			userIncludeDirString	= [userIncludeDirString,'-I',fileNameInfo.userIncludeDirs{i},' '];
		end
	end
fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);
fprintf(file,'MATLAB_INCLUDES = -I%s(MATLAB_ROOT)/simulink/include \\\n',DOLLAR);
fprintf(file,'						-I%s(MATLAB_ROOT)/extern/include \\\n',DOLLAR);
fprintf(file,'						-I%s \\\n',fileNameInfo.sfcMexLibInclude);
fprintf(file,'						-I%s\n',fileNameInfo.sfcDebugLibInclude);
fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = -I%s\n',fileNameInfo.dspLibInclude);
else
fprintf(file,'DSP_INCLUDES    =\n');
end 
fprintf(file,'\n');
fprintf(file,'INCLUDE_PATH = %s %s(MATLAB_INCLUDES) %s(DSP_INCLUDES) %s(COMPILER_INCLUDES)\n',userIncludeDirString,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');

fprintf(file,'#----------------- Compiler and Linker Options --------------------------------\n');
fprintf(file,' \n');
fprintf(file,'# Optimization Options\n');
fprintf(file,'OPT_OPTS = -O\n');
fprintf(file,' \n');
fprintf(file,'# General User Options\n');
fprintf(file,'OPTS =\n');
fprintf(file,' \n');
fprintf(file,'CC_OPTS = %s(OPT_OPTS) %s(OPTS)\n',DOLLAR,DOLLAR);
fprintf(file,'CPP_REQ_DEFINES = -DMATLAB_MEX_FILE\n');
fprintf(file,' \n');
fprintf(file,'# Uncomment this line to move warning level to W4\n');
fprintf(file,'# cflags = %s(cflags:W3=W4)\n',DOLLAR);
fprintf(file,'CFLAGS = %s(CC_OPTS) %s(CPP_REQ_DEFINES) %s(INCLUDE_PATH)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');
fprintf(file,'LDFLAGS = \n');
fprintf(file,' \n');

fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
fprintf(file,' \n');
fprintf(file,'REQ_SRCS  = %s(MACHINE_SRC) %s(MACHINE_REG) %s(MEX_WRAPPER) %s(CHART_SRCS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
	if(length(userAbsSources))
fprintf(file,'USER_ABS_OBJS 	= \\\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr, extStr] = fileparts(userAbsSources{i});
			objStr = [nameStr '.o'];
fprintf(file,'		%s \\\n',objStr);
		end
	else
fprintf(file,'USER_ABS_OBJS =\n');
	end
fprintf(file,'\n');

fprintf(file,'OBJS = %s(REQ_SRCS:.c=.o) %s(USER_ABS_OBJS)\n',DOLLAR,DOLLAR);
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);
	stateflowLibraryString = fileNameInfo.sfcMexLibFile;
	stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.sfcDebugLibFile];
   if (~isempty(fileNameInfo.dspLibFile))
	stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.dspLibFile];
   end
fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);

	if(length(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = \\\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	%s \\\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	%s\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = \\\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	%s \\\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	%s\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end

	arch = lower(computer);
fprintf(file,'FIXEDPOINTLIB = -L%s/bin/%s -lfixedpoint\n',matlabroot,arch);
fprintf(file,'UTLIB = -lut\n');

fprintf(file,' \n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,' \n');
	if gTargetInfo.codingLibrary
fprintf(file,'SF_ARCH := %s(shell arch)\n',DOLLAR);
fprintf(file,'DO_RANLIB = ranlib %s(MACHINE)_%s(TARGET).a\n',DOLLAR,DOLLAR);
fprintf(file,'ifeq (%s(SF_ARCH),sgi)\n',DOLLAR);
fprintf(file,'	DO_RANLIB =\n');
fprintf(file,'endif\n');
fprintf(file,' \n');
fprintf(file,'ifeq (%s(SF_ARCH),sgi64)\n',DOLLAR);
fprintf(file,'	DO_RANLIB =\n');
fprintf(file,'endif\n');
fprintf(file,' \n');
fprintf(file,'%s(MACHINE)_%s(TARGET).a : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	ar ruv %s(MACHINE)_%s(TARGET).a %s(OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(DO_RANLIB)\n',DOLLAR);
	else
		if(gTargetInfo.codingMEX & ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
fprintf(file,'MEX_FILE_NAME = %s.%s\n',sf('get',gMachineInfo.target,'target.mexFileName'),mexext);
		else
fprintf(file,'MEX_FILE_NAME = %s(MACHINE)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);
		end
fprintf(file,' \n');
fprintf(file,' %s(MEX_FILE_NAME): %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(USER_LIBS) %s(MEXLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(CC) -silent -output %s(MEX_FILE_NAME) %s(OBJS) %s(USER_LIBS) %s(LINK_MACHINE_LIBS) %s(SFCLIB) %s(FIXEDPOINTLIB) %s(UTLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
	end
fprintf(file,'%%.o :	%%.c\n');
fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
		for i=1:length(fileNameInfo.userAbsSources)
			objFileName = fileNameInfo.userAbsSources{i};
			objFileName = code_unix_change_ext(objFileName, 'o');
fprintf(file,'%s :	%s\n',objFileName,fileNameInfo.userSources{i});
fprintf(file,'	%s(CC) -c %s(CFLAGS) %s\n',DOLLAR,DOLLAR,fileNameInfo.userSources{i});
		end

	fclose(file);

function result = code_unix_change_ext(filename, ext)

[path_str, name_str, ext_str] = fileparts(filename);

result = [name_str '.' ext];
