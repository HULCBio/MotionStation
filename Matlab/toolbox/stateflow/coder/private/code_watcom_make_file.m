function code_watcom_make_file(fileNameInfo)

% CODE_WATCOM_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.14.2.4.2.1 $  $Date: 2004/04/13 03:12:39 $

	global gMachineInfo gTargetInfo
	 
	code_machine_objlist_file(fileNameInfo);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
	if(~isempty(fileNameInfo.mexOptsFile))
fprintf(file,'call "%s"\n',fileNameInfo.mexOptsFile);
	end
fprintf(file,'wmake -f %s\n',fileNameInfo.watcomMakeFile);
	fclose(file);


	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.watcomMakeFile);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	DOLLAR = '$';
	if(length(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'!include $fileNameInfo.userMakefiles{i}\n');
		end
	end
fprintf(file,'MACHINE     = %s\n',gMachineInfo.machineName);
fprintf(file,'TARGET		= %s\n',gMachineInfo.targetName);

	if length(gMachineInfo.charts)
fprintf(file,'CHART_SRCS 	= &\n');
		for chart=gMachineInfo.charts(1:end-1)
			chartNumber = sf('get',chart,'chart.number');
fprintf(file,'		%s&\n',fileNameInfo.chartSourceFiles{chartNumber+1});
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

	if(length(fileNameInfo.userSources))
fprintf(file,'USER_SRCS 	= &\n');
		for i=1:length(fileNameInfo.userSources)-1
fprintf(file,'		%s&\n',fileNameInfo.userSources{i});
		end
fprintf(file,'		%s\n',fileNameInfo.userSources{end});

fprintf(file,'USER_ABS_SRCS 	= &\n');
		for i=1:length(fileNameInfo.userAbsSources)-1
fprintf(file,'		%s&\n',fileNameInfo.userAbsSources{i});
		end
fprintf(file,'		%s\n',fileNameInfo.userAbsSources{end});
		userSrcPathString	= '';
		if(length(fileNameInfo.userAbsPaths)>0)
			userSrcPathString = [fileNameInfo.userAbsPaths{1}];
			for i=2:length(fileNameInfo.userAbsPaths)
				userSrcPathString = [userSrcPathString,';',fileNameInfo.userAbsPaths{i}];
			end
		end
fprintf(file,'USER_SRC_PATHS = %s\n',userSrcPathString);
	else
fprintf(file,' \n');
fprintf(file,'USER_SRC_PATHS	= &\n');
fprintf(file,'USER_SRCS =\n');
fprintf(file,'USER_ABS_SRCS =\n');
fprintf(file,'USER_SRC_PATHS =\n');
	end

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.watcomMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',fileNameInfo.matlabRoot);
fprintf(file,' \n');
fprintf(file,'#--------------------------------- Tool Locations -----------------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Modify the following macro to reflect where you have installed\n');
fprintf(file,'# the Watcom C/C++ Compiler.\n');
fprintf(file,'#\n');
fprintf(file,'!ifndef %%WATCOM\n');
fprintf(file,'!error WATCOM environmental variable must be defined\n');
fprintf(file,'!else\n');
fprintf(file,'WATCOM = %s(%%WATCOM)\n',DOLLAR);
fprintf(file,'!endif\n');
fprintf(file,'  \n');
fprintf(file,'#---------------------------- Tool Definitions ---------------------------\n');
fprintf(file,'  \n');
fprintf(file,'CC     = wcc386\n');
fprintf(file,'LD     = wcl386\n');
fprintf(file,'LIBCMD = wlib\n');
fprintf(file,'LINKCMD = wlink\n');
fprintf(file,'   \n');
fprintf(file,'#------------------------------ Include Path -----------------------------\n');
	userIncludeDirString = '';
	if(length(fileNameInfo.userIncludeDirs))
		for i = 1:length(fileNameInfo.userIncludeDirs)
			userIncludeDirString	= [userIncludeDirString,fileNameInfo.userIncludeDirs{i},';'];
		end
	end
fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);
fprintf(file,'  \n');
fprintf(file,'MATLAB_INCLUDES = &\n');
fprintf(file,'%s(MATLAB_ROOT)\\simulink\\include;&\n',DOLLAR);
fprintf(file,'%s(MATLAB_ROOT)\\extern\\include;&\n',DOLLAR);
fprintf(file,'%s;&\n',fileNameInfo.sfcMexLibInclude);
fprintf(file,'%s;\n',fileNameInfo.sfcDebugLibInclude);
   if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = %s;\n',fileNameInfo.dspLibInclude);
   else
fprintf(file,'DSP_INCLUDES    =   \n');
   end

