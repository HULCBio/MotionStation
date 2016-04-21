function code_machine_header_file_rtw(fileNameInfo)
% CODE_MACHINE_HEADER_FILE(FILENAMEINFO)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5.2.1 $  $Date: 2004/04/13 03:12:38 $

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%  GLOBAL VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%% Coding options
	global gMachineInfo gTargetInfo



	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineHeaderFile);
    sf_echo_generating('Coder',fileName);
    machine = gMachineInfo.machineId;
    
	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
fprintf(file,'%%implements "machineHeader" "C"\n');
fprintf(file,'%%function CacheOutputs(block,system,pubHFile,prvHFile,cFile) void\n');
		
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% A few useful defines and includes from RTW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%if FEVAL("sf_rtw","usesDSPLibrary",CompiledModel.Name)\n');
fprintf(file,'   %%<LibAddToCommonIncludes("dsp_%s")>\n',fileNameInfo.rtwDspLibIncludeFileName);
fprintf(file,'%%endif\n');
    if ~gTargetInfo.codingLibrary
fprintf(file,'%%if PurelyIntegerCode==0\n');
fprintf(file,'%%<SLibAddToCommonIncludes("<stdlib.h>")>\n');
fprintf(file,'%%<SLibAddToCommonIncludes("<math.h>")>\n');
fprintf(file,'%%endif\n');
fprintf(file,'%%openfile definesBuf\n');
fprintf(file,'#ifndef min\n');
fprintf(file,'# ifndef rt_MIN\n');
fprintf(file,'#  include "rtlibsrc.h"\n');
fprintf(file,'# endif\n');
fprintf(file,'# define min rt_MIN\n');
fprintf(file,'#endif\n');
fprintf(file,'#ifndef max\n');
fprintf(file,'# define max rt_MAX\n');
fprintf(file,'#endif\n');
fprintf(file,'%%closefile definesBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(prvHFile,"Defines",definesBuf)>\n');
    end
    
    if(gTargetInfo.codingLibrary & gMachineInfo.parentTarget~=gMachineInfo.target)
      % custom code for this library is already included in the parent machine
    else
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %% Custom Code Included on the target
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'   %%openfile ccBuf\n');
   	customCodeString = sf('get',gMachineInfo.parentTarget,'target.customCode');
   	customCodeString = sf('Private','expand_double_byte_string',customCodeString);
fprintf(file,'   %s\n',customCodeString);
fprintf(file,'\n');
fprintf(file,'   %%closefile ccBuf\n');
fprintf(file,'   %%<SLibSetModelFileAttribute(prvHFile,"Includes",ccBuf)>\n');
fprintf(file,'\n');
   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Types
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile typedefsBuf   \n');
    types = sf('Cg','get_types',machine);
    for type = types
         codeStr = sf('Cg','get_type_def',type,0);
fprintf(file,'   %s         \n',codeStr);
    end
fprintf(file,'%%closefile typedefsBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(prvHFile,"Typedefs",typedefsBuf)>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Named Constants
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile definesBuf   \n');
    namedConsts = sf('Cg','get_named_consts',machine);
    for namedConst = namedConsts
         codeStr = sf('Cg','get_named_const_def',namedConst,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile definesBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(prvHFile,"Defines",definesBuf)>\n');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Vars
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile externDataBuf\n');
    vars = sf('Cg','get_non_exported_vars',machine);
    for var = vars
         codeStr = sf('Cg','get_var_decl',var,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(prvHFile,"ExternData",externDataBuf)>\n');

fprintf(file,'%%openfile externDataBuf\n');
    vars = sf('Cg','get_exported_vars',machine);
    for var = vars
         codeStr = sf('Cg','get_var_decl',var,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(pubHFile,"ExternData",externDataBuf)>\n');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% function Decls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'%%openfile externDataBuf\n');
fprintf(file,'\n');
    funcs = sf('Cg','get_functions',machine);
    for func = funcs
        codeStr = sf('Cg','get_fcn_decl',func,0);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
    end
    if(gTargetInfo.codingLibrary & gMachineInfo.parentTarget~=gMachineInfo.target)
      % exported fcns are already included in the parent machine
    else
%       dump_exported_fcn_prototypes(file);
    end
fprintf(file,'%%closefile externDataBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(prvHFile,"ExternFcns",externDataBuf)>\n');

fprintf(file,'%%endfunction %%%% CacheOutputs\n');
fprintf(file,'	\n');
fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

	 		