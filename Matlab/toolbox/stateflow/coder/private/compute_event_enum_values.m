function  compute_event_enum_values(chart,...
                                   file,...
                                   defineFlag)
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.4.4.1 $  $Date: 2004/04/13 03:12:39 $

	global gChartInfo gMachineInfo gDataInfo

	for event = [gChartInfo.chartLocalEvents,gChartInfo.chartInputEvents]
		eventNumber = sf('get',event,'event.number');
		eventUniqueName = sf('CodegenNameOf',event);
		
		enumVal = eventNumber;
		enumStr = ['event_',eventUniqueName,gChartInfo.chartUniquePrefix];
		sf('set',event,'event.eventEnumStr',enumStr,'event.eventEnumeration',enumVal);
	end

	gChartInfo.statesWithEntryEvent = sf('find',gChartInfo.states,'state.hasEntryEvent',1);
	gChartInfo.statesWithExitEvent = sf('find',gChartInfo.states,'state.hasExitEvent',1);
	gChartInfo.dataWithChangeEvent = sf('find',gChartInfo.chartData,'data.hasChangeEvent',1);

	if(isempty(gChartInfo.chartEvents))
		gChartInfo.dataChangeEventThreshold = gMachineInfo.machineEventThreshold;
	else
		gChartInfo.dataChangeEventThreshold = max(sf('get',gChartInfo.chartEvents,'event.number'))+1;
	end

	enumVal = gChartInfo.dataChangeEventThreshold;
  	for data = gChartInfo.dataWithChangeEvent
		dataNumber = sf('get',data,'data.number');
		dataUniqueName = sf('CodegenNameOf',data);
		enumStr = ['data_change_in_',dataUniqueName,gChartInfo.chartUniquePrefix];
		sf('set',data,'data.changeEventEnumStr',enumStr,'data.changeEventEnumeration',enumVal);
		enumVal = enumVal+1;
	end
	gChartInfo.stateEntryEventThreshold = enumVal;
	for state = gChartInfo.statesWithEntryEvent
		enumStr = ['entry_to_',sf('CodegenNameOf',state),gChartInfo.chartUniquePrefix];
		sf('set',state,'state.entryEventEnumStr',enumStr,'state.entryEventEnumeration',enumVal);
		enumVal = enumVal+1;
	end

	gChartInfo.stateExitEventThreshold = enumVal;
	for state = gChartInfo.statesWithExitEvent
		enumStr = ['exit_from_',sf('CodegenNameOf',state),gChartInfo.chartUniquePrefix];
		sf('set',state,'state.exitEventEnumStr',enumStr,'state.exitEventEnumeration',enumVal);
		enumVal = enumVal+1;
	end
	if(enumVal>=255)
		str = sprintf('Total number of events seen by this chart exceeds 254.\n This is currently not supported.\n');
		if(gMachineInfo.machineEventThreshold)
			str = sprintf('%s\n Machine Events (Implicit+Explicit) = %d',str,gMachineInfo.machineEventThreshold);
		end
		if(length(gChartInfo.chartEvents))
			str = sprintf('%s\n Chart Parented Explicit Events = %d',str,length(gChartInfo.chartEvents));
		end
		if(length(gChartInfo.statesWithEntryEvent))
			str = sprintf('%s\n State Entry Implicit Events = %d',str,length(gChartInfo.statesWithEntryEvent));
		end
		if(length(gChartInfo.statesWithExitEvent))
			str = sprintf('%s\n State Exit Implicit Events = %d',str,length(gChartInfo.statesWithExitEvent));
		end
		if(length(gChartInfo.dataWithChangeEvent))
			str = sprintf('%s\n Data Change Implicit Events = %d',str,length(gChartInfo.dataWithChangeEvent));
		end

		construct_coder_error(chart,str,0);

	end
