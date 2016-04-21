function code_chart_header_file_new(fileNameInfo,...
										  chart)


%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6.2.1 $  $Date: 2004/04/13 03:12:38 $


	chartNumber = sf('get',chart,'chart.number');

    fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1});
    sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
		return;
	end
fprintf(file,'%s\n',get_boiler_plate_comment('chart',chart));
fprintf(file,'%%implements "chartHeader" "C"\n');
fprintf(file,'%%function CacheOutputs(block,system,typeDefHFile,hFile,cFile) void\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Types
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile typedefsBuf\n');
    types = sf('Cg','get_types',chart);
   if(~isempty(types)) 
      chartInstanceTypdefGuard = ['_' upper(sf('get',chart,'chart.rtwInfo.chartInstanceTypedef')) '_'];
    for type = types
         codeStr = sf('Cg','get_type_def',type,0);
fprintf(file,'   %s\n',codeStr);
    end
   end
fprintf(file,'%%closefile typedefsBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(typedefsBuf)\n');
fprintf(file,'      %%openfile tempBuf\n');
fprintf(file,'#ifndef %s\n',chartInstanceTypdefGuard);
fprintf(file,'#define %s\n',chartInstanceTypdefGuard);
fprintf(file,'      %%<typedefsBuf>\\\n');
fprintf(file,' #endif /* %s */\n',chartInstanceTypdefGuard);
fprintf(file,'      %%closefile tempBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(typeDefHFile,"Typedefs",tempBuf)>\n');
fprintf(file,'   %%endif\n');
fprintf(file,'\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% function Decls
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'%%openfile externFcnsBuf\n');
    funcs = sf('Cg','get_unshared_functions',chart);
    for func = funcs
         codeStr = sf('Cg','get_fcn_decl',func,0);
fprintf(file,'   %s\n',strip_trailing_new_lines(codeStr));
    end
fprintf(file,'%%closefile externFcnsBuf\n');
fprintf(file,'%%<SLibSetModelFileAttribute(hFile,"ExternFcns",externFcnsBuf)>\n');


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% shared function Decls
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   modelName = sf('get',get_relevant_machine,'machine.name');
   if(~rtw_gen_shared_utils(modelName))
fprintf(file,'   %%openfile externFcnsBuf\n');
       funcs = sf('Cg','get_shared_functions',chart);
       for func = funcs
            codeStr = sf('Cg','get_fcn_decl',func,0);
            fcnName = sf('Cg','get_symbol_name', func);
            fcnName = fcnName(1:end-1);
fprintf(file,'         %%if %%<!SFLibLookupUtilityFunctionDecl("%s")>\n',fcnName);
fprintf(file,'            %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'            %%<SFLibInsertUtilityFunctionDecl("%s")>\n',fcnName);
fprintf(file,'         %%endif\n');
       end
fprintf(file,'   %%closefile externFcnsBuf\n');
fprintf(file,'   %%<SLibSetModelFileAttribute(hFile,"ExternFcns",externFcnsBuf)>\n');
   end

fprintf(file,'\n');
fprintf(file,'%%endfunction %%%% CacheOutputs\n');
	fclose(file);
	try_indenting_file(fileName);

