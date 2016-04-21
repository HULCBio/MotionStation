function [ret1,ret2] = modelref_conversion_bus_utils(fcnName,arg2,arg3,arg4,...
                                                  arg5,arg6) 
%
% This file contains several functions used by the automatic conversion to
% model reference for handling buses
%  $Revision: 1.1.6.6 $

  ret1 = [];
  ret2 = [];

  switch(fcnName)

   case 'find_bus_definition'
    [ret1, ret2] = find_bus_definition(arg2,arg3,arg4);

   case 'define_downstream_buses'
    ret1 = define_downstream_buses(arg2,arg3,arg4,arg5);

   case 'handle_other_instance_buses'
    ret1 = handle_other_instance_buses(arg2,...
                                       arg3,...
                                       arg4,...
                                       arg5,...
                                       arg6);
   case 'save_bus_in_m'
    save_bus_in_m(arg2,arg3);

   case 'print_bus_m_header'
    print_bus_m_header(arg2,arg3,arg4,arg5);

   case  'save_bus_in_mat'
    save_bus_in_mat(arg2,arg3);

   case 'save_nonbus_data_types_in_m'
    save_nonbus_data_types_in_m(arg2,arg3);
  
   case 'is_datatype_builtin' 
    ret1 = is_datatype_builtin(arg2);
    
    %These are functions in this file that are only used locally
    %generate_bus_object
    %set_elems_from_port_and_block
    %bus_types_are_equal
    %check_this_bus_level
    %get_bus_name_from_list
    %add_item_to_bus_list
    %get_nonbus_unique_data_types

   otherwise
    error('ModelRefConv:Fatal',...
          'fatal error: invalid function name');
  end

%%%%%%%%%%%%%%%%%%%%%%%%%
% find_bus_definition
% This function defines bus objects for the tree of bus creators
% contained in busInfo which is the output of
%     get_param(some input port,'BusStruct')
%
% The busCreatorObjects structure is modified to contain the information
% for all of the busObjects created during building up this bus object 
% definition

