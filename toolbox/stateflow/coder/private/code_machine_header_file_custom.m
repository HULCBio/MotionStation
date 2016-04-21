function code_machine_header_file_custom(fileNameInfo)
% CODE_MACHINE_HEADER_FILE(FILENAMEINFO)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2.4.1 $  $Date: 2004/04/13 03:12:38 $

	global gTargetInfo gMachineInfo
	

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineHeaderFile);
   sf_echo_generating('Coder',fileName);
   machine = gMachineInfo.machineId;
    
   file = fopen(fileName,'wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end             

fprintf(file,'%s	\n',get_boiler_plate_comment('machine',machine));
	
fprintf(file,'#ifndef __%s_%s_h__\n',gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'#define __%s_%s_h__\n',gMachineInfo.machineName,gMachineInfo.targetName);
fprintf(file,'\n');
fprintf(file,'%s\n',sf('Private','target_methods','MachineHeaderTop',gMachineInfo.target));
fprintf(file,'#include "tmwtypes.h"\n');
fprintf(file,'\n');
	customCodeString = sf('get',gMachineInfo.parentTarget,'target.customCode');
	if(~isempty(customCodeString))
    	customCodeString = sf('Private','expand_double_byte_string',customCodeString);
fprintf(file,'/* Custom Code from Simulation Target dialog*/    	\n');
fprintf(file,'%s\n',customCodeString);
fprintf(file,'\n');
   end

   file = dump_module(fileName,file,machine,'header');
   if file < 3
     return;
   end
   
   dump_exported_fcn_prototypes(file);
fprintf(file,'\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
	
fprintf(file,'\n');

	fclose(file);
	try_indenting_file(fileName);



	 		