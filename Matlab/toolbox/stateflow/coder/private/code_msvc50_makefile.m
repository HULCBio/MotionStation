function code_msvc50_makefile(fileNameInfo)
% CODE_MSVC50_MAKEFILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.10.2.4.2.1 $  $Date: 2004/04/13 03:12:39 $

	global gMachineInfo gTargetInfo
	
	fileName = fileNameInfo.msvc50MakeFile;
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	DOLLAR = '$';
	srcDirectory = ['sfprj\build\',gMachineInfo.machineName,'\',gMachineInfo.targetName,'\src'];
	if(sf('MatlabVersion')>=600)
		libMexDir = fullfile(matlabroot,'extern','lib','win32','microsoft','msvc50');
		libMexFile = ['"',...
                      fullfile(libMexDir,'libmx.lib'),'" "',...
                      fullfile(libMexDir,'libmex.lib'),'" "',...
                      fullfile(libMexDir,'libmat.lib'),'" "',...
                      fullfile(libMexDir,'libfixedpoint.lib'),'" "',...
                      fullfile(libMexDir,'libut.lib'),...
                      '"'];
	else
		libMexFile = 'libmexmsvc.lib';
	end

fprintf(file,'# Microsoft Developer Studio Project File - Name="%s_%s" - Package Owner=<4>\n',gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'# Microsoft Developer Studio Generated Build File, Format Version 5.00\n');
fprintf(file,'# ** DO NOT EDIT **\n');
fprintf(file,' \n');
	if gTargetInfo.codingLibrary
fprintf(file,'# TARGTYPE "Win32 (x86) Static Library" 0x0104\n');
	else
fprintf(file,'# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102\n');
	end
fprintf(file,' \n');
fprintf(file,'CFG=%s_%s - Win32 Debug\n',gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'!MESSAGE This is not a valid makefile. To build this project using NMAKE,\n');
fprintf(file,'!MESSAGE use the Export Makefile command and run\n');
fprintf(file,'!MESSAGE \n');
fprintf(file,'!MESSAGE NMAKE /f "%s_%s.mak".\n',gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'!MESSAGE \n');
fprintf(file,'!MESSAGE You can specify a configuration when running NMAKE\n');
fprintf(file,'!MESSAGE by defining the macro CFG on the command line. For example:\n');
fprintf(file,'!MESSAGE \n');
fprintf(file,'!MESSAGE NMAKE /f "%s_%s.mak" CFG="%s_%s - Win32 Debug"\n',gMachineInfo.machineName,gMachineInfo.targetName,gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'!MESSAGE \n');
fprintf(file,'!MESSAGE Possible choices for configuration are:\n');
fprintf(file,'!MESSAGE\n');
	if gTargetInfo.codingLibrary
fprintf(file,'!MESSAGE "%s_%s - Win32 Debug" (based on "Win32 (x86) Static Library")\n',gMachineInfo.machineName,gMachineInfo.targetName);
	else
fprintf(file,'!MESSAGE "%s_%s - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")\n',gMachineInfo.machineName,gMachineInfo.targetName);
	end
fprintf(file,'!MESSAGE \n');
fprintf(file,' \n');
fprintf(file,'# Begin Project\n');
fprintf(file,'# PROP Scc_ProjName ""\n');
fprintf(file,'# PROP Scc_LocalPath ""\n');
fprintf(file,'CPP=cl.exe\n');
	if ~gTargetInfo.codingLibrary
fprintf(file,'MTL=midl.exe\n');
fprintf(file,'RSC=rc.exe\n');
	end
fprintf(file,'# PROP BASE Use_MFC 0\n');
fprintf(file,'# PROP BASE Use_Debug_Libraries 1\n');
fprintf(file,'# PROP BASE Output_Dir "Debug"\n');
fprintf(file,'# PROP BASE Intermediate_Dir "Debug"\n');
fprintf(file,'# PROP BASE Target_Dir ""\n');
fprintf(file,'# PROP Use_MFC 0\n');
fprintf(file,'# PROP Use_Debug_Libraries 1\n');
fprintf(file,'# PROP Output_Dir "."\n');
fprintf(file,'# PROP Intermediate_Dir "Debug"\n');
	if ~gTargetInfo.codingLibrary
fprintf(file,'# PROP Ignore_Export_Lib 0\n');
	end
fprintf(file,'# PROP Target_Dir ""\n');
	userIncludeDirString = '' ;
	for i = 1:length(fileNameInfo.userIncludeDirs)
		userIncludeDirString	= [userIncludeDirString,' /I "',fileNameInfo.userIncludeDirs{i},'"'];
	end
   if (~isempty(fileNameInfo.dspLibInclude))
      userIncludeDirString = [userIncludeDirString, ' /I "',fileNameInfo.dspLibInclude,'"'];
   end
   
	if gTargetInfo.codingLibrary
fprintf(file,'# ADD BASE CPP /nologo /W3 /GX /Z7 /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c\n');
fprintf(file,'# ADD CPP /nologo /MD /W3 /GX /Z7 /Od %s /I %s /I "%s" /I "%s" /I "%s\\extern\\include" /I "%s\\simulink\\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /YX /FD /c\n',userIncludeDirString,srcDirectory,fileNameInfo.sfcMexLibInclude,fileNameInfo.sfcDebugLibInclude,fileNameInfo.matlabRoot,fileNameInfo.matlabRoot);
	else
fprintf(file,'# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /FD /c\n');
fprintf(file,'# ADD CPP /nologo /MD /W3 /Gm /GX /Zi /Od %s /I %s /I "%s" /I "%s" /I "%s\\extern\\include" /I "%s\\simulink\\include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "MATLAB_MEX_FILE" /YX /FD /c\n',userIncludeDirString,srcDirectory,fileNameInfo.sfcMexLibInclude,fileNameInfo.sfcDebugLibInclude,fileNameInfo.matlabRoot,fileNameInfo.matlabRoot);
fprintf(file,'# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o NUL /win32\n');
fprintf(file,'# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o NUL /win32\n');
fprintf(file,'# ADD BASE RSC /l 0x409 /d "_DEBUG"\n');
fprintf(file,'# ADD RSC /l 0x409 /d "_DEBUG"\n');
	end
fprintf(file,'BSC32=bscmake.exe\n');
fprintf(file,'# ADD BASE BSC32 /nologo\n');
fprintf(file,'# ADD BSC32 /nologo\n');
	if gTargetInfo.codingLibrary
		linkLibString = '';
		for i = 1:length(fileNameInfo.userLibraries)
			linkLibString = [linkLibString,' "',fileNameInfo.userLibraries{i},'"'];
		end
fprintf(file,'LIB32=link.exe -lib\n');
fprintf(file,'# ADD BASE LIB32 /nologo\n');
fprintf(file,'# ADD LIB32 /nologo %s\n',linkLibString);
	else
fprintf(file,'LINK32=link.exe\n');
fprintf(file,'# ADD BASE LINK32 /nologo /subsystem:windows /dll /export:mexFunction /debug /machine:I386 /pdbtype:sept\n');
		linkLibString = '';
		numLinkMachines = length(fileNameInfo.linkLibFullPaths);
		if(numLinkMachines)
			for i = 1:numLinkMachines
				linkLibString = [linkLibString,' "',fileNameInfo.linkLibFullPaths{i},'"'];
			end
		end
		for i = 1:length(fileNameInfo.userLibraries)
			linkLibString = [linkLibString,' "',fileNameInfo.userLibraries{i},'"'];
		end
      if (~isempty(fileNameInfo.dspLibFile))
   		linkLibString = [linkLibString,' "',fileNameInfo.dspLibFile,'"'];
   	end
		stateflowLibraryString = ['"', fileNameInfo.sfcMexLibFile ,'"'];
		stateflowLibraryString = [stateflowLibraryString,' "', fileNameInfo.sfcDebugLibFile ,'"'];
		mexFileName = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.dll'];
fprintf(file,'# ADD LINK32 %s %s %s /nologo /subsystem:windows /dll /export:mexFunction /debug /machine:I386 /out:"%s" /pdbtype:sept\n',linkLibString,stateflowLibraryString,libMexFile,mexFileName);
	end
	if(~gTargetInfo.codingLibrary & sf('MatlabVersion')<600)
fprintf(file,'# Begin Special Build Tool\n');
fprintf(file,'SOURCE=%s(InputPath)\n',DOLLAR);
fprintf(file,'PreLink_Cmds=lib.exe /def:"%s\\extern\\include\\matlab.def" /machine:ix86 /OUT:libmexmsvc.lib\n',fileNameInfo.matlabRoot);
fprintf(file,'# End Special Build Tool\n');
	end
fprintf(file,'# Begin Target\n');
fprintf(file,' \n');
fprintf(file,'# Name "%s_%s - Win32 Debug"\n',gMachineInfo.machineName,gMachineInfo.targetName);

	for i=1:length(fileNameInfo.userSources)
fprintf(file,'# Begin Source File\n');
fprintf(file,' \n');
fprintf(file,'SOURCE="%s"\n',fileNameInfo.userSources{i});
fprintf(file,'# End Source File\n');
	end
	for chart=gMachineInfo.charts
		chartNumber = sf('get',chart,'chart.number');
fprintf(file,'# Begin Source File\n');
fprintf(file,' \n');
fprintf(file,'SOURCE=%s\\%s\n',srcDirectory,fileNameInfo.chartSourceFiles{chartNumber+1});
fprintf(file,'# End Source File\n');
	end
fprintf(file,'# Begin Source File\n');
fprintf(file,' \n');
fprintf(file,'SOURCE=%s\\%s\n',srcDirectory,fileNameInfo.machineSourceFile);
fprintf(file,'# End Source File\n');
	if(~gTargetInfo.codingLibrary)
fprintf(file,'# Begin Source File\n');
fprintf(file,' \n');
fprintf(file,'SOURCE=%s\\%s\n',srcDirectory,fileNameInfo.machineRegistryFile);
fprintf(file,'# End Source File\n');
	end

fprintf(file,'# End Target\n');
fprintf(file,'# End Project\n');
fprintf(file,' \n');

	fclose(file);