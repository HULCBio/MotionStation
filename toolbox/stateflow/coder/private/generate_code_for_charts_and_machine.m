function generate_code_for_charts_and_machine(fileNameInfo,codingRebuildAll)

   global gMachineInfo
   global gTargetInfo

   incCodeGenInfo = compute_inc_codegen_info(fileNameInfo,codingRebuildAll);
   display_startup_message(fileNameInfo);
   genCount = 0;

   for i = 1:length(gMachineInfo.charts)
        chart = gMachineInfo.charts(i);
        if gTargetInfo.codingRTW
            sf('set', chart, 'chart.rtwInfo.codeGeneratedNow', incCodeGenInfo.flags(i));
        end
        if(~incCodeGenInfo.flags(i))
            continue;
        end
        
        genCount=genCount+1;
        if(mod(genCount,80)==0)
            newLine = 1;
        else
            newLine = 0;
        end
        display_chart_codegen_message(chart,newLine);
        try,
            compute_chart_information(chart);
            errorsOccurred = construct_module(chart);
        catch,
            errorsOccurred = 1;
            construct_coder_error(chart,lasterr,0);
        end

        if(errorsOccurred)
            continue;
        end
        
        code_chart_header_file(fileNameInfo,chart);
        code_chart_source_file(fileNameInfo,chart);
   end
   
   if gTargetInfo.codingRTW
        gMachineInfo.ctxInfo.eventVarUsed = false;
        for i = 1:length(gMachineInfo.charts)
            chart = gMachineInfo.charts(i);
            if(~incCodeGenInfo.flags(i))
                chartFileNumber = sf('get', chart, 'chart.chartFileNumber');
                chartNumber = find(incCodeGenInfo.infoStruct.chartFileNumbers==chartFileNumber);
                if (incCodeGenInfo.infoStruct.chartInfo(chartNumber).usesGlobalEventVar) 
                    gMachineInfo.ctxInfo.eventVarUsed = true;
                end
            else
                % if we are here, we have just generated the TLC file for this chart
                % chart.rtwInfo is uptodate 
                if sf('get', chart, 'chart.rtwInfo.usesGlobalEventVar')
                    gMachineInfo.ctxInfo.eventVarUsed = true;
                end
            end
        end
        
        for i = 1:length(fileNameInfo.linkMachines)
            infoStruct = sf('Private','infomatman','load','binary',fileNameInfo.linkMachines{i},'rtw');
            if any([infoStruct.chartInfo.usesGlobalEventVar]);
                gMachineInfo.ctxInfo.eventVarUsed = true;
            end
        end
   else
        gMachineInfo.ctxInfo.eventVarUsed = true;      
   end
   
   sf('Cg','construct_machine_module',gMachineInfo.ctxInfo);
   if(sf('Private','coder_error_count_man','get')==0)
      code_machine_header_file(fileNameInfo);
      code_machine_source_file(fileNameInfo);
      code_interface_and_support_files(incCodeGenInfo,fileNameInfo);
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_startup_message(fileNameInfo)
   global gMachineInfo
   msgString = sprintf('Code Directory :\n     "%s"\n',fileNameInfo.targetDirName);
   sf('Private','sf_display','Coder',msgString);

   msgString = sprintf('Machine (#%d): "%s"  Target (#%d): "%s"',gMachineInfo.machineId,gMachineInfo.machineName,gMachineInfo.target,gMachineInfo.targetName);
   sf('Private','sf_display','Coder',msgString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_chart_codegen_message(chart,newLine)
   chartFullName = sf('FullNameOf',chart,'/');
   chartShortName = chartFullName(max(find(chartFullName=='/'))+1:end);
   msgString = sprintf('\nChart "%s" (#%d):',chartShortName,chart);
   sf('Private','sf_display','Coder',msgString);
   if(newLine)
      sf('Private','sf_display','Coder','.',1);
   else
      sf('Private','sf_display','Coder','.',2);
   end      