function [newBusName, busCreatorObjects] = find_bus_definition(busInfo,...
                                                    busCreatorObjects,...
                                                    topModel)

  % The busInfo struct contains the following fields: name, src, srcPort,
  % busObjectName, and signals where signals is an array of structures of
  % the same type as busInfo

  % If we do not have a bus creator, just return with an empty
  % bus name
  blkType = get_param(busInfo.src, 'BlockType');
  if ~strcmp(blkType,'BusCreator')
    newBusName = [];
    return
  end

  % Finally actually generate the bus object
  [newBusName,busCreatorObjects] = generate_bus_object(busInfo,...
                                                    busCreatorObjects);

  thisRefBlk = get_param(busInfo.src,'ReferenceBlock');
  if ~isempty(thisRefBlk)
    % If it's a link block check that all other instances have the same
    % bus definition
    otherInstances = find_system(topModel,'LookUnderMasks','all',...
                                        'FollowLinks','on',...
                                        'ReferenceBlock',thisRefBlk);
    for idx =1:length(otherInstances)
      lineHs   = get_param(otherInstances(idx),'LineHandles');
      dstPortH = get_param(lineHs.Outport(1),'DstportHandle');
      otherBusInfo  = get_param(dstPortH(1),'BusStruct');
      otherBusName =generate_bus_object(otherBusInfo,busCreatorObjects);
      areSame = bus_types_are_equal(evalin('base',newBusName),...
                                 evalin('base',otherBusName));
      if ~areSame
        error('ModelRefConv:linkBusError',...
              ['Encountered a bus creator, ',...
               getfullname(busInfo.src),...
               ', which is a link and ',...
               'not all instances have the same bus definition']);
      end
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%
% generate_bus_object %
% This is the function that actually defines the bus objects
%
function [newBusName, ...
          busCreatorObjects] = generate_bus_object(busInfo,busCreatorObjects)
  
  % If this source is already in the busCreatorObjects list 
  % we can get the name. If it's not, this function returns empty
  newBusName = get_bus_name_from_list(busInfo.src,busCreatorObjects);
  if ~isempty(newBusName)
    return;
  end

  for i = 1:length(busInfo.signals)
    elems(i) = Simulink.BusElement;
    elems(i).Name = busInfo.signals(i).name;
    srcBlk  = busInfo.signals(i).src;
    % if a bus object has already been defined use that
    if ~isempty(busInfo.signals(i).busObjectName)
      elems(i).DataType = busInfo.signals(i).busObjectName;
    elseif ~isempty(busInfo.signals(i).signals)
      if strcmp(get_param(busInfo.signals(i).src,'BlockType'),'Mux')

        % Mux blocks do not get bus objects
        muxBlk = busInfo.signals(i).src;
        muxPorts=get_param(muxBlk,'PortHandles');
        muxOut = muxPorts.Outport;
        elems = set_elems_from_port_and_block(muxOut,1,muxBlk,elems,i);

      else
        % Src is a bus creator
        [subBusName,busCreatorObjects] = generate_bus_object(...
            busInfo.signals(i),busCreatorObjects);
        elems(i).DataType = subBusName;
        if isempty(subBusName)
          error('ModelRefConv:Fatal',...
                'fatal error: empty subBusName');
        end
      end
    else
      % This signal is not a bus, just get the data for the element
      srcPort = busInfo.signals(i).srcPort;
      if ishandle(srcBlk)

        allPortH = get_param(srcBlk,'PortHandles');
        if srcPort > 0
          srcPortH = allPortH.Outport(srcPort);
        else
          srcPortH = allPortH.Inport(-srcPort);
        end
        elems = set_elems_from_port_and_block(srcPortH,srcPort,srcBlk,elems,i);
      end
    end
  end
  object = Simulink.Bus;
  object.Elements = elems;

  % Determine name of bus object
  % try to get the bus name from the name of the signal leaving the bus creator
  portHs         = get_param(busInfo.src,'PortHandles');
  newBusName     = get_param(portHs.Outport,'Name');
  newBusNameExists = evalin('base',['exist(''',newBusName,''')']);

  if newBusNameExists  || isempty(newBusName)
    defaultBusName = ['bus',num2str(length(busCreatorObjects))];
    if newBusNameExists
      warning(['Cannot use the signal name ''',...
               newBusName,...
             ''' as the busObject name for block '''...
               getfullname(busInfo.src),...
             ''' because a variable already exists with that name. ',...
               'Using default identifier: ''',defaultBusName,''' instead.']);
    end
    newBusName = defaultBusName;
  end
  assignin('base', newBusName, object);

  % Add this info to the busCreatorObjects structure
  busCreatorObjects = add_item_to_bus_list(busCreatorObjects,...
                                           newBusName,...
                                           busInfo.src);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_elems_from_port_and_block
% Create the entry in the bus object for this particular signal
function elems = set_elems_from_port_and_block(portH,portIdx,blkH,elems,elemsIdx)


%Limitation: Fixed-Point data types and Other Simulink.NumericType objects
%need to be defined in the base work space to be used with buses

  compDataType =  get_param(portH, 'CompiledPortDataType');

  if(is_datatype_builtin(compDataType))
    elems(elemsIdx).DataType = compDataType;
  elseif((strncmp(compDataType, 'sfix', 4) ||...
          strncmp(compDataType, 'ufix', 4) ||...
          strncmp(compDataType, 'flt', 3)))
    
    %Create fix-point data types in the base workspace
    %Once geck 213743 is resolved, this will not be necessary.
    %Instead the data type will be set to an expression that
    %returns a Simulink.NumericType
    
    [dInfo,ScaledDouble] = fixdt(compDataType);
    
    %Supporting Scaled Doubles is put off until geck 213811 is
    %resolved for bu signals
    if(ScaledDouble)
      error('ModelRefConv:UnsupportedBusDataType',...
            ['Block ''',get_param(portH,'Parent'),''' output port ',...
             num2str(portIdx), ' defines a signal of data type ''',compDataType,... 
             ''' which is not supported for bus objects']);
    end  
    typeName =['mdlref_',compDataType];
    assignin('base',typeName,fixdt(compDataType))
    elems(elemsIdx).DataType = typeName;
  else
    error('ModelRefConv:UnsupportedBusDataType',...
          ['Block ''',get_param(portH,'Parent'),''' output port ',...
           num2str(portIdx), ' defines a signal of data type ''',compDataType,... 
           ''' which is not supported for bus objects']);
  
  end

  dims = get_param(portH, 'CompiledPortDimensions');
  % The first element of dims is the number of elements in dims
  % we do not want that to be part of the setting in the bus object
  % so remove it
  % If we have a mux that is reporting a bus, assume that the
  % elements are all one dimensional
  if dims(1) == -2
    newDims = 0;
    currIdx = 3;
    for elIdx = 1:dims(2)
      if dims(currIdx) == 2
         thisDims = dims(currIdx+1) * dims(currIdx+2);
         currIdx = currIdx + 3;
      else
         if dims(currIdx) ~= 1
           error('Fatal');
         end
         thisDims = dims(currIdx+1);
         currIdx = currIdx + 2;
      end
      newDims = newDims + thisDims;
    end

    %dims = dims(2);
  else
    dims(1) = [];
  end
  elems(elemsIdx).Dimensions = dims;

  cplxFlags = get_param(portH, 'CompiledPortComplexSignal');
  cplx = 'real';
  if (cplxFlags == 1), cplx = 'complex'; end
  elems(elemsIdx).Complexity = cplx;

  fdFlags = get_param(blkH, 'CompiledPortFrameData');

  if fdFlags.Outport(1) == -2
    % This check is needed until geck 181781 is resolved
    framesOnPort = fdFlags.Outport(portIdx+2);
  else
    framesOnPort = fdFlags.Outport(portIdx);
  end

  if framesOnPort == 0
    elems(elemsIdx).SamplingMode = 'Sample based';
  else
    elems(elemsIdx).SamplingMode = 'Frame based';
  end

  ts = get_param(blkH, 'CompiledSampleTime');
  if (ts == [0 0])
    ts = 0;
  elseif (ts == [-1 -1])
    ts = -1;
  end
  elems(elemsIdx).SampleTime = ts;

%%%%%%%%%%%%%%%%%%%
% bus_types_are_equal
% Determine if two bus objects are defining the same structure
function areSame = bus_types_are_equal(bus1,bus2)

  areSame = true;

  numEl1 = length(bus1.Elements);
  numEl2 = length(bus2.Elements);

  if numEl1 ~= numEl2
    areSame =false;
  else
    for elIdx = 1:numEl1

      if ~strcmp(bus1.Elements(elIdx).DataType,bus2.Elements(elIdx).DataType)
        %check for bus type and recurse
        if ( (~isempty(strfind(bus1.Elements(elIdx).DataType,'bus')) ||...
              ~isempty(strfind(bus1.Elements(elIdx).DataType,'Bus')))...
          && ...
              (~isempty(strfind(bus2.Elements(elIdx).DataType,'bus')) || ...
               ~isempty(strfind(bus2.Elements(elIdx).DataType,'Bus'))))
          areSame = bus_types_are_equal(evalin('base',...
                                            bus1.Elements(elIdx).DataType),...
                                     evalin('base',...
                                            bus2.Elements(elIdx).DataType));
        else
          areSame =false;
        end
      elseif ~strcmp(bus1.Elements(elIdx).Complexity,...
                     bus2.Elements(elIdx).Complexity)
        areSame =false;
      elseif bus1.Elements(elIdx).Dimensions~=bus2.Elements(elIdx).Dimensions
        areSame =false;
      elseif ~strcmp(bus1.Elements(elIdx).SamplingMode,...
                     bus2.Elements(elIdx).SamplingMode)
        areSame =false;
      elseif bus1.Elements(elIdx).SampleTime~=bus2.Elements(elIdx).SampleTime
        areSame =false;

      end
    end
  end

  return


%%%%%%%%%%%%%%%%%%%%%%%%%%
% define_downstream_buses
% Define the bus objects for all bus creators down stream from the
% outport passed in
function  busCreatorObjects = define_downstream_buses(outportH,...
                                                    busCreatorObjects,...
                                                    topH,...
                                                    thisSystem)

  dstPorts = get_param(outportH,'TraceDestinationInputPorts');
  dstBlks  = get_param(dstPorts,'Parent');
  dstTypes = get_param(dstBlks,'BlockType');
  for dstIdx =1:length(dstTypes)
    if strcmp(dstTypes{dstIdx},'BusCreator')
      % Only define a bus if the block is in this system
      % if it is not in this system, then we do not yet know
      % if the bus creator should get the same bus object definition
      % as another bus creator
      if modelref_conversion_utilities('block_is_in_system',...
                                       dstBlks{dstIdx},...
                                       thisSystem)
        dstLineHs  = get_param(dstBlks{dstIdx},'LineHandles');
        dstPortH   = get_param(dstLineHs.Outport,'DstportHandle');
        % All the destinations will have the same bus definition so it does
        % not matter which one we use
        busInfo = get_param(dstPortH(1),'BusStruct');

        [busName,...
         busCreatorObjects] = find_bus_definition(busInfo,...
                                                  busCreatorObjects,...
                                                  topH);
      end
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handle_other_instance_buses
% For each other instance check that the bus object definition matched this one
function busCreatorObjects = handle_other_instance_buses(thisRefBlk,...
                                                    busInfo,...
                                                    inIdx,...
                                                    topModelH,...
                                                    busCreatorObjects)

  if ~isempty(thisRefBlk)
    otherInstances = find_system(topModelH,...
                                 'LookUnderMasks','all',...
                                 'FollowLinks','on',...
                                 'ReferenceBlock',thisRefBlk);

    for instIdx = 1:length(otherInstances)

      otherPorts = get_param(otherInstances(instIdx),'PortHandles');
      otherBusInfo = get_param(otherPorts.Inport(inIdx),'BusStruct');

      busCreatorObjects = check_this_bus_level(busInfo,...
                                               otherBusInfo,...
                                               busCreatorObjects);
    end
  end



%%%%%%%%%%%%%%%%%%%%%%
% check_this_bus_level
% Check that the two bus info's passed in give the same bus object definition
% If they do, then add all of the bus creators encountered to the
% busCreatorObjects with bus object names that are duplicated appropriately
function busCreatorObjects = check_this_bus_level(busInfo1,...
                                                  busInfo2,...
                                                  busCreatorObjects)


  for sigIdx = 1:length(busInfo1.signals)
    % If we have a nested bus deep dive (if we have a nested signal
    % with a mux, do not)
    if ~isempty(busInfo1.signals(sigIdx).signals) && ...
          ~strcmp(get_param(busInfo1.signals(sigIdx).src,'BlockType'),'Mux')
      busCreatorObjects = check_this_bus_level(busInfo1.signals(sigIdx),...
                                               busInfo2.signals(sigIdx),...
                                               busCreatorObjects);
    end
  end

  [busName1, busCreatorObjects] = generate_bus_object(busInfo1,...
                                                    busCreatorObjects);

  busName2 = generate_bus_object(busInfo2,...
                                 busCreatorObjects);
  areSame = bus_types_are_equal(evalin('base',busName1),...
                                evalin('base',busName2));

  if areSame
    busCreatorObjects = add_item_to_bus_list(busCreatorObjects,...
                                             busName1,...
                                             busInfo2.src);
  else
    error('ModelRefConv:Fatal',...
          'Different bus trees feeding two instances of same model');
  end



%%%%%%%%%%%%%%%%%%%%%%%%
% get_bus_name_from_list
% Given a block and the busCreatorObjects structure, pass back
% the name of the bus object associated with the bus creator if one
% has already been determined. Pass back empty otherwise
function busName = get_bus_name_from_list(busSrc,busCreatorObjects)

  busName = '';
  thisRefBlk = get_param(busSrc,'ReferenceBlock');
  % See if it is in the list (this will happen if the bus Creator
  % does not have a bus object specified on it, but we've already
  % encountered this bus Creator in our conversion process)
  if isempty(thisRefBlk)
    % Check for this block specifically
    thisFullName = getfullname(busSrc);
    for i=1:length(busCreatorObjects)
      if strcmp(busCreatorObjects{i}.BlockFullName,...
                thisFullName)
        busName = busCreatorObjects{i}.BusName;
        return
      end
    end
  else
    % Check for refblk
    % Note:the check that all instances are the same will have
    % happened when the first block's bus object was defined
    for i=1:length(busCreatorObjects)
      if strcmp(busCreatorObjects{i}.RefBlk,...
                thisRefBlk)
        busName = busCreatorObjects{i}.BusName;
        return
      end
    end
  end

%%%%%%%%%%%%%%%%%%%%%%
% add_item_to_bus_list
% add this bus object and source to the busCreatorObject list
function busCreatorObjects = add_item_to_bus_list(busCreatorObjects,...
                                                  busName,...
                                                  busSrc)
  % Add the busInfo2 src to the busCreatorObjects with busName1
  idx = length(busCreatorObjects) + 1;
  busCreatorObjects{idx}.BlockFullName = getfullname(busSrc);
  busCreatorObjects{idx}.BusName = busName;
  busCreatorObjects{idx}.SetOnBlk = false;
  busCreatorObjects{idx}.RefBlk = get_param(busSrc,'ReferenceBlock');

%%%%%%%%%%%%%%%%%%%%%
% Get the nonbus, non-builtin unique datatypes for the buses
%
function busDataTypes = get_nonbus_nonbuiltin_data_types(busCreatorObjects)
% GET_NONBUS_BUILTIN_DATA_TYPES is a utility function to return
% a list of Simulink.NumericType's that are not buses and that are 
% used in buses. Builtin datatypes are not of Simulink.NumericType  
% class and they are not buses. Datatypes are filtered using 
% the isa command
    
  busDataTypes  ={};

  for idx = 1:length(busCreatorObjects);
    busCreatorObject = evalin('base',busCreatorObjects{idx}.BusName);
    for yidx = 1:length( busCreatorObject.Elements)
      elem = busCreatorObject.Elements(yidx);
      if(is_datatype_builtin(elem.DataType)), continue; end
      
      evalStringA =  ['isa(',elem.DataType,',''Simulink.NumericType'')'];
      evalStringB =  ['isa(',elem.DataType,',''Simulink.Bus'')'];
      try
        isNumericType = evalin('base',evalStringA);
        isBusType     = evalin('base',evalStringB);
      catch
        error(['ModelRefConv:Fatal',...
               'Error evaluating expression: ',evalStringA,'or ',evalStringB]);
      end  
      if(isNumericType && ~isBusType)
        if any(strcmp(busDataTypes,elem.DataType))
          busDataTypes{end + 1} = elem.DataType;
        end
      end
    end
  end

%%%%%%%%%%%%%%%%%
%Save the bus structure in m
%
function save_bus_in_m(fid,busCreatorObject)

  fprintf(fid,'%%\n');
  fprintf(fid,'%% Original Block Used For Definition:\n');

  tmpStr = ['%% ',strrep(busCreatorObject.BlockFullName,sprintf('\n'),' ')];
  fprintf(fid,'%s\n',tmpStr);

  if ~isempty(busCreatorObject.RefBlk)
    tmpStr = ['% Library Block: ',strrep(busCreatorObject.RefBlk,...
                                         sprintf('\n'),' ')];
    fprintf(fid,'%s\n',tmpStr);
  end

  theElems = evalin('base',[busCreatorObject.BusName,'.Elements']);
  for elemIdx = 1:length(theElems)
    fprintf(fid,'elems(%d) = Simulink.BusElement;\n',elemIdx);

    tmpStr = ['''',theElems(elemIdx).Name,''''];
    fprintf(fid,'elems(%d).Name = %s;\n',elemIdx,tmpStr);
    tmpStr = ['''',theElems(elemIdx).DataType,''''];
    fprintf(fid,'elems(%d).DataType = %s;\n',elemIdx,tmpStr);
    tmpStr = ['''',theElems(elemIdx).Complexity,''''];
    fprintf(fid,'elems(%d).Complexity = %s;\n',elemIdx,tmpStr);

    dims = theElems(elemIdx).Dimensions;
    if length(dims) > 1
      fprintf(fid,'elems(%d).Dimensions = [%d',elemIdx,dims(1));
      for dimsIdx = 2: length(dims)
        fprintf(fid,', %d',dims(dimsIdx));
      end
      fprintf(fid,'];\n');
    else
      fprintf(fid,'elems(%d).Dimensions = %d;\n',elemIdx,dims);
    end

    tmpStr = ['''',theElems(elemIdx).SamplingMode,''''];
    fprintf(fid,'elems(%d).SamplingMode = %s;\n',elemIdx,tmpStr);

    ts = theElems(elemIdx).SampleTime;
    switch(length(ts))
     case 1
      fprintf(fid,'elems(%d).SampleTime = %g;\n',elemIdx,ts);
     case 2
      fprintf(fid,'elems(%d).SampleTime = [%g,%g];\n',elemIdx,ts(1),ts(2));
     otherwise
      error('invalid length of sample time');
    end

  end

  fprintf(fid,'%s = Simulink.Bus;\n',busCreatorObject.BusName);
  fprintf(fid,'%s.Elements = elems;\n',busCreatorObject.BusName);


%%%%%%%%%%%%%%%%%
%Save the user defined data structures to the m-file
%
function  save_nonbus_data_types_in_m(fid,busCreatorObjects)

  nonBusDataTypeNames =  get_nonbus_nonbuiltin_data_types(busCreatorObjects);
  
  for idx=1:length(nonBusDataTypeNames)
    nonBusDataTypeName = nonBusDataTypeNames{idx};
    try 
      nonBusDataType     = evalin('base',nonBusDataTypeName);
    catch
      error(['ModelRefConv:Fatal',...
            'Cannot evaluate datatype:',nonBusDataTypeName]);
    end  
    
    tmpStr = ['% Defining data type: ',nonBusDataTypeName];
    fprintf(fid,'\n%%\n%s\n',tmpStr);
    
    tmpStr = [nonBusDataTypeName,'=Simulink.NumericType;'];
    fprintf(fid,'%s\n',tmpStr);


    nonBusDataTypeFieldNames = fieldnames(nonBusDataType );
    for yidx = 1:length( nonBusDataTypeFieldNames )
      
      fname  =  nonBusDataTypeFieldNames{yidx};
      val    =  getfield(nonBusDataType,fname);
      fmtStr =  [];
      
      switch( fname )

       case {'Description','HeaderFile','Category'},
        fmtStr = '''%s''';

       case {'Signed','TotalBits','WordLength','IsAlias'},
        fmtStr = '%d';

       case {'FixedExponent','FractionLength','Slope',...
             'SlopeAdjustmentFactor','Bias'},
        fmtStr = '%g';

       otherwise,
        error('ModelRefConv:Fatal',...
              'fatal error: Invalid Simulink.NumericType field');

      end
      tmpStr = [nonBusDataTypeName,'.',fname,'=', fmtStr,';\n'];
      fprintf(fid,tmpStr,val);

    end
  end


function print_bus_m_header(fid,topMdlName,newTopMdlName,busMFileName)

   fprintf(fid,['%% This file is automatically generated during conversion ',...
                'to model reference\n']);
   fprintf(fid,'%% Original model name: %s\n',topMdlName);
   fprintf(fid,'%% Converted top model name: %s\n',newTopMdlName);
   fprintf(fid,'%% File Name: %s\n',busMFileName);
   fprintf(fid,'%% Date: %s\n',date);
   fprintf(fid,'%% \n');

%%%%%%%%%%%%%%%%%
%Save the bus structures to a mat file
%
function save_bus_in_mat(busFileName,busCreatorObjects)

  busSaveCommand = ['save ',busFileName];
  for i=1:length(busCreatorObjects)
    busSaveCommand = [busSaveCommand,' ',busCreatorObjects{i}.BusName];
  end

  %Save the datatypes of the busCreatorObjects if they are not
  %built-in MATLAB datatypes.See geck 213743
  nonBusDataTypes =  get_nonbus_nonbuiltin_data_types(busCreatorObjects);

  for i=1:length(nonBusDataTypes)
    busSaveCommand = [busSaveCommand,' ',nonBusDataTypes{i}];
  end

  try
    busSaveCommand = [busSaveCommand,';'];
    evalin('base',busSaveCommand);
  catch
    error(['ModelRefConv:Fatal',...
           'fatal error: ', lasterr]);
  end  
    
  
%%%%%%%%%%%%%%%% 
%Determine if a datatype is builtin    
%
function isBuiltin =  is_datatype_builtin(datatype)
  isBuiltin = false;
  if (strcmp(datatype,'double') || ...
      strcmp(datatype,'single') || ...
      strcmp(datatype,'int8')   || ...
      strcmp(datatype,'uint8')  || ...
      strcmp(datatype,'int16')  || ...
      strcmp(datatype,'uint16') || ...
      strcmp(datatype,'int32')  || ...
      strcmp(datatype,'uint32') || ...
      strcmp(datatype,'boolean'))
    isBuiltin =true;
  end
