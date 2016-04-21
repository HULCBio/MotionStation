function code_msvc_make_file(fileNameInfo)
% CODE_MSVC_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.7.2.1 $  $Date: 2004/04/13 03:12:39 $

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
fprintf(file,'nmake -f %s\n',fileNameInfo.msvcMakeFile);
	fclose(file);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end


	DOLLAR = '$';
fprintf(file,'# ------------------- Required for MSVC nmake ---------------------------------\n');
fprintf(file,'# This file should be included at the top of a MAKEFILE as follows:\n');
fprintf(file,'\n');
fprintf(file,'\n');
	if(length(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'!include "%s"\n',fileNameInfo.userMakefiles{i});
		end
	end
fprintf(file,'!include <ntwin32.mak>\n');
fprintf(file,'\n');
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
fprintf(file,'MACHINE_REG =\n');
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

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.msvcMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',fileNameInfo.matlabRoot);
fprintf(file,'BUILDARGS   =\n');

fprintf(file,'\n');
fprintf(file,'#--------------------------- Tool Specifications ------------------------------\n');
fprintf(file,'#\n');
fprintf(file,'#\n');
fprintf(file,'MSVC_ROOT1 = %s(MSDEVDIR:SharedIDE=vc)\n',DOLLAR);
fprintf(file,'MSVC_ROOT2 = %s(MSVC_ROOT1:SHAREDIDE=vc)\n',DOLLAR);
fprintf(file,'MSVC_ROOT  = %s(MSVC_ROOT2:sharedide=vc)\n',DOLLAR);
fprintf(file,'\n');
fprintf(file,'# Compiler tool locations, CC, LD, LIBCMD:\n');
fprintf(file,'CC     = cl.exe\n');
fprintf(file,'LD     = link.exe\n');
fprintf(file,'LIBCMD = lib.exe\n');

fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
fprintf(file,'\n');
	userIncludeDirString = '';
	if(length(fileNameInfo.userIncludeDirs))
		for i = 1:length(fileNameInfo.userIncludeDirs)
			userIncludeDirString	= [userIncludeDirString,' /I "',fileNameInfo.userIncludeDirs{i},'"'];
		end
	end
fprintf(file,'USER_INCLUDES   = %s\n',userIncludeDirString);
fprintf(file,'ML_INCLUDES     = /I "%s(MATLAB_ROOT)\\extern\\include"\n',DOLLAR);
fprintf(file,'SL_INCLUDES     = /I "%s(MATLAB_ROOT)\\simulink\\include"\n',DOLLAR);
fprintf(file,'SF_INCLUDES     = /I "%s" /I "%s"\n',fileNameInfo.sfcMexLibInclude,fileNameInfo.sfcDebugLibInclude);
fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = /I "%s"\n',fileNameInfo.dspLibInclude);
else
fprintf(file,'DSP_INCLUDES    =\n');
end
fprintf(file,'\n');
fprintf(file,'COMPILER_INCLUDES = /I "%s(MSVC_ROOT)\\include"\n',DOLLAR);
fprintf(file,'\n');
fprintf(file,'INCLUDE_PATH = %s(USER_INCLUDES) %s(ML_INCLUDES) %s(SL_INCLUDES) %s(SF_INCLUDES) %s(DSP_INCLUDES)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'LIB_PATH     = "%s(MSVC_ROOT)\\lib"\n',DOLLAR);

fprintf(file,'\n');

if(0)
fprintf(file,'#----------------- Compiler and Linker Options --------------------------------\n');
fprintf(file,'\n');
fprintf(file,'CFLAGS = /nologo -c -Zp8 -G5 -W3 /MD -DNDEBUG -DMATLAB_MEX_FILE\n');
fprintf(file,'\n');
else
fprintf(file,'CFLAGS = %s(COMPFLAGS) /MD\n',DOLLAR);
end
fprintf(file,'LDFLAGS = /nologo /dll /OPT:NOREF /export:mexFunction\n');
fprintf(file,'\n');


fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
fprintf(file,'\n');
fprintf(file,'REQ_SRCS  = %s(MACHINE_SRC) %s(MACHINE_REG) %s(MEX_WRAPPER) %s(CHART_SRCS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
	if(length(userAbsSources))
fprintf(file,'USER_ABS_OBJS 	= \\\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr, extStr] = fileparts(userAbsSources{i});
			objStr = [nameStr '.obj'];
fprintf(file,'		"%s" \\\n',objStr);
		end
	else
fprintf(file,'USER_ABS_OBJS =\n');
	end
fprintf(file,'\n');
fprintf(file,'OBJS = %s(REQ_SRCS:.c=.obj) %s(USER_ABS_OBJS)\n',DOLLAR,DOLLAR);
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);

	stateflowLibraryString = ['"', fileNameInfo.sfcMexLibFile ,'"'];
	stateflowLibraryString = [stateflowLibraryString,' "', fileNameInfo.sfcDebugLibFile ,'"'];


fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);
	if(length(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = \\\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	"%s" \\\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	"%s"\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = \\\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	"%s" \\\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	"%s"\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end

fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibFile))
fprintf(file,'DSP_LIBS    = "%s"\n',fileNameInfo.dspLibFile);
else
fprintf(file,'DSP_LIBS    =\n');
end

fprintf(file,'\n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,'\n');
	if gTargetInfo.codingLibrary
fprintf(file,'%s(MACHINE)_%s(TARGET).lib : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(LD) -lib /OUT:%s(MACHINE)_%s(TARGET).lib @%s(OBJLIST_FILE) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Created Stateflow library %s@\n',DOLLAR);

	else
		if(gTargetInfo.codingMEX & ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))

fprintf(file,'MEX_FILE_NAME_WO_EXT = %s\n',sf('get',gMachineInfo.target,'target.mexFileName'));
		else
fprintf(file,'MEX_FILE_NAME_WO_EXT = %s(MACHINE)_%s(TARGET)\n',DOLLAR,DOLLAR);
		end
fprintf(file,'MEX_FILE_NAME = %s(MEX_FILE_NAME_WO_EXT).%s\n',DOLLAR,mexext);
		mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'bin','win32','mapcsf.exe');
		if(~exist(mapCsfBinary,'file'))
			mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'tools','win32','mapcsf.exe');
			if(~exist(mapCsfBinary,'file'))
				mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'tools','nt','mapcsf.exe');
				if(~exist(mapCsfBinary,'file'))
					mapCsfBinary = '';
				end
			end
		end

		if(~isempty(mapCsfBinary))
