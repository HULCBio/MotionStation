function ret = modelref_conversion_utilities(fcnName,arg2,arg3,arg4,arg5) 
%  $Revision: 1.1.6.9 $

  
  switch(fcnName)
   case 'replace_subsystems_with_model_blks'
    ret = replace_subsystems_with_model_blks(arg2,arg3,arg4,arg5);

   case 'replace_block_with_model_block'
    ret = [];
    replace_block_with_model_block(arg2,arg3,arg4);
    
   case  'add_bus_objects_to_creators'
    ret = add_bus_objects_to_creators(arg2,arg3,arg4);
    
   case 'string_to_variable_name'
    ret = string_to_variable_name(arg2,arg3,arg4);
    
   case 'config_set_checks'
    ret=[];
    config_set_checks(arg2,arg3);
    
    case 'block_is_in_system'
     ret = block_is_in_system(arg2,arg3);
     
   case 'find_signal_label'
     ret = find_signal_label(arg2,arg3,arg4,arg5);
    
   otherwise
    error('ModelRefConv:Fatal',...
          'fatal error: invalid function name');
  end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% replace_subsystems_with_model_blks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If a previously converted system is contained in the system
% we are currently converting we need to replace a subsystem with
% a model block in the newly created model
%
% We have two cases here:
% 
% CASE 1:                                CASE 2:
% +--------------------------+           +-----------------------------+
% |  Original Model          |           |  Original Model             |
% |                          |           |                             |
% |   +--------------------+ |           |   +-----------------------+ |
% |   | origSysName        | |           |   | origSysName           | |
% |   |                    | |           |   |                       | |
% |   |   +-------------+  | |           |   |   +-----------------+ | |
% |   |   | subToMdlRef |  | |           |   |   | subsysLink      | | |
% |   |   +-------------+  | |           |   |   |                 | | |
% |   |                    | |           |   |   |  +------------+ | | |
% |   +--------------------+ |           |   |   |  |subToMdlRef | | | |
% +--------------------------+           |   |   |  +------------+ | | |
%                                        |   |   +-----------------+ | |
%                                        |   +-----------------------+ |
%                                        +-----------------------------+
%
% subToMdlRef is a subsystem which is becoming a model (on the createdModels
%             list)
%
% origSysName is a subsystem that is also becoming a model block (the one
%             that is currently being processed)
%
% subssysLink is a subsystem that is NOT becoming a model but it IS
%             a library link block 
%
% For CASE 1 we will replace the subsystem subToMdlRef with a model block
% here, while we are creating origSysName's model.
%
% For CASE 2 we need to wait until the library modification stage to replace
% the subsystem with a model block. For now we will just cache away the
% name of the library that needs to be modified 
%
function createdModels = replace_subsystems_with_model_blks(origSysName,...
                                                    newModelName,...
                                                    createdModels,...
                                                    finalNewModelName)
  
  % origSysName       - The full name of the system (subsystem or model)
  %                     for which a model has just been created
  % newModelName      - This is the name for the model that has just
  %                     been created for origSysName.
  % createdModels     - The main book keeping structure array tracking the
  %                     created models and all of the instances of them
  % finalNewModelName - The name this model will have when conversion 
  %                     is all done. This may be the same as newModelName
  %                     but may also be different (in the case where we will
  %                     use the library name for the model name)
  
  for mdlIdx= 1:length(createdModels)
    theList = createdModels(mdlIdx).Instances;
    for instIdx = 1: length(theList)

      % If the parent has yet to be found look for it here
      if isempty(theList(instIdx).postConversionLocation.ParentModelName)

        convertedSysName = ...
            theList(instIdx).preConversionLocation.FullPathInModel;
        if (block_is_in_system(convertedSysName,origSysName))
          
          ssToReplace.FullName = [newModelName,...
                              strrep(convertedSysName,origSysName,'')];
          ssToReplace.Handle = get_param(ssToReplace.FullName,'Handle');
          ssToReplace.Name   = get_param(ssToReplace.Handle,'Name');
          
          newParent = get_param(ssToReplace.Handle,'Parent');
          if ~strcmp(get_param(newParent,'Type'),'block_diagram')
            newParentRefBlk = get_param(newParent,'ReferenceBlock');
          else
            newParentRefBlk = '';
          end
          if isempty(newParentRefBlk)
            % CASE 1: replace right here in this model
            disp(['Replacing subsystem ''',...
                  strrep(ssToReplace.FullName,sprintf('\n'),' '),...
                  ''' with Model block.']);
            
            replace_block_with_model_block(ssToReplace,...
                                           createdModels(mdlIdx).ModelName,...
                                           createdModels(mdlIdx).LabelOuts);
            theList(instIdx).SubsysReplacedByModelBlk = true;
            
            postConversionLocation.FullPathInModel = ...
                strrep(ssToReplace.FullName,newModelName,finalNewModelName);
            postConversionLocation.ParentModelName = finalNewModelName;
            postConversionLocation.FullPathInLibrary = '';
            postConversionLocation.LibraryName = '';
            theList(instIdx).postConversionLocation = postConversionLocation;
            
          else
            % CASE 2: need to replace in a library
            % set in defaults already: theList(idx).SubsysReplacedByModelBlk 
            % = false;
            postConversionLocation.FullPathInModel = ssToReplace.FullName;
            postConversionLocation.ParentModelName = finalNewModelName;

            % need to build up what block in libToMod needs modifying
            parentFullName = getfullname(newParent);
            parentRefFullName = getfullname(newParentRefBlk);
            origLibPath = ...
                theList(instIdx).preConversionLocation.FullPathInLibrary;
            postConversionLocation.FullPathInLibrary = ...
                strrep(origLibPath,parentFullName,parentRefFullName);
            postConversionLocation.LibraryName = bdroot(newParentRefBlk);
            theList(instIdx).postConversionLocation = postConversionLocation;
          end
        end
      end
    end
    % make sure any changes to theList get kept in the return array
    createdModels(mdlIdx).Instances = theList;
  end

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add_bus_objects_to_creators %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [busCreatorObjects] = add_bus_objects_to_creators(originalSubsystem,...
                                                    newModel,...
                                                    busCreatorObjects)
  
  % Convert any bus creators with bus objects to have the bus object set on them
  for i= 1:length(busCreatorObjects)
    if (~(busCreatorObjects{i}.SetOnBlk))
      
      busCrName  = busCreatorObjects{i}.BlockFullName;
      busObjName = busCreatorObjects{i}.BusName;
      origSysFullName = originalSubsystem.FullName;
      
      if (block_is_in_system(busCrName,origSysFullName))
        blkToMod = strrep(busCrName,origSysFullName,newModel.Name);
        
        if isempty(get_param(blkToMod,'ReferenceBlock'))
          set_param(blkToMod,'UseBusObject','on');
          set_param(blkToMod,'BusObject',busObjName);
          busCreatorObjects{i}.SetOnBlk = true;        
        end
      end
    end
  end

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% replace_block_with_model_block %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function replace_block_with_model_block(ssToReplace,modelNameForModelBlock,labelOuts)
  
  blockHandle = ssToReplace.Handle;
  blockName   = ssToReplace.Name;
  
  % Copy these items from original block
  origPos         = get_param(blockHandle,'Position');
  origOrientation = get_param(blockHandle,'Orientation');
  origForeColor   = get_param(blockHandle,'ForegroundColor');
  origBackColor   = get_param(blockHandle,'BackgroundColor');
  origDropShadow  = get_param(blockHandle,'DropShadow');
  origNamePlace   = get_param(blockHandle,'NamePlacement');
  origShowName    = get_param(blockHandle,'ShowName');
  origPriority    = get_param(blockHandle,'Priority');
  

  blkLines = get_param(blockHandle,'LineHandles');
  parent_to_change = get_param(blockHandle,'Parent');      
  delete_block(blockHandle);
    
  newBlockHandle = add_block('built-in/ModelReference',...
                             [parent_to_change,'/',...
                              strrep(blockName,'/','')]);
  
  set_param(newBlockHandle,'ModelName',modelNameForModelBlock);
  
  set_param(newBlockHandle,'Position',       origPos);
  set_param(newBlockHandle,'Orientation',    origOrientation);
  set_param(newBlockHandle,'ForegroundColor',origForeColor);
  set_param(newBlockHandle,'BackgroundColor',origBackColor);
  set_param(newBlockHandle,'DropShadow',     origDropShadow);
  set_param(newBlockHandle,'NamePlacement',  origNamePlace);
  set_param(newBlockHandle,'ShowName',       origShowName);
  set_param(newBlockHandle,'Priority',       origPriority);
  
  % The new block should have automatically connected to the old wires.
  % Verify this.
  newBlkPorts = get_param(newBlockHandle,'PortHandles');
  for i=1:length(newBlkPorts.Inport) 
    if ( (get_param(newBlkPorts.Inport(i),'Line') ~= blkLines.Inport(i)) && ...
         blkLines.Inport(i) ~= -1) 
      if (get_param(blkLines.Inport(i),'DstPortHandle') ~= ...
          newBlkPorts.Inport(i)) ||...
            (get_param(blkLines.Inport(i),'DstBlockHandle') ~= newBlockHandle)
        warning(['Something went wrong with wiring Input port ',...
                 sprintf('%d',i),...
                 ' of model block ',get_param(newBlockHandle,'Name'), ...
                 ' in system ',get_param(newBlockHandle,'Parent')]);
      end
    end
  end
  
  for i=1:length(newBlkPorts.Outport) 
    if ( (get_param(newBlkPorts.Outport(i),'Line') ~= blkLines.Outport(i)) && ...
         blkLines.Outport(i) ~=-1)
      if (get_param(blkLines.Outport(i),'SrcPortHandle') ~= ...
          newBlkPorts.Outport(i)) || ...
            (get_param(blkLines.Outport(i),'SrcBlockHandle') ~= newBlockHandle)
        warning(['Something went wrong with wiring Output port ',...
                 sprintf('%d',i),...
                 ' of model block ',get_param(newBlockHandle,'Name'), ...
                 ' in system ',get_param(newBlockHandle,'Parent')]);
      end
    end
  end
  
  % Set the labels on the output ports of the Model block as needed
  % Note this is a workaround for geck 203295 (R14FCS branch).
  for labelIdx = 1:length(labelOuts)
    set_param(newBlkPorts.Outport(labelOuts(labelIdx).outIdx),...
              'Name',labelOuts(labelIdx).label);
  end

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% string_to_variable_name %
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stringOut = string_to_variable_name(stringIn,maxLength,mdlNameKeepEndWhenTooLong)
% Take in a string and convert it to a valid and unique identifier
% This is used for creating busObject names and model names for model 
% reference conversion
  
  persistent modelReferenceIdentifierCount;
  
  if isempty(modelReferenceIdentifierCount)
    modelReferenceIdentifierCount = 0;
  end
  
  % Take care of a few bad characters
  stringOut = strrep(stringIn, ' ', '_');
  stringOut = strrep(stringOut, sprintf('\n'), '_');
  stringOut = strrep(stringOut, '~', '_');
  stringOut = strrep(stringOut, '`', '_');
  stringOut = strrep(stringOut, '!', '_');
  stringOut = strrep(stringOut, '@', '_');
  stringOut = strrep(stringOut, '#', '_');
  stringOut = strrep(stringOut, '$', '_');
  stringOut = strrep(stringOut, '%', '_');
  stringOut = strrep(stringOut, '^', '_');
  stringOut = strrep(stringOut, '&', '_'); % and?
  stringOut = strrep(stringOut, '*', '_');
  stringOut = strrep(stringOut, '(', '_');
  stringOut = strrep(stringOut, ')', '_');
  stringOut = strrep(stringOut, '-', '_');
  stringOut = strrep(stringOut, '+', '_'); %and?
  stringOut = strrep(stringOut, '=', '_');
  stringOut = strrep(stringOut, '\', '_');
  stringOut = strrep(stringOut, '|', '_');
  stringOut = strrep(stringOut, '{', '_');
  stringOut = strrep(stringOut, '}', '_');
  stringOut = strrep(stringOut, '[', '_');
  stringOut = strrep(stringOut, ']', '_');
  stringOut = strrep(stringOut, ':', '_');
  stringOut = strrep(stringOut, ';', '_');
  stringOut = strrep(stringOut, '''', '_');
  stringOut = strrep(stringOut, '"', '_');
  stringOut = strrep(stringOut, '<', '_');
  stringOut = strrep(stringOut, '>', '_');
  stringOut = strrep(stringOut, ',', '_');
  stringOut = strrep(stringOut, '.', '_');
  stringOut = strrep(stringOut, '?', '_');
  stringOut = strrep(stringOut, '/', '_');
  
  % A couple of things to help get more meaningful names
  % More useful characters can be kept if these redundancies are removed
  stringOut = strrep(stringOut,'Bus_Creator','Bus');
  while findstr(stringOut,'__')
    stringOut = strrep(stringOut,'__','_');
  end
  
  % Keep the model from being named certain C keywords
  if strcmpi(stringOut,'matrix') || strcmpi(stringOut,'vector')
    stringOut = [stringOut,'1'];
  end                 
                 
  % Keep only the last 63 characters if too long
  % What is the recommended length of a model name?
  if length(stringOut) > maxLength
    if mdlNameKeepEndWhenTooLong
      stringOut = stringOut((end-(maxLength-1)):end);
    else
      stringOut = stringOut(1:maxLength);
    end
  end
  
  % Make sure it is unique
  i=0;
  tempStr = stringOut;
  while exist(tempStr)
    i = i+1;
    if ( (length(stringOut) + length(num2str(i))) > maxLength)
      intPostFix = sprintf('%d',i);
      if mdlNameKeepEndWhenTooLong
        tempStr = [stringOut((end-(maxLength-length(intPostFix)-1)):end),...
                   intPostFix];
      else
        tempStr = [stringOut(1:(maxLength-length(intPostFix))),intPostFix];
      end
    else 
      tempStr = [stringOut,sprintf('%d',i)];
    end
  end
  stringOut = tempStr;
    
  % Make sure it starts with a letter
  if ~isletter(stringOut(1))
    stringOut(1)='A';
  end
  
  if exist(stringOut) || ~isvarname(stringOut)
    % give up and use our backup plan
    modelReferenceIdentifierCount = modelReferenceIdentifierCount + 1;
    while exist(['modelReferenceId',...
                 sprintf('%d',modelReferenceIdentifierCount)])
      modelReferenceIdentifierCount = modelReferenceIdentifierCount + 1;
    end
    stringOut = ['modelReferenceId',...
                 sprintf('%d',modelReferenceIdentifierCount)];
    warning(['string_to_variable_name: Falied to create a unique and valid ',...
             'variable name from ''',stringIn,...
             ''' Using default identifier: ''',stringOut,''' instead.']);
  end
  
 % warning(s);
  
%%%%%%%%%%%%%%%%%%%%% 
% config_set_checks %
%%%%%%%%%%%%%%%%%%%%%
function config_set_checks(modelH,changeNow)
  
  configSet = getActiveConfigSet(modelH);
  
  % (1) Make sure we have RTWInlineParameters on
  OPTComponent = configSet.getComponent('Optimization');
  if ~strcmp(OPTComponent.InlineParams,'on')
    if changeNow
      OPTComponent.InlineParams='on';
    else
      warning(['Inline Parameters must be ''on'' for model reference.',...
               'Inline Parameters will be turned on for all models created']);
    end
  end
  
  % (2) Make sure the solver is fixed step
  slvrComponent = configSet.getComponent('Solver');
  if ~strcmp(slvrComponent.SolverType,'Fixed-step')
    if changeNow
      slvrComponent.SolverType = 'Fixed-Step';
    else
      warning(['The model is configured to use a variable step solver.'...
               'Model reference requires a fixed step solver. ',...
               'The solver will be changed to fixed step for all ',...
               'models created']);
    end
  end

%%%%%%%%%%%%%%%%%%%%%%
% block_is_in_system %
%%%%%%%%%%%%%%%%%%%%%%
function blkIsInSys = block_is_in_system(theBlock,theSystem)
  
  blkIsInSys = false;  
  
  theParent = get_param(theBlock,'Parent');
  while ~isempty(theParent)
    if strcmp(theParent,theSystem)
      blkIsInSys = true;
      break;
    end
    theParent = get_param(theParent,'Parent');
  end
  
  return

  
%%%%%%%%%%%%%%%%%%%%%
% find_signal_label %
%%%%%%%%%%%%%%%%%%%%%
% This function determines what label, if any, needs to be set on the 
% specified output port for the model we are creating. 
%
function labelOuts = find_signal_label(srcPort,...
                                       busInfo,...
                                       outIdx,...
                                       labelsArray)
  % Initialize the output
  labelOuts = labelsArray;
  
  srcName = get_param(srcPort,'Name');
  % RefreshedPropSignals is a hidden never save param which 
  % is a version of PropagatedSignals that does not require 
  % ShowPropagatedSignals to be on
  srcPropagatedName = get_param(srcPort,'RefreshedPropSignals');

  isBus = ~isempty(busInfo);
  if isBus
    busPortH = get_param(busInfo.src,'PortHandles');
    busPort = busPortH.Outport;
    % This is a bus creator it should have only one outport 
    % assert that this is so
    if length(busPort) > 1
      error('ModelRefConv:Fatal',...
            ['Fatal Error: modelref_conversion_utilities: ',...
             'fill_labelOuts_struct: ',...
             'bus creator block has more than one outport']);
    end
    busName =get_param(busPort,'Name');
    busPropagatedName =get_param(busPort,'RefreshedPropSignals');
  else
    busName = '';
    busPropagatedName = '';
  end

  % Assume we do not have a label
  labelString = '';
  
  % Now figure out the name
  if ~isempty(srcName)
    % The signal is labeled right at the outport - use that
    labelString = srcName;
  elseif ~isempty(srcPropagatedName)
    % The signal is labeled but not at the outport
    % Figure out what the string should be 
    if ~isBus
      % We do not have a bus so whatever is in the PropagatedSignals is
      % what we want
      labelString = srcPropagatedName;
    elseif ~isempty(busName)
      % The output of the busCreator itself has been labeled so we know that
      % the propagated signal name is not just the concatenation of the signals
      % feeding the bus, so we can use that
      % Note we use the srcPropagatedName instead of busName in case the signal
      % has been re-named since the bus creator block
      labelString = srcPropagatedName;
    elseif ~strcmp(srcPropagatedName, busPropagatedName)
      % The busPropagatedName is the concatenation of the signals feeding the
      % bus, so if the srcPropagatedName is different, then somewhere between
      % the bus and this outport, the signal has been labeled and so we can
      % use the srcPropagatedName
      labelString = srcPropagatedName;      
    end
  end

  if ~isempty(labelString)
    % add the new label to the struct
    labelToAdd.label = labelString;
    labelToAdd.outIdx = outIdx;
    if isempty(labelOuts)
      labelOuts = labelToAdd;
    else
      labelOuts(end+1) = labelToAdd;
    end
  end

  return