function code_machine_source_file_rtw(fileNameInfo)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2.4.1 $  $Date: 2004/04/13 03:12:39 $


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%  GLOBAL VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global gMachineInfo gTargetInfo
		
    machine = gMachineInfo.machineId;

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineSourceFile);
    sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
fprintf(file,'%%implements "machineSource" "C"\n');


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Var Definitions
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%function CacheMachineDefinitions(block,system,hFile,cFile) void\n');
fprintf(file,'%%openfile tmpFcnBuf\n');
   vars = sf('Cg','get_vars',machine);
   for var = vars
         codeStr = sf('Cg','get_var_def',var,1);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,'%%closefile tmpFcnBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(cFile,"Definitions",tmpFcnBuf)>\\\n');
fprintf(file,'\n');
fprintf(file,'%%endfunction\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Inlined Machine Data Initializer
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%function DumpMachineInitializer(block) Output\n');
fprintf(file,'\n');
fprintf(file,'%%openfile tmpFcnBuf\n');
    x = sf('Cg','get_cg_fcn_data',gMachineInfo.machineId);
    str = sf('Cg','get_fcn_body',x.dataInitializer);
fprintf(file,'%s\n',str);
fprintf(file,'%%closefile tmpFcnBuf\n');
fprintf(file,'%%if !WHITE_SPACE(tmpFcnBuf)\n');
fprintf(file,'\n');
fprintf(file,'  %s\n',sf_comment('/* Machine initializer */'));
fprintf(file,'  %%<tmpFcnBuf>\\\n');
fprintf(file,'%%endif\n');
fprintf(file,'%%endfunction\n');

fprintf(file,'%%function GlobalMachineInitializer(block) void\n');
fprintf(file,'  %%openfile tmpFcnBuf\n');
fprintf(file,'  %%<DumpMachineInitializer(block)>\\\n');
    for i=1:length(fileNameInfo.linkMachines)
    	if(strcmp(fileNameInfo.linkMachinesInlinable{i},'No'))
fprintf(file,'  %%generatefile "machineSource" "%s_rtw.tlc"\n',fileNameInfo.linkMachines{i});
fprintf(file,'  %%<GENERATE_TYPE(block,"DumpMachineInitializer","machineSource")>\\\n');
    	end
    end
fprintf(file,'  %%closefile tmpFcnBuf\n');
fprintf(file,'  %%return tmpFcnBuf				\n');
fprintf(file,'%%endfunction %%%% GlobalMachineInitializer\n');
fprintf(file,'\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Inlined Machine Data Terminator
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%function DumpMachineTerminator(block) Output\n');
fprintf(file,'%%openfile tmpFcnBuf\n');
	x = sf('Cg','get_cg_fcn_data',gMachineInfo.machineId);
    str = sf('Cg','get_fcn_body',x.dataFinalizer);
fprintf(file,'%s\n',str);
fprintf(file,'%%closefile tmpFcnBuf\n');
fprintf(file,'%%if !WHITE_SPACE(tmpFcnBuf)\n');
fprintf(file,'\n');
fprintf(file,'  %s\n',sf_comment('/* Machine initializer */'));
fprintf(file,'  %%<tmpFcnBuf>\\\n');
fprintf(file,'%%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'%%function GlobalMachineTerminator(block) void\n');
fprintf(file,'  %%openfile tmpFcnBuf\n');
fprintf(file,'  %%<DumpMachineTerminator(block)>\\\n');
    for i=1:length(fileNameInfo.linkMachines)
        if(strcmp(fileNameInfo.linkMachinesInlinable{i},'No'))
fprintf(file,'  %%generatefile "machineSource" "%s_rtw.tlc"\n',fileNameInfo.linkMachines{i});
fprintf(file,'  %%<GENERATE_TYPE(block,"DumpMachineTerminator","machineSource")>\\\n');
		end
	end
fprintf(file,'  %%closefile tmpFcnBuf\n');
fprintf(file,'  %%return tmpFcnBuf				\n');
fprintf(file,'%%endfunction %%%% GlobalMachineTerminator\n');
fprintf(file,'\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% function Definitions
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'%%function CacheMachineFunctions(block,system,hFile,cFile) void\n');
fprintf(file,'  %%openfile tmpFcnBuf\n');
    funcs = sf('Cg','get_functions',machine);
    for func = funcs
         codeStr = sf('Cg','get_fcn_def',func,1);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'  %%closefile tmpFcnBuf\n');
fprintf(file,'  %%<SLibSetModelFileAttribute(cFile,"Functions",tmpFcnBuf)>\n');
fprintf(file,'%%endfunction\n');
    fclose(file);


