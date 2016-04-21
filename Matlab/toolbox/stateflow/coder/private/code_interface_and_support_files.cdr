function code_interface_and_support_files(incCodeGenInfo,fileNameInfo)

    global gTargetInfo gMachineInfo

    if(~gTargetInfo.codingSFunction)
      return;
    end
    if(gTargetInfo.codingDebug)
       code_debug_macros(fileNameInfo);
    end

    %% Generate the interface files only when there are no codegen errors
     msgString = sprintf('\nInterface and Support files:');
     sf('Private','sf_display','Coder',msgString);

    if(~gTargetInfo.codingLibrary & gTargetInfo.codingSFunction)
        code_machine_registry_file(fileNameInfo);
    end

     lastBuildDate = incCodeGenInfo.infoStruct.date;
     makefileCheckSumChanged = all(incCodeGenInfo.flags) |...
                              (~isequal(incCodeGenInfo.infoStruct.makefileChecksum,...
                                        sf('get',gMachineInfo.machineId,'machine.makefileChecksum')));
     if gTargetInfo.codingMSVC42Makefile

         if makefileCheckSumChanged | ...
           ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile),lastBuildDate)
             code_msvc_make_file(fileNameInfo);
         end
     end
     if gTargetInfo.codingWatcomMakefile
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.watcomMakeFile),lastBuildDate)
             code_watcom_make_file(fileNameInfo);
         end
     end
     if gTargetInfo.codingBorlandMakefile
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.borlandMakeFile),lastBuildDate)
             code_borland_make_file(fileNameInfo);
         end
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.machineDefFile),lastBuildDate)
             code_machine_def_file(fileNameInfo,1);
         end
     end
     if gTargetInfo.codingMSVC50Makefile
         if ~gTargetInfo.codingMSVC42Makefile
             if makefileCheckSumChanged | ...
                ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile),lastBuildDate)
                 code_msvc_make_file(fileNameInfo);
             end
         end
     end
     if sf('Feature','Developer')
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.msvc50MakeFile),lastBuildDate)
             code_msvc50_makefile(fileNameInfo);
             code_msvc50_dswfile(fileNameInfo);
         end
     end
     if gTargetInfo.codingUnixMakefile
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.unixMakeFile),lastBuildDate)
             code_unix_make_file(fileNameInfo);
         end
     end

     if (~isunix & gTargetInfo.codingLccMakefile & ...
         ~gTargetInfo.codingMSVC42Makefile & ...
         ~gTargetInfo.codingBorlandMakefile & ...
         ~gTargetInfo.codingWatcomMakefile)
         if makefileCheckSumChanged | ...
            ~check_if_file_is_in_sync(fullfile(fileNameInfo.targetDirName,fileNameInfo.lccMakeFile),lastBuildDate)
             code_lcc_make_file(fileNameInfo);
         end
     end

    sf('Private','sf_display','Coder',sprintf('\n'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = check_if_file_is_in_sync(fileName,buildDate)

result = sf('Private','check_if_file_is_in_sync',fileName,buildDate);
