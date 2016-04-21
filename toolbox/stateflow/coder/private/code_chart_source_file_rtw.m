function code_chart_source_file_rtw(fileNameInfo,chart)

%%   Copyright 1995-2004 The MathWorks, Inc.
%%   $Revision: 1.1.6.10.2.1 $  $Date: 2004/04/13 03:12:38 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   global gMachineInfo gChartInfo

   chartNumber = sf('get',chart,'chart.number');
   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end

fprintf(file,'%%implements "chartSource" "C"\n');

fprintf(file,'%%function ChartConfig(block, system) void\n');
fprintf(file,'  %%createrecord chartConfiguration { ...\n');
fprintf(file,'          executeAtInitialization  %.15g ...\n',sf('get',chart,'chart.executeAtInitialization'));
fprintf(file,'  }\n');
fprintf(file,'  %%return chartConfiguration\n');
fprintf(file,'%%endfunction\n');

fprintf(file,'%%function ChartFunctions(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
      excludedFcn = x.chartGateway.ptr(1);
      funcs = sf('Cg','get_unshared_functions',chart);
fprintf(file,'   %%openfile chartFcnsBuf\n');

        % Inserting Target Math Fcn generation here
        fcnGenString = sf('Cg','get_module_used_target_fcns',chart);
fprintf(file,'     %s\n',strip_trailing_new_lines(fcnGenString));
%        % Inserting Target Math Includes here
%        moduleIncludeString = sf('Cg','get_module_target_include_directives',chart);
%...     $strip_trailing_new_lines(moduleIncludeString)$

        
         namedConsts = sf('Cg','get_named_consts',chart);
         for namedConst = namedConsts
            codeStr = sf('Cg','get_named_const_def',namedConst,1);
fprintf(file,'         %s\n',strip_trailing_new_lines(codeStr));
         end

         if(sf('Feature','RTW New Symbol Naming'))
            fcnNames = {};
            for func = funcs
               fcnName = sf('Cg','get_symbol_name', func);
               fcnName = fcnName(1:end-1);

               % Filter undesirable portions of identifier
               fcnName = strrep(fcnName, '%', '');
               fcnName = strrep(fcnName, '<LibSFUniquePrefix(block)>', '');
               fcnName = strrep(fcnName, '<block.SymbolMapping.', '');
               fcnName = strrep(fcnName, '>', '');

               fcnNames{end+1} = fcnName;
            end
            sf('set',chart,'chart.rtwInfo.sfSymbols', fcnNames);
         end

         for func = funcs
            codeStr = sf('Cg','get_fcn_decl',func,1);
fprintf(file,'         %s\n',strip_trailing_new_lines(codeStr));
         end
         
         for func = funcs
            if func{1}.ptr(1) ~= excludedFcn
               codeStr = sf('Cg','get_fcn_def',func,1);
fprintf(file,'            %s\n',strip_trailing_new_lines(codeStr));
            end
         end
fprintf(file,'   %%closefile chartFcnsBuf\n');
fprintf(file,'   %%return chartFcnsBuf\n');
fprintf(file,'%%endfunction %%%% ChartFunctions\n');


fprintf(file,'%%function ChartSharedFunctions(block,system) void\n');
fprintf(file,'   %%openfile chartFcnsBuf\n');
         modelName = sf('get',get_relevant_machine,'machine.name');
         if(~rtw_gen_shared_utils(modelName))
            sharedFuncs = sf('Cg', 'get_shared_functions', chart);
            if(~isempty(funcs))
               for func = sharedFuncs
                  fcnName = sf('Cg','get_symbol_name', func);
                  fcnName = fcnName(1:end-1);
                  fcnDefCodeStr = sf('Cg','get_fcn_def',func,1);
fprintf(file,'                 %%if %%<!SFLibLookupUtilityFunction("%s")>\n',fcnName);
fprintf(file,'                    %s\n',strip_trailing_new_lines(fcnDefCodeStr));
fprintf(file,'                    %%<SFLibInsertUtilityFunction("%s")>\n',fcnName);
fprintf(file,'                 %%endif\n');
               end
            end
         end
fprintf(file,'   %%closefile chartFcnsBuf\n');
fprintf(file,'   %%return chartFcnsBuf\n');
fprintf(file,'%%endfunction %%%% ChartSharedFunctions\n');



% The chart gateway is always inlined so we only emit the body
% for this function
fprintf(file,'%%function Outputs(block,system) void\n');
      x = sf('Cg','get_cg_fcn_data',chart);
fprintf(file,'   %%openfile codeBuf\n');
         codeStr = sf('Cg','get_fcn_body',x.chartGateway);
fprintf(file,'      %s\n',strip_trailing_new_lines(codeStr));
fprintf(file,'   %%closefile codeBuf\n');
fprintf(file,'   %%return codeBuf\n');
fprintf(file,'%%endfunction  %%%% Outputs\n');

% The chart data initializer is always inlined so we only emit the body
% for this function
fprintf(file,'%%function InlinedInitializerCode(block,system) Output\n');
fprintf(file,'   %%<SLibResetSFChartInstanceAccessed(block)>\\\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartDataInitializer);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Initialize code for chart: %%<LibParentMaskBlockName(block)> */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');
fprintf(file,'\n');
% The chart enable is always inlined so we only emit the body
% for this function
fprintf(file,'%%function EnableUnboundOutputEventsCode(block,system) Output\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartEnable);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Enable code for chart: %%<LibParentMaskBlockName(block)> */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');
% The chart disable is always inlined so we only emit the body
% for this function
fprintf(file,'%%function DisableUnboundOutputEventsCode(block,system) Output\n');
fprintf(file,'   %%openfile initBodyBuf\n');
         x = sf('Cg','get_cg_fcn_data',chart);
         str = sf('Cg','get_fcn_body',x.chartDisable);
fprintf(file,'      %s\n',str);
fprintf(file,'   %%closefile initBodyBuf\n');
fprintf(file,'   %%if !WHITE_SPACE(initBodyBuf)\n');
fprintf(file,'      /* Disable code for chart: %%<LibParentMaskBlockName(block)> */\n');
fprintf(file,'      %%<initBodyBuf>\\\n');
fprintf(file,'   %%endif\n');
fprintf(file,'%%endfunction\n');
fprintf(file,'\n');




% Emit shared functions and header files.

fprintf(file,'%%function DumpSharedUtils(block,system) void\n');
   funcs = sf('Cg', 'get_shared_functions', chart);
   if(~isempty(funcs))
      modelName = sf('get',get_relevant_machine,'machine.name');
      if(rtw_gen_shared_utils(modelName))
fprintf(file,'      %%if EXISTS(::GenUtilsSrcInSharedLocation) && (::GenUtilsSrcInSharedLocation == 1)\n');
fprintf(file,'         %%if !ISFIELD(::CompiledModel, "RTWInfoMatFile")\n');
fprintf(file,'            %%<LoadRTWInfoMatFileforTLC()>\n');
fprintf(file,'         %%endif    \n');
         for func = funcs
            fcnName = sf('Cg','get_symbol_name', func);
            fcnName = fcnName(1:end-1);
            fcnDefCodeStr = sf('Cg','get_fcn_def',func,1);
            fcnDeclCodeStr = sf('Cg','get_fcn_decl',func,0);         
            sharedUtilTargetIncludes = sf('Cg','get_shared_fcn_target_includes',func);
            dump_single_shared_util(file, fcnName, fcnDefCodeStr, fcnDeclCodeStr, sharedUtilTargetIncludes);
         end
fprintf(file,'      %%else\n');
fprintf(file,'         %%error WISH change error message, unable to dump shared utils\n');
fprintf(file,'      %%endif  \n');
      end
   end
fprintf(file,'%%endfunction\n');

   fclose(file);
   try_indenting_file(fileName);
   sf('Cg','destroy_module',chart);


function dump_single_shared_util(file, fcnName, fcnDefCodeStr, fcnDeclCodeStr, sharedUtilTargetIncludes)
fprintf(file,' %%if %%<!SFLibLookupUtilityFunction("%s")>\n',fcnName);
fprintf(file,'     %%<SFLibInsertUtilityFunction("%s")>\n',fcnName);
fprintf(file,'     %%openfile defCode\n');
fprintf(file,'     %s\n',sharedUtilTargetIncludes);
fprintf(file,'     %s\n',fcnDefCodeStr);
fprintf(file,'     %%closefile defCode\n');
fprintf(file,'     %%openfile declCode\n');
fprintf(file,'     %s\n',fcnDeclCodeStr);
fprintf(file,'     %%closefile declCode\n');
fprintf(file,'     %%<SLibDumpUtilsSourceCode("%s", declCode, defCode)>\n',fcnName);
fprintf(file,' %%endif\n');


