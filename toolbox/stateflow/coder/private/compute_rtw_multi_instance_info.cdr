function compute_rtw_multi_instance_info
 
global gMachineInfo gChartInfo gTargetInfo

gMachineInfo.multiInstancedChartsForRTW = zeros(length(gMachineInfo.charts),1);
if(gTargetInfo.codingRTW)
    if(gTargetInfo.codingLibrary & gMachineInfo.mainMachineId==0)
        construct_coder_error(gMachineInfo.machineId,'Cannot generate RTW code for a library model directly',1);
    end
    if(gTargetInfo.rtwMallocCodeFormat)
        codingRTWMICodeFormat = 1;
    elseif gTargetInfo.isErtMultiInstanced
        codingRTWMICodeFormat = 1;
    else
        codingRTWMICodeFormat = 0;
    end
    if(codingRTWMICodeFormat==1)
        gMachineInfo.multiInstancedChartsForRTW = ones(length(gMachineInfo.multiInstancedChartsForRTW),1);
    elseif(gTargetInfo.codingLibrary)
        if(1)
            modelH = sf('get',gMachineInfo.mainMachineId,'machine.simulinkModel');
            linkChartHandles = sf('get',gMachineInfo.mainMachineId,'machine.sfLinks');
            linkChartSources = get_param(linkChartHandles,'referenceblock');

            for i=1:length(gMachineInfo.charts)
                % G153466. We should not use sf('FullNameOf') here as
                % we need the exact fullname as known by simulink
                % in order for the strcmp to work. FullNameOf replaces
                % tabs and newlines with single spaces and not useful in this
                % context.
                blockH = sf('Private','chart2block',gMachineInfo.charts(i));
                sourceName = getfullname(blockH);
                linkInstances = strcmp(sourceName,linkChartSources);
                gMachineInfo.multiInstancedChartsForRTW(i) = sum(linkInstances)>1;
            end
        else
            gMachineInfo.multiInstancedChartsForRTW = ones(length(gMachineInfo.multiInstancedChartsForRTW),1);
            for i=1:length(gMachineInfo.charts)
                if(sf('get',gMachineInfo.charts(i),'chart.exportChartFunctions'))
                    gMachineInfo.multiInstancedChartsForRTW(i) = 0;
               	else
                    gMachineInfo.multiInstancedChartsForRTW(i) = 1;
                end
            end
        end
    end
    for i=1:length(gMachineInfo.charts)
        sf('set',gMachineInfo.charts(i),'chart.rtwInfo.isMultiInstanced',gMachineInfo.multiInstancedChartsForRTW(i));
    end
end
