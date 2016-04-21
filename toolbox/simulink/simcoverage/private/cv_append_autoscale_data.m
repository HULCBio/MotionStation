function cv_append_autoscale_data(covData)

% Copyright 2003 The MathWorks, Inc.

% Cache metric names
allmetrics = cv_metric_names;

% Cache signal range
sigRange = covData.metrics.sigrange;

% Cache signal range isa enum
srIsa = cv('get','default','sigranger.isa');

% Cache top of coverage tree
topCov = cv('get', covData.rootID, '.topSlsf');

% Order the set of coverage IDs
[allIds, depths] = cv('DfsOrder', topCov, 'require', allmetrics.MTRC_SIGRANGE);
origins          = cv('get', allIds, 'slsfobj.origin');

for i = 1 : length(allIds)
	name = cv('get', allIds(i), '.name');
	[srID, isaVal] = cv('MetricGet', allIds(i), allmetrics.MTRC_SIGRANGE, '.id', '.isa');

	% If data originates from Stateflow and is range data
	if (origins(i) == 2) && (isaVal == srIsa)
		sfChartID   = cv('get', allIds(i), '.handle');
		sfBlockID   = sf('Private', 'chart2block', sfChartID);
		[dataNames, dataWidths, dataNumbers, dataIDs] = cv_sf_chart_data(sfChartID);

		% Sort the data items based on their number and
		% make the numbers contiguous from 0 to permit 
		% charts that contain temporary data.
        [notUsed,sortI] = sort(dataNumbers);
     	varCnt = length(dataNames);
     	dataNumbers = 0:(varCnt-1);
     	dataNames = dataNames(sortI);
     	dataWidths = dataWidths(sortI);
     	dataIDs = dataIDs(sortI);
 
		% Compute offset into signal range vector
		[portSizes, baseIndex] = cv('get', srID, '.cov.allWidths', '.cov.baseIdx');
		startIndex             = [1 cumsum(2 * portSizes) + 1];

		% When we find a stateflow chart we need to create entries for each
		% of the data  objects within the chart
		for dataIndex = 1 : length(dataNames)

			% Cache data ID and data type
			dataBlockName   = getfullname(sfBlockID);
			dataSystem      = bdroot(dataBlockName);
			dataChartName   = strrep(dataBlockName, '/', '_');
			dataName        = dataNames{dataIndex};
			dataID          = dataIDs(dataIndex);
			dataTypeDefined = sf('get', dataID, '.dataType');
			dataTypeActual  = sf('CoderDataType', dataID);
			dataSignalName  = [dataChartName '_' dataName '_' num2str(dataID)];

			% Log only data _defined_ as fixpt type.
			% NOTE: The actual data type may have been overridden
			if strcmp(dataTypeDefined, 'fixpt')

				% Cache data min/max
				dataRange = sigRange(baseIndex...
									 + startIndex(dataNumbers(dataIndex) + 1)...
									 + (0 : (2 * dataWidths(dataIndex) - 1)), :);
				dataMin = dataRange(1);
				dataMax = dataRange(2);

				% Cache fixpt type attributes
				[dataBaseType,...
				 dataFixExp,...
				 dataSlope,...
				 dataBias,...
				 dataNumBits,...
				 dataIsSigned] = sf('FixPtProps', dataID);
				
				% Get archive mode
				dataArchiveModeStr = get_param(dataSystem, 'MinMaxOverflowArchiveMode');

				% Log data
				cv('AutoscaleLog',...
				dataSignalName,...
				dataBlockName,...
				dataName,...
				dataTypeDefined,...
				dataTypeActual,...
				dataID,...
				dataMin,...
				dataMax,...
				dataSlope,...
				dataBias,...
				dataFixExp,...
				dataNumBits,...
				dataIsSigned,...
				dataArchiveModeStr);
			end; % if fixpt data type
		end; % For each data in sf chart
	end; % If data originates from Stateflow and is range data
end;