fprintf(file,'MEX_FILE_CSF =  %s(MEX_FILE_NAME_WO_EXT).csf\n',DOLLAR);
		else
fprintf(file,'MEX_FILE_CSF =\n');
		end

fprintf(file,'all : %s(MEX_FILE_NAME) %s(MEX_FILE_CSF)\n',DOLLAR,DOLLAR);
fprintf(file,'\n');
		libMexDir = fullfile(matlabroot,'extern','lib','win32','microsoft','msvc50');
fprintf(file,'MEXLIB = "%s" "%s" "%s" "%s" "%s"\n',fullfile(libMexDir,'libmx.lib'),fullfile(libMexDir,'libmex.lib'),fullfile(libMexDir,'libmat.lib'),fullfile(libMexDir,'libfixedpoint.lib'),fullfile(libMexDir,'libut.lib'));
fprintf(file,'\n');
fprintf(file,'%s(MEX_FILE_NAME) : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(LD) %s(LDFLAGS) /OUT:%s(MEX_FILE_NAME) /map:"%s(MEX_FILE_NAME_WO_EXT).map" %s(USER_LIBS) %s(SFCLIB) %s(MEXLIB) %s(LINK_MACHINE_LIBS) %s(DSP_LIBS) @%s(OBJLIST_FILE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Created %s@\n',DOLLAR);
fprintf(file,'\n');
		if(~isempty(mapCsfBinary))
fprintf(file,'%s(MEX_FILE_CSF) : %s(MEX_FILE_NAME)\n',DOLLAR,DOLLAR);
fprintf(file,'	"%s" %s(MEX_FILE_NAME)\n',mapCsfBinary,DOLLAR);
		end
	end

fprintf(file,'.c.obj :\n');
fprintf(file,'	@echo ### Compiling "%s<"\n',DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s<"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr, extStr] = fileparts(userAbsSources{i});
			objFileName = [nameStr '.obj'];
fprintf(file,'%s :	"%s"\n',objFileName,userSources{i});
fprintf(file,'	@echo ### Compiling "%s"\n',userSources{i});
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,userSources{i});
		end

	fclose(file);
