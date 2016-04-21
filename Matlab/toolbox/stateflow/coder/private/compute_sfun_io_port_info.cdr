function portInfo = compute_sfun_io_port_info(chart,preInference)
      
   %%%%%%%%%IMPORTANT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % This function needs to be self-sufficient in order to be called
   % independent of a codegen session. DO not USE any CODEGEN GLOBALS
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

   disableImplicitCasting = sf('get',chart,'chart.disableImplicitCasting');
   chartParentedData = sf('DataOf',chart);
   chartInputData = sf('find',chartParentedData,'data.scope','INPUT_DATA');
   chartOutputData = sf('find',chartParentedData,'data.scope','OUTPUT_DATA');

   chartEvents = sf('EventsOf',chart);
   chartOutputEvents = sf('find',chartEvents,'event.scope','OUTPUT_EVENT');
   chartInputEvents = sf('find',chartEvents,'event.scope','INPUT_EVENT');
   chartFcnCallOutputEvents = sf('find',chartOutputEvents,'event.trigger','FUNCTION_CALL_EVENT');

	numInputPorts = length(chartInputData) + ~isempty(chartInputEvents);
	if numInputPorts == 0
	   inputPortInfo = get_data_props;
	else
		%%% set input ports for data
	   inputPortInfo = get_data_props;
	   inputPortInfo(:) = [];
		for dataId = chartInputData
		   thisPortInfo = get_data_props(dataId,disableImplicitCasting,preInference);
		   inputPortInfo(end+1) = thisPortInfo;
		end
		%%% set input port for events
		%%% all events must be vectored into one port
		%%% type of event ports is always real
		if ~isempty(chartInputEvents)
		   dataProps = get_data_props;
			if(disableImplicitCasting==0)
			   dataProps.type.name = 'SS_DOUBLE';
			else
			   dataProps.type.name = 'SS_INT8';
			end
			dataProps.dims = length(chartInputEvents);
			dataProps.contiguous = 0;
			inputPortInfo(end+1) = dataProps;
		end
   end
   		
	%%% set number of s-function output ports
	%%% output function call events must be packed into port 0
	numOutputPorts = length(chartOutputData) + length(chartOutputEvents) ...
		- length(chartFcnCallOutputEvents) + 1;
   
   dataProps = get_data_props;		
	if isempty(chartFcnCallOutputEvents)
	   dataProps.dims = 1;
	else
	   dataProps.dims = length(chartFcnCallOutputEvents);
	end
	
	outputPortInfo = dataProps;

	%%% set output ports for data
	for dataId = chartOutputData
		outputPortInfo(end+1) = get_data_props(dataId,disableImplicitCasting,preInference);
	end

	%%% set output ports for other events
		%%% width is always 1, type is always real
	for event = sf('find',chartOutputEvents,'~event.trigger','FUNCTION_CALL_EVENT')
		dataProps = get_data_props;
		if(disableImplicitCasting~=0)
         dataProps.type.name = 'SS_BOOLEAN';
		end
		outputPortInfo(end+1) = dataProps;
	end
	
	portInfo.input = inputPortInfo;
	portInfo.output = outputPortInfo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataProps = get_data_props(dataId,disableImplicitCasting,preInference)
   
   dataProps.isComplex = 0;
   dataProps.type.name = 'SS_DOUBLE';
   dataProps.type.baseType = '';
   dataProps.type.fixptExponent = 0;
   dataProps.type.fixptSlope = 1;
   dataProps.type.fixptBias = 0;
   dataProps.dims = 1;
   dataProps.contiguous = 0;
   dataProps.dataId = 0;
   
   if(nargin==0)
      return;
   end      
   
   dataProps.dataId = dataId;
   
   if(preInference) 
      if(sf('get',dataId,'data.inheritDataSize'))
         dataSize = -1;
      end
   else   
   	dataSize = sf('get',dataId,'data.parsedInfo.array.size');
   	if isempty(dataSize)
   		dataSize = 1;
   	end
   end
   
	dataProps.isComplex = sf('get', dataId, '.isComplex');
	actualDataType = sf('CoderDataType',dataId);
	if(strcmp(actualDataType,'fixpt'))
		[fixPtBaseType,fixptExponent,fixptSlope,fixptBias] =...
			sf('FixPtProps',dataId);
      dataProps.type.name = 'fixpt';
		dataProps.type.baseType = sl_type_enum_from_name(fixPtBaseType);
		dataProps.type.fixptExponent = fixptExponent;
		dataProps.type.fixptSlope = fixptSlope;
		dataProps.type.fixptBias = fixptBias;            
	else
		if(disableImplicitCasting==1)
         dataProps.type.name = sl_type_enum_from_name(actualDataType);
		else
         dataProps.type.name = 'SS_DOUBLE';
		end
	end
	if(length(dataSize)<2)	
	   dataProps.dims = dataSize(1);
	else
	   dataProps.dims = [dataSize(1),dataSize(2)];
	end
   dataProps.contiguous = 1;
	
