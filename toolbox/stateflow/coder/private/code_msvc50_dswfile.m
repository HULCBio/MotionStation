function code_msvc50_dswfile(fileNameInfo)
% CODE_MSVC50_DSWFILE(FILENAMEINFO)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.2.2.1 $  $Date: 2004/04/13 03:12:39 $

	global gMachineInfo  gTargetInfo



	fileName = fileNameInfo.msvc50dswFile;
 	sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end


fprintf(file,'Microsoft Developer Studio Workspace File, Format Version 5.00\n');
fprintf(file,'# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!\n');
fprintf(file,' \n');
fprintf(file,'###############################################################################\n');
fprintf(file,' \n');
fprintf(file,'Project: "%s_%s"=.\\%s_%s.dsp - Package Owner=<4>\n',gMachineInfo.machineName,gMachineInfo.targetName,gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,' \n');
fprintf(file,'Package=<5>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'Package=<4>\n');
fprintf(file,'{{{\n');
	if ~gTargetInfo.codingLibrary & length(fileNameInfo.linkMachines)
		for i=1:length(fileNameInfo.linkMachines)
fprintf(file,'    Begin Project Dependency\n');
fprintf(file,'    Project_Dep_Name %s_%s\n',fileNameInfo.linkMachines{i},gMachineInfo.targetName);
fprintf(file,'    End Project Dependency\n');
		end
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingTMW & gTargetInfo.codingDebug
fprintf(file,'    Begin Project Dependency\n');
fprintf(file,'    Project_Dep_Name sfc_debugger\n');
fprintf(file,'    End Project Dependency\n');
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingTMW & gTargetInfo.codingSFunction
fprintf(file,'    Begin Project Dependency\n');
fprintf(file,'    Project_Dep_Name sfc_mex\n');
fprintf(file,'    End Project Dependency\n');
	end
fprintf(file,'}}}\n');
	if ~gTargetInfo.codingLibrary & length(fileNameInfo.linkMachines)
		for i=1:length(fileNameInfo.linkMachines)
			fullPathNameOfDspFile = fileNameInfo.linkMachineFullPaths{i};
			index = max(find(fullPathNameOfDspFile=='\'));
			if(~isempty(index))
				fullPathNameOfDspFile = fullPathNameOfDspFile(1:index-1);
			end
			fullPathNameOfDspFile = fullfile(fullPathNameOfDspFile,[fileNameInfo.linkMachines{i},'_',gMachineInfo.targetName,'.dsp']);
fprintf(file,'  \n');
fprintf(file,'###############################################################################\n');
fprintf(file,' \n');
fprintf(file,'Project: "%s_%s"=%s - Package Owner=<4>\n',fileNameInfo.linkMachines{i},gMachineInfo.targetName,fullPathNameOfDspFile);
fprintf(file,' \n');
fprintf(file,'Package=<5>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
fprintf(file,'Package=<4>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
		end
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingTMW & gTargetInfo.codingDebug
fprintf(file,'  \n');
fprintf(file,'###############################################################################\n');
fprintf(file,' \n');
fprintf(file,'Project: "sfc_debugger"=%s - Package Owner=<4>\n',fullfile(sf('Root'),'..','prj','sfc_debugger.vcproj'));
fprintf(file,' \n');
fprintf(file,'Package=<5>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
fprintf(file,'Package=<4>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
	end
	if ~gTargetInfo.codingLibrary & gTargetInfo.codingTMW & gTargetInfo.codingSFunction
fprintf(file,'  \n');
fprintf(file,'###############################################################################\n');
fprintf(file,' \n');
fprintf(file,'Project: "sfc_mex"=%s - Package Owner=<4>\n',fullfile(sf('Root'),'..','prj','sfc_mex.vcproj'));
fprintf(file,' \n');
fprintf(file,'Package=<5>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
fprintf(file,'Package=<4>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
	end
fprintf(file,'\n');
fprintf(file,'###############################################################################\n');
fprintf(file,'\n');
fprintf(file,'Global:\n');
fprintf(file,'\n');
fprintf(file,'Package=<5>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
fprintf(file,'Package=<3>\n');
fprintf(file,'{{{\n');
fprintf(file,'}}}\n');
fprintf(file,'\n');
fprintf(file,'###############################################################################\n');
fprintf(file,'\n');
fprintf(file,'\n');
	fclose(file);