fprintf(file,'  \n');
fprintf(file,'INCLUDES = %s(USER_INCLUDES)%s(MATLAB_INCLUDES)%s(DSP_INCLUDES)%s(%%INCLUDE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'  \n');
fprintf(file,'#-------------------------------- C Flags --------------------------------\n');
fprintf(file,'!ifeq %%OS Windows_NT\n');
fprintf(file,'REQ_OPTS = -fpi87 -3s -bt=NT\n');
fprintf(file,'!else\n');
fprintf(file,'REQ_OPTS = -fpi87 -3s\n');
fprintf(file,'!endif\n');
fprintf(file,' \n');
fprintf(file,'\n');
fprintf(file,'MEX_DEFINE = -DMATLAB_MEX_FILE\n');
fprintf(file,'OPT_OPTS = -ox\n');
fprintf(file,'CC_OPTS =  -zp8 -ei -bd -zq %s(MEX_DEFINE) %s(REQ_OPTS) %s(OPT_OPTS) %s(OPTS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'CFLAGS = %s(CC_OPTS)\n',DOLLAR);
fprintf(file,' \n');
fprintf(file,'#------------------------------- Source Files ---------------------------------\n');
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);

	stateflowLibraryString = fileNameInfo.sfcMexLibFile;
	stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.sfcDebugLibFile];
   if (~isempty(fileNameInfo.dspLibFile))
      stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.dspLibFile];
   end
fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);

	if(length(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = &\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	%s &\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	%s\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(~gTargetInfo.codingLibrary & numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = &\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	%s &\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	%s\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end
fprintf(file,' \n');
fprintf(file,'REQ_OBJS  = &\n');
	for i=1:length(fileNameInfo.userAbsSources)
		userSourceFile = fileNameInfo.userAbsSources{i};
		userObjFile = [userSourceFile(1:end-1),'obj'];
fprintf(file,'%s &\n',userObjFile);
	end
	for chart=gMachineInfo.charts
		chartNumber = sf('get',chart,'chart.number');
		chartSourceFile = fileNameInfo.chartSourceFiles{chartNumber+1};
		chartObjFile = [chartSourceFile(1:end-1),'obj'];
fprintf(file,'%s	&\n',chartObjFile);
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingSFunction
		machineRegistryFile = fileNameInfo.machineRegistryFile;
		machineRegistryFile = [machineRegistryFile(1:end-1),'obj'];
fprintf(file,'%s &\n',machineRegistryFile);
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingMEX
		mexWrapperFile = fileNameInfo.mexWrapperFile;
		mexWrapperFile = [mexWrapperFile(1:end-1),'obj'];
fprintf(file,'%s &\n',mexWrapperFile);
	end
	machineSourceFile = fileNameInfo.machineSourceFile;
	machineSourceFile = [machineSourceFile(1:end-1),'obj'];
fprintf(file,'%s\n',machineSourceFile);
fprintf(file,' \n');
fprintf(file,'OBJS = %s(REQ_OBJS)\n',DOLLAR);
	if gTargetInfo.codingLibrary
fprintf(file,'LIBS = %s(USER_LIBS)\n',DOLLAR);
	else
fprintf(file,'LIBS = %s(USER_LIBS) %s(LINK_MACHINE_LIBS) libmexwat.lib libmxwat.lib libfixwat.lib %s\\extern\\lib\\win32\\watcom\\wc106\\libut.lib %s(SFCLIB)\n',DOLLAR,DOLLAR,matlabroot,DOLLAR);
	end
fprintf(file,' \n');
fprintf(file,'#----------------------- Exported Environment Variables -----------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Because of the 128 character command line length limitations in DOS, we\n');
fprintf(file,'# use environment variables to pass additional information to the WATCOM\n');
fprintf(file,'# Compiler and Linker\n');
fprintf(file,'#\n');
fprintf(file,' \n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,'.ERASE\n');
fprintf(file,' \n');
fprintf(file,'.BEFORE\n');
fprintf(file,'	@set INCLUDE=%s(INCLUDES)\n',DOLLAR);
fprintf(file,' \n');
	if gTargetInfo.codingLibrary
fprintf(file,'%s(MACHINE)_%s(TARGET).lib : %s(OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(LIBCMD) -q -n -l %s(MACHINE)_%s(TARGET).lib %s(LIBS) @%s(OBJLIST_FILE) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

	else
		if(gTargetInfo.codingMEX & ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
fprintf(file,'MEX_FILE_NAME = %s.%s\n',sf('get',gMachineInfo.target,'target.mexFileName'),mexext);
		else
fprintf(file,'MEX_FILE_NAME = %s(MACHINE)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);
		end

fprintf(file,'%s(MEX_FILE_NAME) : %s(MAKEFILE) %s(OBJS) %s(SFCLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(LIBCMD) -q -n libmexwat.lib %s\\bin\\win32\\libmex.dll\n',DOLLAR,matlabroot);
fprintf(file,'	%s(LIBCMD) -q -n libmxwat.lib %s\\bin\\win32\\libmx.dll\n',DOLLAR,matlabroot);
fprintf(file,'	%s(LIBCMD) -q -n libfixwat.lib %s\\bin\\win32\\libfixedpoint.dll\n',DOLLAR,matlabroot);
fprintf(file,'	%s(LINKCMD) name %s(MEX_FILE_NAME) format windows nt dll export mexFunction %s(LDFLAGS) library {%s(LIBS)} file {@%s(OBJLIST_FILE)} \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	del libmexwat.lib;\n');
fprintf(file,'	del libmxwat.lib;\n');
fprintf(file,'	del libfixwat.lib;\n');
	end
fprintf(file,' \n');
fprintf(file,'# Source Path\n');
fprintf(file,'.c : %s(USER_SRC_PATHS)\n',DOLLAR);
fprintf(file,' \n');
fprintf(file,'.c.obj:\n');
fprintf(file,'	@echo %s#%s#%s# Compiling "%s[@"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s[@\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');

	fclose(file);
