function [conversionStatus,...
          newModel,...
          busCreatorObjectsOut,...
          createdModelsOut] = subsystem_to_model_reference(systemToConvert,...
                                                  topModel,...
                                                  saveLocation,...
                                                  createdModels,...
                                                  busCreatorObjects,...
                                                  useLibNameForModelName,...
                                                  maxModelNameLength,...
                                                  mdlNameKeepEndWhenTooLong)
% subsystem_to_model_reference: Converts a subsystem to a model for referencing
%
% Input arguments:
%   systemToConvert:
%      the subsystem to convert. This structure contains
%      five elements: Handle, Name, FullName, RefBlock, and Checksum
%   topModel:
%      the top model that contains the subsystem being converted
%      to a model (This is a structure containing Name and Handle)
%   saveLocation:
%      a string for the location to save the new model
%   createdModels:
%      a structure array containing the book keeping info for the whole
%      conversion process. It tracks what models have been created and
%      what subsystem blocks in the model will become model blocks
%      referencing those models. It tracks where all of those subsystems
%      live before and after conversion (both in models and libraries)
%   busCreatorObjects: 
%      a cell array of bus creator objects created during the 
%      conversion process. Each element is a structure with four fields:
%      BlockFullName, BusName, SetOnBlk, and RefBlk
%  useLibNameForModelName:
%      a flag for an input to the conversion process. If it is true then
%      subsystems that meet certain requirements will use the name of the
%      library that defines them for the name of the model created from them
%  maxModelNameLength:
%      The maximum length allowed for a created model name
%  mdlNameKeepEndWhenTooLong: 
%      If the model name will be too long this flag indicates whether the
%      extra characters should be removed form the beginning or the end
%
% Output Arguments:
%   conversionStatus: A string summarizing the status of the conversion.
%      It has 4 possible values:
%         'success' - The model was successfully created
%         'failedDueToLimitation' - Converting this system hit some known
%             limitation of this tool. The system will not have a model
%             created for it
%         'failedDueToError' - An error was encountered while converting
%             this system. The system will not have a model created for it
%         'unknown' - This is the initial value for the flag. If this is
%             passed back to the caller something has gone wrong
%   newModel:
%      A structure for the newly created model whose
%      elements are Handle, Name, BusOuts and LabelsOut
%   busCreatorObjectsOut:
%      The modified list of bus creator objects that was passed in.
%      Any new bus objects that were created have been added to the list
%   createdModelsOut:
%      The modified version of createdModels passed in. The additional
%      information will consist of the post conversion location of some
%      of the subsystems being tracked
% 
% This function performs the following steps:
%
% (1) Generate a name for the new model based on the name of the subsystem
%     block
% (2) Use new_system to create a new model containing all of the blocks
%     and lines from the subsystem
% (3) Copy the configuration set from the top model into the new model
% (4) Massage the configuration set as needed
% (5) Set information (data type, dimensions, signal complexity, sampling 
%     mode, and sample time) on the root input ports of the new model.
%     If the input port has a bus passing through it, make sure there is
%     a bus object defined and set that on the input port instead of setting
%     the properties individually.
% (6) Set information (data type, dimensions, signal complexity, sampling 
%     mode, and sample time) on the root output ports of the new model.
%     If the output port has a bus passing through it, make sure there is 
%     a bus object defined and set that on the output port instead of setting
%     the properties individually.
% (7) Label the signals driving the root level output ports if needed 
% (8) Find any subsystems in the new model that correspond to subsystems
%     in the original model that have already been converted to models for
%     referencing. Change each of these subsystems to a Model block
%     referencing the appropriate model.
% (9) Find any bus creators in the new model that have had a bus object
%     defined for them and set the bus object type name in the block parameter.
%     Also set the "output as structure" parameter to true.
% (10) Save the new model in the specified directory
% 
%   $Revision: 1.1.6.9 $

  % Initialize the outputs
  conversionStatus = 'unknown';
  busCreatorObjectsOut = busCreatorObjects;
  newModel.Name = '';
  newModel.Handle = [];
  newModel.BusOuts =[];
  newModel.LabelOuts =[];
  newModel.ModifyLib = ~isempty(systemToConvert.RefBlock);
  newModel.FinalName = '';
  createdModelsOut = createdModels;
  
  try
    
    if (useLibNameForModelName && ...
        can_use_lib_name_for_model_name(systemToConvert.RefBlock))
      
      theLib = bdroot(systemToConvert.RefBlock);
      newModel.Name = [get_param(theLib,'Name'),'_temp'];
      newModel.FinalName = get_param(theLib,'Name');
      newModel.ModifyLib = false;      
      disp(['Current new model name is ',newModel.Name]);
      disp(['Eventual model name is ',newModel.FinalName]);
    
    else
      % Create a name for the new model based on the block name
      newModel.Name = modelref_conversion_utilities('string_to_variable_name',...
                                                    systemToConvert.Name,...
                                                    maxModelNameLength,...
                                                    mdlNameKeepEndWhenTooLong);
      newModel.FinalName = newModel.Name;
      newModel.ModifyLib = ~isempty(systemToConvert.RefBlock);
      disp(['New model name is ',newModel.Name]);
    end

    
    % This creates a new model and populates it with the blocks and lines of 
    % the original subsystem
    % Note the new model will have the default parameters at this point

    % Copy systemToConvert as a whole (i.e. not its contents) to a temp
    % model, then break the link, then use that system for the
    % new_system command. If we do not do this we will end up with links to
    % blocks that no longer exist in the library after the entire conversion
    % is complete
    if ~isempty(systemToConvert.RefBlock)
      tempModelName = modelref_conversion_utilities(...
          'string_to_variable_name',...
          'tmpMdl',maxModelNameLength,mdlNameKeepEndWhenTooLong);
      tempBlockName = [tempModelName,'/blah'];
      new_system(tempModelName,'model');
      add_block(systemToConvert.RefBlock,tempBlockName);
      set_param(tempBlockName,'LinkStatus','none');

      newModel.Handle = new_system(newModel.Name,'Model',tempBlockName);

      % Now get rid of the temporary model without a trace
      close_system(tempModelName,0);
    else
      newModel.Handle = new_system(newModel.Name,...
                                   'Model',...
                                   systemToConvert.Handle);

    end

    % Force the finding of all blocks so that we won't get invalid
    % simulink object errors later when referring to blocks by their
    % full path name instead of doing a find_system for them
    find_system(newModel.Handle,...
                'FollowLinks','on',...
                'LookUnderMasks','all');

    % Copy the configuration set of the original into the new model
    origConfigSet = getActiveConfigSet(topModel.Handle);
    newConfigSet = origConfigSet.copy;

    if strcmp(newConfigSet.getProp('SolverMode'),'MultiTasking')
      newConfigSet.setProp('SolverMode','Auto');
    end

    newConfigSet.Name = 'ModelReferencing';
    ConfigSetToRemove = getActiveConfigSet(newModel.Handle);
    attachConfigSet(newModel.Handle,newConfigSet);
    setActiveConfigSet(newModel.Handle,newConfigSet.Name);
    detachConfigSet(newModel.Handle,ConfigSetToRemove.Name);


    % Set the fundamental sample time of sub model to match the top model
    % We need to do this if the model has continuous states
    %fundStepSize = get_param(topModel.Handle,'FundamentalStepSize');
    %newConfigSet.setProp('FixedStep', num2str(fundStepSize));

    % Make required modifications to the configuration set
    modelref_conversion_utilities('config_set_checks',newModel.Handle,true);

    % Use the DatTypeOverride_Compiled setting of the original subsystem
    % to set the DataTypeOverride setting in the new model (see geck 193771)
    set_param(newModel.Handle,...
              'DataTypeOverride',...
              get_param(systemToConvert.Handle,'DataTypeOverride_Compiled'));

    % Here we make changes to the config set that we'll only make to models
    % that aren't the original one
    configSet = getActiveConfigSet(newModel.Handle);

    % Turn off logging of outputs because if it is on it's probably set up
    % with the wrong number of variables
    % Leave state logging as it was because it needs to match the parent
    dataComponent = configSet.getComponent('Data Import/Export');
    dataComponent.SaveOutput = 'off';
    dataComponent.SaveTime   = 'off';

    % Do this after the checks so that we know it's already been set
    % to fixed step solver
    %
    % Determine if the original subsystem is inside a triggered subsystem
    % (ideally include for/while)
    % If so, make sure this new model will be inheriting a sample time
    % This requires:
    % 1) fixed step size of auto
    % 2) set the solver constraint to "ensure sample time independent
    % 3) do not set the sample time on the root inports
    % 4) do we need to do anything about any bus objects?
    % 5) does not contain certain blocks (should eliminate
    %    the cand if it does)
    isInTriggered = is_in_triggered_subsystem(systemToConvert,topModel);
    slvrComponent = configSet.getComponent('Solver');
    if isInTriggered
      hasDintBlks = ~isempty(find_system(systemToConvert.Handle,...
                                         'FollowLinks','on',...
                                         'LookUnderMasks','all',...
                                         'BlockType','DiscreteIntegrator'));
      hasPulseBlks = ~isempty(find_system(systemToConvert.Handle,...
                                         'FollowLinks','on',...
                                         'LookUnderMasks','all',...
                                         'BlockType','DiscretePulseGenerator'));

      hasFromWksBlks = ~isempty(find_system(systemToConvert.Handle,...
                                          'FollowLinks','on',...
                                          'LookUnderMasks','all',...
                                          'BlockType','FromWorkspace'));

      if(hasDintBlks || hasPulseBlks || hasFromWksBlks)
        % This can actually be relaxed a bit - if the blocks are inside
        % another triggered subsystem then we do not need to eliminate this
        % system from being converted
        error('ModelRefConv:UnacceptableBlksInTriggered',...
              ['System is being triggered and contains a block which ',...
               'will not allow the model to inherit a sample time']);
      end

      slvrComponent.SolverType = 'Fixed-Step';
      slvrComponent.FixedStep = 'auto';
      slvrComponent.SampleTimeConstraint='STIndependent';
    end

    % Set info on the input ports
    subsysPortH = get_param(systemToConvert.Handle, 'PortHandles');
    for inIdx = 1:length(subsysPortH.Inport)

      ssInPortH = subsysPortH.Inport(inIdx);

      % The BusStruct get_param (which is only valid for input ports of blocks)
      % returns empty if the signal feeding the input port in question is not
      % a bus. If there is already a bus object defined for the bus signal,
      % then the name of that object is in the busObjectName of the
      % structure returned by the get_param
      busInfo = get_param(ssInPortH,'BusStruct');
      busName = '';
      % If we have  a bus coming into the subsystem we need to define a 
      % bus object for the model. This code below defines bus objects for 
      % all of the bus creators driving input port
      %
      %  +---------------------------------------------+
      %  |                             Start at the    |
      %  |         +---+               system input    |
      %  |      ---| B |   +---+       and work back   |
      %  |      ---| C |---| B |      +-------------+  |
      %  |         +---+   | C |      |System being |  |
      %  |                 | 2 |------|turned into  |  |
      %  |              ---|   |      |a model      |  |
      %  |                 +---+      +-------------+  |
      %  |                                             |
      %  +---------------------------------------------+
      %
      %
      if ~isempty(busInfo)
        if isempty(busInfo.busObjectName)
          % There is a bus signal, but it does not yet have an object
          % associated with it. Use the data in the busInfo structure to
          % define a bus object
          [busName,...
           busCreatorObjects] = modelref_conversion_bus_utils(...
               'find_bus_definition',...
               busInfo,...
               busCreatorObjects,...
               topModel.Handle);
        else
          % We already have a bus object just use it
          busName = busInfo.busObjectName;
        end
      end

      newInBlkH = find_system(newModel.Handle,...
                              'SearchDepth',1,...
                              'BlockType','Inport',...
                              'Port',sprintf('%d',inIdx));

      origInBlkH = find_system(systemToConvert.Handle,...
                               'FollowLinks','on',...
                               'LookUnderMasks','all',...
                               'SearchDepth',1,...
                               'BlockType','Inport',...
                               'Port',sprintf('%d',inIdx));

      if ~isempty(busName)
        % This input port has a bus coming into it

        set_param(newInBlkH,'UseBusObject','on');
        set_param(newInBlkH,'BusObject',busName);

        % Handle the other instances - This sets
        % up the same busObject names for the bus creators
        % feeding the other instances. Note the same bus object names
        % will be used, but this function checks that the definitions are
        % the same and adds the other instance bus creators to the list
        busCreatorObjects = modelref_conversion_bus_utils(...
            'handle_other_instance_buses',...
            systemToConvert.RefBlock,...
            busInfo,...
            inIdx,...
            topModel.Handle,...
            busCreatorObjects);

      else
        % This input port does not have a bus
        set_info_on_port(ssInPortH,origInBlkH,newInBlkH,inIdx,'Input',...
                                   isInTriggered);

        % Set the signal name
        origInBlkPorts = get_param(origInBlkH,'PortHandles');
        signalName = get_param(origInBlkPorts.Outport,'PropagatedSignals');
        if ~isempty(signalName)
          newPorts = get_param(newInBlkH,'PortHandles');
          set_param(newPorts.Outport,'Name',signalName);
        end
      end
    end

    % If we're passing a bus out of the subsystem we need to define a
    % bus object for the model. This code below defines bus objects for
    % all of the bus creators feeding the output port
    %
    % System being turned into a model:
    %  +---------------------------------------+
    %  |                                       |
    %  |         +---+                         |
    %  |      ---| B |   +---+                 |
    %  |      ---| C |---| B |                 |
    %  |         +---+   | C |      +---+      |
    %  |                 | 2 |------|Out|      |
    %  |              ---|   |      +---+      |
    %  |                 +---+   start at Out  |
    %  |                         and work back |
    %  +---------------------------------------+
    %
    %
    for outIdx=1:length(subsysPortH.Outport)
      ssOutPortH = subsysPortH.Outport(outIdx);
      origOutBlkH = find_system(systemToConvert.Handle,...
                                'FollowLinks','on',...
                                'LookUnderMasks','all',...
                                'SearchDepth',1,...
                                'BlockType','Outport',...
                                'Port',sprintf('%d',outIdx));
      ports = get_param(origOutBlkH,'PortHandles');
      outBlkInPortH = ports.Inport(1);
      busInfo = get_param(outBlkInPortH,'BusStruct');
      busName = '';

      if ~isempty(busInfo)
        if isempty(busInfo.busObjectName)
          [busName,...
           busCreatorObjects] = modelref_conversion_bus_utils(...
               'find_bus_definition',...
               busInfo,...
               busCreatorObjects,...
               topModel.Handle);
        else
          busName = busInfo.busObjectName;
        end
      end

      newOutBlkH = find_system(newModel.Handle,...
                               'SearchDepth',1,...
                               'BlockType','Outport',...
                               'Port',sprintf('%d',outIdx));

      if ~isempty(busName)
        set_param(newOutBlkH,'BusObject',busName);
        set_param(newOutBlkH,'UseBusObject','on');
        newModel.BusOuts = [newModel.BusOuts,outIdx];
      else
        % This output port does not have a bus, set properties
        set_info_on_port(ssOutPortH,origOutBlkH,newOutBlkH,...
                                    outIdx,'Output',...
                                    isInTriggered);
      end

      newOutBlkH = find_system(newModel.Handle,...
                               'SearchDepth',1,...
                               'BlockType','Outport',...
                               'Port',sprintf('%d',outIdx));

      % Check to see if we have a signal label coming into this outport
      % If we do, set the signal name on the signal inside the model (so
      % that it will be visible outside the model).
      % Also, we track that information so that we can set it
      % on the model block when we replace the subsystem so that it will
      % be visible to the downstream bus creators. This later part is
      % a workaround for geck 203295 (R14FCS branch).
      origOutportLine = get_param(outBlkInPortH,'Line');
      origSrcPort = get_param(origOutportLine,'SrcPortHandle');

      newModel.LabelOuts = modelref_conversion_utilities(...
          'find_signal_label',...
          origSrcPort,...
          busInfo,...
          outIdx,...
          newModel.LabelOuts);

    end

    % Convert systems to model blocks where appropriate
    % we also figure out which systems will be in this one
    % The latter is needed for bus handling immediately below
    createdModels = modelref_conversion_utilities(...
        'replace_subsystems_with_model_blks',...
        systemToConvert.FullName,...
        newModel.Name,...
        createdModels,...
        newModel.FinalName);
    
    % Set the bus object on the bus creators that are in this system    
    busCreatorObjects = modelref_conversion_utilities(...
        'add_bus_objects_to_creators',...
        systemToConvert,...
        newModel,...
        busCreatorObjects);

    % Set the signal label on the signal driving the outports, if needed
    %
    %   Model currently being created
    % +-------------------------------+
    % |                               |
    % |              Set              |
    % |    +-------+ Signal           |
    % |    | Some  | Name    +-----+  |
    % |    | Block |---------| Out |  |
    % |    +-------+         +-----+  |
    % |                               |
    % +-------------------------------+
    %
    for labelIdx=1:length(newModel.LabelOuts)
      outBlkIdx = newModel.LabelOuts(labelIdx).outIdx;
      labelString = newModel.LabelOuts(labelIdx).label;
      
      newOutBlkH = find_system(newModel.Handle,...
                               'SearchDepth',1,...
                               'BlockType','Outport',...
                               'Port',...
                               sprintf('%d',outBlkIdx));
      ports = get_param(newOutBlkH,'PortHandles');
      newOutBlkInPortH = ports.Inport(1);
      newOutportLine = get_param(newOutBlkInPortH,'Line');
      srcPortToSet = get_param(newOutportLine,'SrcPortHandle');

      % Set the name in the signal driving the outport block
      set_param(srcPortToSet,'Name',labelString);
    end

    % Save new model to disk
    if ~isempty(saveLocation)
      disp(['Saving ''',newModel.Name,''' in ''',saveLocation,'''']);
      save_system(newModel.Handle,[saveLocation,filesep,newModel.Name]);
    end

    % We will successfully return so send back the busCreatorObjects
    % as modified as well as the createdModels
    busCreatorObjectsOut = busCreatorObjects;
    createdModelsOut = createdModels;

    conversionStatus = 'success';

    return

  catch
    err = lasterror;
    if ( strcmp(err.identifier ,'ModelRefConv:linkBusError') || ...
         strcmp(err.identifier ,'ModelRefConv:UnsupportedDataType') || ...
         strcmp(err.identifier ,'ModelRefConv:UnacceptableBlksInTriggered') || ...
         strcmp(err.identifier ,'ModelRefConv:UnsupportedBusDataType'))
      conversionStatus='failedDueToLimitation';
      limitOrError = 'a known limitation';
    else
      conversionStatus='failedDueToError';
      limitOrError = 'an unexpected error';
    end
    disp([sprintf('\n'),...
          'The conversion of this system failed due to ',...
          limitOrError,'. Reason (i.e. last error): ',...
          sprintf('\n'),...
         err.message,...
          sprintf('\n'),...
         ' This system will not be converted. ',...
         'The model created will be closed without saving.',...
          sprintf('\n')]);
    newModel.Name = '';
    if ~isempty(newModel.Handle)
      close_system(newModel.Handle,0);
      newModel.Handle ='';
    end
    return
  end


function isInTriggered = is_in_triggered_subsystem(systemToConvert,topModel)

  isInTriggered = false;
  sysH = systemToConvert.Handle;

  while(sysH ~= topModel.Handle)
    ports = get_param(sysH,'PortHandles');
    if ~isempty(ports.Trigger)
      isInTriggered = true;
      return
    end
    if (~isempty(find_system(sysH,'SearchDepth',1,...
                             'FollowLinks','on',...
                             'BlockType','WhileIterator')) || ...
        ~isempty(find_system(sysH,'SearchDepth',1,...
                             'FollowLinks','on',...
                             'BlockType','ForIterator')))
      isInTriggered = true;
      return
    end
    par = get_param(sysH,'Parent');
    sysH = get_param(par,'Handle');
  end

function set_info_on_port(ssPortH,origBlkH,newBlkH,portNum,portType,isInTriggered)

% Get all the compiled info

  compDataType.Str = get_param(ssPortH,'CompiledPortDataType');

  if (modelref_conversion_bus_utils('is_datatype_builtin',compDataType.Str))
    compDataType.isFixPt = false;
  elseif((strncmp(compDataType.Str, 'sfix', 4) ||...
          strncmp(compDataType.Str, 'ufix', 4) ||...
          strncmp(compDataType.Str, 'flt', 3)))
    compDataType.isFixPt        = true;
    compDataType.isScaledDouble = false;
    [dInfo, scaledDouble]=fixdt(compDataType.Str);
    if(scaledDouble),compDataType.isScaledDouble  = true; end
  else
    error('ModelRefConv:UnsupportedDataType',...
          [portType,' port ',num2str(portNum),' has a data type of',...
           compDataType.Str,' which is not supported for automatic ',...
           'conversion.']);
  end

  compWidths = get_param(ssPortH,'CompiledPortWidth');
  compPortDims = get_param(ssPortH,'CompiledPortDimensions');
  compComplex = get_param(ssPortH,'CompiledPortComplexSignal');
  tmpCompFrame = get_param(origBlkH,'CompiledPortFrameData');

  % The compiled port frame data is not consistent with the other
  % get_params as to whether it reports a bus. See geck 181781
  if strcmp(portType,'Input')
    if tmpCompFrame.Outport(1) == -2
      compFrame = tmpCompFrame.Outport(3);
      for idx = 4:length(tmpCompFrame.Outport)
        if tmpCompFrame.Outport(idx)~=compFrame
          error('ModelRefConv:Fatal',...
                ['Fatal Error: compiled port frame data is not ',...
                 'self-consistent']);
        end
      end
    else
      compFrame = tmpCompFrame.Outport;
      if length(compFrame) ~= 1
        error('ModelRefConv:Fatal',...
              'Fatal Error: frame data too long');
      end
    end
  else
    if tmpCompFrame.Inport(1) == -2
      compFrame = tmpCompFrame.Inport(3);
      for idx = 4:length(tmpCompFrame.Inport)
        if tmpCompFrame.Inport(idx)~=compFrame
          error('ModelRefConv:Fatal',...
                ['Fatal Error: compiled port frame data is not ',...
                 'self-consistent']);
        end
      end
    else
      compFrame = tmpCompFrame.Inport;
      if length(compFrame) ~= 1
        error('ModelRefConv:Fatal',...
              'Fatal Error: frame data too long');
      end
    end
  end

  compTs = get_param(origBlkH,'CompiledSampleTime');

  % Set all the info

  if (compDataType.isFixPt)
    if(compDataType.isScaledDouble)
      newBlkH = insert_fixpt_spec_subsys(newBlkH,portNum,portType);
    end
    set_param(newBlkH, 'DataType',    'Specify via dialog');
    set_param(newBlkH, 'OutDataType',['fixdt(''',compDataType.Str,''')']);
  else
    set_param(newBlkH,'DataType',compDataType.Str);
  end

  if (compPortDims(1) == 2)
    portDimsStr = ['[',sprintf('%d',compPortDims(2)),' ',...
                   sprintf('%d',compPortDims(3)),']'];
  else
    portDimsStr = sprintf('%d',compPortDims(2));
  end
  set_param(newBlkH,'PortDimensions',portDimsStr);

  % Input ports with constant cause elimination of system in
  % find_model_reference_candidates. For an outport that is constant,
  % it would be nice to set it, but we can't so let it be inherited for now
  % When geck 210005 is fixed we can change this behavior
  if ~isInTriggered && ~isinf(compTs(1))
    if length(compTs >1)
      tsToSet = ['[',sprintf('%d',compTs(1)),',',sprintf('%d',compTs(2)),']'];
    else
      tsToSet = sprintf('%d',compTs(1));
    end
    set_param(newBlkH,'SampleTime',tsToSet);
  end
  
  if compComplex == 0
    set_param(newBlkH,'SignalType','real');
  else
    set_param(newBlkH,'SignalType','complex');
  end
  if compFrame == 0
    set_param(newBlkH,'SamplingMode','Sample based');
  else
    set_param(newBlkH,'SamplingMode','Frame based');
  end

% end function

function  newPortBlk = insert_fixpt_spec_subsys(portBlk,portNum,portType)
% This function will insert a subsystem with ScaledDouble
% between the portBlk block and its source or its
% destinations to accomplish a certain datatype conversion
% for fixpoint.
% Data type is scaled double. We need to insert a
% Signal Specification Block(Subsystem) and do
% set_param(blk,'DataTypeOverride','ScaledDoubles');
% on that subsystem

  pos =  get_param(portBlk, 'Position');
  outPortPos = [pos(1)+100, pos(2)-5, pos(1)+140, pos(2)+5];

  modelName = get_param(portBlk,'Parent');

  scaledDoubleSigSpecBlkName = [modelName,'/LockDownSignalSpec_',...
                      portType,'_',sprintf('%d', portNum)];

  scaleDblH = add_block('built-in/SubSystem', ...
                        scaledDoubleSigSpecBlkName, ...
                        'ShowName', 'on', ...
                        'FontSize', 10, ...
                        'Position', outPortPos);

   set_param(scaleDblH,'DataTypeOverride','ScaledDoubles');

   inH = add_block('built-in/Inport', ...
                  [scaledDoubleSigSpecBlkName,'/In1'], ...
                  'Position',[15    15    35    35]);

   outH = add_block('built-in/Outport', ...
                    [scaledDoubleSigSpecBlkName,'/Out1'], ...
                    'Position',[115    15    135    35]);

  in_PortH  = get_param(inH,  'PortHandles');
  out_PortH = get_param(outH, 'PortHandles');
  add_line(scaleDblH, in_PortH.Outport, out_PortH.Inport,...
           'autorouting','on');
  scaledPortHs   = get_param(scaleDblH,'PortHandles');
  portHs         = get_param(portBlk,'Porthandles');



  %If the port is in an inport to the system
  if(isempty(portHs.Inport))
    lineH = get_param(portHs.Outport,'Line');
    dstHs = get_param(lineH,'DstPorthandle');

    %First delete what is between the port and
    %the destinations. Then rewire to Signal Specification
    %Block

    for idx = 1:length(dstHs)
      delete_line(modelName,portHs.Outport,dstHs(idx));
      add_line(modelName,scaledPortHs.Outport,dstHs(idx),...
               'autorouting','off');
    end
    add_line(modelName,portHs.Outport,scaledPortHs.Inport);
  end

  %If the port is in an outport to the system
  if(isempty(portHs.Outport))
    lineH = get_param(portHs.Inport,'Line');
    src   = get_param(lineH,'SrcPorthandle');
    delete_line(modelName,src,portHs.Inport);
    add_line(modelName,src,scaledPortHs.Inport);

    %For cosmetic reasons, switch the position of the
    %signal specification block and the port

    oldPortPos = get_param(portBlk,'Position');
    set_param(portBlk, 'Position',outPortPos);
    set_param(scaleDblH,'Position',oldPortPos);

    add_line(modelName,scaledPortHs.Outport,portHs.Inport,...
             'autorouting','off')
  end

  %Return the Inport of the Signal Specification Block to
  %be further processed.
  newPortBlk = inH;

function canUseLibNameForMdlName = can_use_lib_name_for_model_name(refBlk)
  
  if isempty(refBlk) 
    canUseLibNameForMdlName = false;
  else
    parentRefBlk = get_param(refBlk,'Parent');
    isAtRootOfLib = strcmp(get_param(parentRefBlk,'type'),'block_diagram');
    
    theLib = bdroot(refBlk);
    theBlks = get_param(theLib,'blocks');
    isOnlyBlkInLib = (length(theBlks) == 1);
    
    canUseLibNameForMdlName = isAtRootOfLib && isOnlyBlkInLib;
  end
