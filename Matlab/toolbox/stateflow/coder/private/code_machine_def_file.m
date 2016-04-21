function code_machine_def_file(fileNameInfo,codingBorland)
% CODE_MACHINE_DEF_FILE(FILENAMEINFO)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1.4.1 $  $Date: 2004/04/13 03:12:38 $

	global gMachineInfo gTargetInfo


	if codingBorland & gTargetInfo.codingMEX & ~isempty(sf('get',gMachineInfo.target,'target.mexFileName'))
		fileName = fullfile(fileNameInfo.targetDirName,[sf('get',gMachineInfo.target,'target.mexFileName'),'.def']);
	else
		fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineDefFile);
	end
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	if codingBorland
fprintf(file,'EXPORTS\n');
fprintf(file,'mexFunction = _mexFunction\n');
	else
		if gTargetInfo.codingMEX
			if(~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
fprintf(file,'LIBRARY   %s\n',sf('get',gMachineInfo.target,'target.mexFileName'));
			else
fprintf(file,'LIBRARY   %s_%s\n',gMachineInfo.machineName,gMachineInfo.targetName);
			end
		else
fprintf(file,'LIBRARY   %s_sfun\n',gMachineInfo.machineName);
		end
fprintf(file,'CODE      PRELOAD MOVEABLE DISCARDABLE\n');
fprintf(file,'DATA      PRELOAD MOVEABLE SINGLE\n');
fprintf(file,'HEAPSIZE  1024\n');
fprintf(file,'EXPORTS\n');
fprintf(file,'	mexFunction\n');
	end
	fclose(file);
