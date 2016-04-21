function code_lcc_make_file(fileNameInfo)

% CODE_LCC_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.5.2.1 $  $Date: 2004/04/13 03:12:38 $

	global gMachineInfo gTargetInfo

	lccRoot = sf('Private','sf_get_component_root','lcc');

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
fprintf(file,'"%s\\bin\\lccmake" -f %s\n',lccRoot,fileNameInfo.lccMakeFile);
	fclose(file);

	projectInfo.targetDirName = fileNameInfo.targetDirName;
	projectInfo.handlesSpaces = 1;
	projectInfo.cc = [lccRoot,'\bin\lcc.exe'];
	projectInfo.ld = [lccRoot,'\bin\lcclnk.exe'];
	projectInfo.nameDirective = '-o ';
	projectInfo.libcmd = [lccRoot,'\bin\lcclib.exe'];

	if gTargetInfo.codingMakeDebug
		projectInfo.cflags = '-g4 -c -Zp8 -DMATLAB_MEX_FILE -noregistrylookup';
		projectInfo.ldflags = ['-dll',' -L"',lccRoot,'\lib"'];
	else
		projectInfo.cflags = '-c -Zp8 -DMATLAB_MEX_FILE -noregistrylookup';
		projectInfo.ldflags = ['-s -dll',' -L"',lccRoot,'\lib"'];
	end
	projectInfo.libflags = '';
	
	projectInfo.makeFileName = fileNameInfo.lccMakeFile;

	projectInfo.includeDirs{1} = [lccRoot,'\include'];
	projectInfo.includeDirs{end+1} = [fileNameInfo.matlabRoot,'\extern\include'];
	projectInfo.includeDirs{end+1} = [fileNameInfo.matlabRoot,'\simulink\include'];
	projectInfo.includeDirs{end+1} = fileNameInfo.sfcMexLibInclude;
	projectInfo.includeDirs{end+1} = fileNameInfo.sfcDebugLibInclude;
   if (~isempty(fileNameInfo.dspLibInclude))
      projectInfo.includeDirs{end+1} = fileNameInfo.dspLibInclude;
   end

 	projectInfo.includeDirs = [projectInfo.includeDirs,fileNameInfo.userIncludeDirs];
	projectInfo.libPath = [lccRoot,'\lib'];

	projectInfo.libraries = {};
  	if(~gTargetInfo.codingLibrary)
		projectInfo.libraries = fileNameInfo.linkLibFullPaths;
		projectInfo.libraries = [projectInfo.libraries,fileNameInfo.userLibraries];
		if(gTargetInfo.codingSFunction | gTargetInfo.codingMEX)
			projectInfo.libraries{end+1} = [lccRoot,'\mex\lccdef.def'];
		   projectInfo.libraries{end+1} = fileNameInfo.sfcDebugLibFile;
		   projectInfo.libraries{end+1} = fileNameInfo.sfcMexLibFile;
			projectInfo.libraries{end+1} = [fileNameInfo.matlabRoot,'\extern\lib\win32\lcc\libmex.lib'];
			projectInfo.libraries{end+1} = [fileNameInfo.matlabRoot,'\extern\lib\win32\lcc\libmx.lib'];
			projectInfo.libraries{end+1} = [fileNameInfo.matlabRoot,'\extern\lib\win32\lcc\libfixedpoint.lib'];
			projectInfo.libraries{end+1} = [fileNameInfo.matlabRoot,'\extern\lib\win32\lcc\libut.lib'];
         if (~isempty(fileNameInfo.dspLibFile))
            projectInfo.libraries{end+1} = fileNameInfo.dspLibFile;
         end			
		end
	end

	projectInfo.sourceFiles{1} = fileNameInfo.machineSourceFile;
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingSFunction
		projectInfo.sourceFiles{end+1} = fileNameInfo.machineRegistryFile;
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingMEX
		projectInfo.sourceFiles{end+1} = fileNameInfo.mexWrapperFile;
	end
	projectInfo.sourceFiles = [projectInfo.sourceFiles,fileNameInfo.chartSourceFiles];
	projectInfo.sourceFiles = [projectInfo.sourceFiles,fileNameInfo.userSources];
	if(~gTargetInfo.codingLibrary & (gTargetInfo.codingSFunction | gTargetInfo.codingMEX))
		projectInfo.sourceFiles{end+1} = [lccRoot,'\mex\lccstub.c'];
	end

	if(gTargetInfo.codingLibrary)
		projectInfo.codingLibrary = 1;
		projectInfo.outputFileName = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.lib'];
	else
		projectInfo.codingLibrary = 0;
		if(gTargetInfo.codingMEX & ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
			projectInfo.outputFileName = [sf('get',gMachineInfo.target,'target.mexFileName'),'.dll'];
		else
			projectInfo.outputFileName = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.dll'];
		end
	end
	projectInfo.preLinkCommand = '';
	projectInfo.postLinkCommand = '';

	lcc_make_gen(projectInfo);	

function lcc_make_gen(projectInfo)

	lccRoot = sf('Private','sf_get_component_root','lcc');

	fileName = fullfile(projectInfo.targetDirName,projectInfo.makeFileName);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	if(projectInfo.handlesSpaces)
		quoteChar = '"';
	else
		quoteChar = '';
	end

	DOLLAR = '$';
fprintf(file,'CC     = %s%s%s\n',quoteChar,projectInfo.cc,quoteChar);
fprintf(file,'LD     = %s%s%s\n',quoteChar,projectInfo.ld,quoteChar);
fprintf(file,'LIBCMD = %s%s%s\n',quoteChar,projectInfo.libcmd,quoteChar);
fprintf(file,'CFLAGS = %s\n',projectInfo.cflags);
fprintf(file,'LDFLAGS = %s\n',projectInfo.ldflags);
fprintf(file,'LIBFLAGS = %s\n',projectInfo.libflags);
fprintf(file,'\n');

	projectInfo.objectFiles = projectInfo.sourceFiles;
	for i=1:length(projectInfo.objectFiles)
		sourceFile = projectInfo.objectFiles{i};
		objectFile = [sourceFile(1:end-1),'obj'];
		fileSeps = find(objectFile=='\');
		if(~isempty(fileSeps))
			objectFile = objectFile(fileSeps(end)+1:end);
		end
		projectInfo.objectFiles{i} = objectFile;
	end

	includeDirString = '';
	if(length(projectInfo.includeDirs))
		for i = 1:length(projectInfo.includeDirs)
			includeDirString	= [includeDirString,' -I',quoteChar,projectInfo.includeDirs{i},quoteChar,' '];
		end
	end
	projectInfo.objectListFile = [projectInfo.makeFileName,'o'];
	projectInfo.objectListFilePath = fullfile(projectInfo.targetDirName,projectInfo.objectListFile);
	code_lcc_objlist_file(projectInfo.objectListFilePath,projectInfo.objectFiles,projectInfo.libraries,quoteChar)
fprintf(file,'OBJECTS = \\\n');
	for i= 1:length(projectInfo.objectFiles)
fprintf(file,'	%s%s%s\\\n',quoteChar,projectInfo.objectFiles{i},quoteChar);
	end
	for i= 1:length(projectInfo.libraries)
fprintf(file,'	%s%s%s\\\n',quoteChar,projectInfo.libraries{i},quoteChar);
	end
fprintf(file,'\n');
fprintf(file,'INCLUDE_PATH=%s\n',includeDirString);
fprintf(file,' \n');
fprintf(file,'\n');
	projectInfo.preLinkCommand = '';
	projectInfo.postLinkCommand = '';

	if projectInfo.codingLibrary
fprintf(file,'%s : %s(MAKEFILE) %s(OBJECTS)\n',projectInfo.outputFileName,DOLLAR,DOLLAR);
		if(~isempty(projectInfo.preLinkCommand))
fprintf(file,'	%s\n',projectInfo.preLinkCommand);
		end
fprintf(file,'	%s(LIBCMD) %s(LIBFLAGS) /OUT:%s *.obj\n',DOLLAR,DOLLAR,projectInfo.outputFileName);
		if(~isempty(projectInfo.postLinkCommand))
fprintf(file,'	%s\n',projectInfo.postLinkCommand);
		end
	else
fprintf(file,'%s : %s(MAKEFILE) %s(OBJECTS)\n',projectInfo.outputFileName,DOLLAR,DOLLAR);
		if(~isempty(projectInfo.preLinkCommand))
fprintf(file,'	%s\n',projectInfo.preLinkCommand);
		end
fprintf(file,'	%s(LD) %s(LDFLAGS) %s%s @%s\n',DOLLAR,DOLLAR,projectInfo.nameDirective,projectInfo.outputFileName,projectInfo.objectListFile);
		if(~isempty(projectInfo.postLinkCommand))
fprintf(file,'	%s\n',projectInfo.postLinkCommand);
		end
	end

	for i=1:length(projectInfo.sourceFiles)
fprintf(file,'%s :	%s%s%s\n',projectInfo.objectFiles{i},quoteChar,projectInfo.sourceFiles{i},quoteChar);
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) %s%s%s\n',DOLLAR,DOLLAR,DOLLAR,quoteChar,projectInfo.sourceFiles{i},quoteChar);
	end

	fclose(file);

function code_lcc_objlist_file(objListFile,objectFiles,libraryFiles,quoteChar)

	fileName = objListFile;
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	for i=1:length(objectFiles)
fprintf(file,'%s%s%s\n',quoteChar,objectFiles{i},quoteChar);
	end
	for i=1:length(libraryFiles)
fprintf(file,'%s%s%s\n',quoteChar,libraryFiles{i},quoteChar);
	end

	fclose(file);
