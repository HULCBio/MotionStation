function retVal = disableimplicitsignalresolution(model, displayOnly)
%DISABLEIMPLICITSIGNALRESOLUTION  Convert a model which attempts to resolve signal
%  objects for all named signal and states to only resolve signal objects for
%  those signals / states that explicitly require it.
%
%  The conversion process performs the following operations:
%  - Search for all output ports / block states that resolve to Simulink signal objects.
%  - Modify these ports / blocks to enforce signal object resolution in the future.
%  - Set the model's property SignalResolutionControl to 'UseLocalSettings'.
%
% Syntax:
%   retVal = disableimplicitsignalresolution(model, displayOnly)
%
% Input Arguments:
% - model (required):       Name / handle of model to be converted.
% - displayOnly (optional): Show the changes to be made without doing them (0/1).
%
% Output Argument:
% - retVal: MATLAB structure containing:
%   - Signals: Handles to ports with signal names that resolve to signal objects.
%   - States:  Handles to blocks with states that resolve to signal objects.
% 
% NOTE:
% 1. To perform the conversion process successfully,
%    all the relevant Simulink signal objects must be in the base workspace.
% 2. This function does not enforce signal object resolution for blocks that
%    are library links.
% 3. If Stateflow output data resolves to a Simulink signal object, this function:
%    - Turns off hierarchical scoping of signal objects from within the Stateflow chart.
%    - Explicitly labels the output signal of the Stateflow chart.
%    - Enforces signal object resolution for this signal in the future.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/15 00:45:56 $

  if nargin == 1
    displayOnly = false;
  end

  retVal.Signals = [];
  retVal.States  = [];
  
  model = get_param(model, 'Handle');
  
  % Deal with case where SignalResolutionControl is already 'UseLocalSettings'
  origSetting = get_param(model, 'SignalResolutionControl');
  if strcmp(origSetting, 'UseLocalSettings')
    warnTxt = ['This model has the option OnlyResolveSignalObjectWhereRequired enabled.\n', ...
               'This option will be temporarily disabled during this migration process.'];
    warning(sprintf(warnTxt));
    set_param(model, 'SignalResolutionControl', 'TryResolveAll');
  end

  % Compile the model
  modelName = get_param(model, 'Name');
  
  try
    % Find all output ports with signal labels that have the
    % MustResolveToSignalObject option disabled.
    ports = find_system(model, ...
                              'LookUnderMasks', 'all', ...
                              'Regexp', 'on', ...
                              'FindAll', 'on', ...
                              'Type', 'port', ...
                              'PortType', 'outport', ...
                              'MustResolveToSignalObject', 'off', ...
                              'Name', '\S+');

    hPorts = get_param(ports, 'Object');
    if iscell(hPorts)
      hPorts = [hPorts{:}]';
    end
    
    % Look for ports that have signal objects resolved for them.
    disp('The following signal labels will be forced to resolve to signal objects:');
    for idx = length(hPorts):-1:1
      thisPort = hPorts(idx);

      % Display information about signals to be locked down
      if (l_IsSignalObjectResolved(thisPort.Parent, thisPort.Name))
        if l_IsPortInsideStateflowChart(thisPort);
          % For Stateflow, display chart name not underlying S-Function
          sfChart = get_param(thisPort.Parent, 'Parent');
          usedByStr = l_FullName(sfChart);
        else
          % Otherwise, display blockName/portNo
          usedByStr = l_FullName(thisPort.Parent, num2str(thisPort.PortNumber));
        end

        disp(['- ', strtrim(thisPort.Name), '  (used by: ', usedByStr, ')']);
      else
        ports(idx) = [];
        hPorts(idx) = [];
      end
    end

    if isempty(hPorts)
      disp('... none found ...');
    end
    disp(' ');
    
    % Find all blocks with states that have the
    % StateMustResolveToSignalObject option disabled.
    blks = find_system(model, ...
                       'LookUnderMasks', 'all', ...
                       'Type', 'block', ...
                       'StateMustResolveToSignalObject', 'off');
    
    hBlks = get_param(blks, 'Object');
    if iscell(hBlks)
      hBlks = [hBlks{:}]';
    end
    
    % Check for corresponding Simulink.Signal objects in the base workspace.
    disp('The following states will be forced to resolve to signal objects:');
    for idx = length(hBlks):-1:1
      thisBlk = hBlks(idx);
      
      % Get StateName (special handling for DataStoreMemory block)
      if strcmp(thisBlk.BlockType, 'DataStoreMemory')
        stateName = strtrim(thisBlk.DataStoreName);
      else
        stateName = strtrim(thisBlk.StateIdentifier);
      end
        
      if l_IsSignalObjectResolved(thisBlk.Handle, stateName)
        disp(['- ', stateName, '  (used by: ', ...
              l_FullName(thisBlk.Parent, thisBlk.Name), ')']);
      else
        % Remove the block from the list if the state name doesn't resolve
        blks(idx) = [];
        hBlks(idx) = [];
      end
    end
    
    if isempty(hBlks)
      disp('... none found ...');
    end
    disp(' ');
    
    set_param(model, 'SignalResolutionControl', origSetting);

    % IF REQUESTED - ENFORCE FUTURE SIGNAL RESOLUTION
    if (~displayOnly)
      % For each port whose signal label resolves.
      for idx = 1:length(hPorts)
        thisPort = hPorts(idx);
        if l_IsPortInsideStateflowChart(thisPort)
          % For Stateflow - enforce resolution outside Stateflow Subsystem
          sfChart = get_param(thisPort.Parent, 'Parent');
          sigLabel = thisPort.Name;
          outportBlk = find_system(sfChart, ...
                                   'LookUnderMasks', 'on', ...
                                   'Name',           sigLabel, ...
                                   'BlockType',      'Outport');

          if (iscell(outportBlk) && (length(outportBlk) == 1))
            outportBlk = outportBlk{1};
          else
            error('Assert: Expected to find one outport block with same name as signal');
          end
          
          % MOVE SIGNAL LABEL TO PARENT SUBSYSTEM (Stateflow chart)
          sfPorts    = get_param(sfChart, 'PortHandles');
          sfPortNo   = str2num(get_param(outportBlk, 'Port'));
          thisPort   = get_param(sfPorts.Outport(sfPortNo), 'Object');
          if ~strcmp(thisPort.Name, sigLabel)
            if ~isempty(thisPort.Name)
              warning(sprintf(['Changing signal label from ''%s'' to ''%s'' ', ...
                               'for output of Stateflow chart ''%s'''], ...
                              thisPort.Name, sigLabel, sfChart));
            end
            thisPort.Name = sigLabel;
          end
          
          % Set "PermitHierarchicalScoping" to 'ParametersOnly' for Stateflow chart
          set_param(sfChart, 'PermitHierarchicalResolution', 'ParametersOnly');
        end
        thisPort.MustResolveToSignalObject = false;
        thisPort.RTWStorageClass = 'ExportedGlobal';
        thisPort.RTWStorageTypeQualifier = '';
        thisPort.RTWStorageClass = 'Auto';
        thisPort.MustResolveToSignalObject = true;
      end
      
      % For each block with state and a corresponding signal object.
      for idx = 1:length(hBlks)
        thisBlk = hBlks(idx);
        thisBlk.RTWStateStorageClass = 'ExportedGlobal';
        thisBlk.RTWStateStorageTypeQualifier = '';
        thisBlk.RTWStateStorageClass = 'Auto';
        thisBlk.StateMustResolveToSignalObject = true;
      end
      set_param(model, 'SignalResolutionControl', 'UseLocalSettings');
    end
    
    % Disable automatic signal label resolution for this model
    if (~displayOnly)
    end
    
    retVal.Signals = ports;
    retVal.States  = blks;
    
  catch
    set_param(model, 'SignalResolutionControl', origSetting);
    error(lasterr);
  end
  
% endfunction

%------------------------------------------------------------------------------
% SUBFUNCTIONS
%------------------------------------------------------------------------------
function name = l_FullName(name, suffix)
  
  if nargin == 2
    name = [name, '/', suffix];
  end
  
  name = strrep(name, sprintf('\n'), ' ');
  
% endfunction

%------------------------------------------------------------------------------
function isStateflow = l_IsPortInsideStateflowChart(thisPort)

  parentBlk = thisPort.Parent;
  parentSys = get_param(parentBlk, 'Parent');
  
  % Check if parent system is Stateflow subsystem (chart)
  if ((strcmp(get_param(parentSys, 'Type'), 'block')) && ...
      (strcmp(get_param(parentSys, 'MaskType'), 'Stateflow')))
    isStateflow = true;
  else
    isStateflow = false;
  end
  
%endfunction

%------------------------------------------------------------------------------
function doesResolve = l_IsSignalObjectResolved(hSrc, name)
% Check whether name resolves to signal object in base workspace.

  if isempty(name)
    doesResolve = false;
  else
    
    % Check for blocks that are inside subsystems that prevent hierarchical resolution
    parent = get_param(hSrc, 'Parent');
    while strcmp(get_param(parent, 'Type'), 'block')
      if strcmp(get_param(parent, 'PermitHierarchicalResolution'), 'All')
        parent = get_param(parent, 'Parent');
      else
        doesResolve = false;
        return;
      end
    end
    
    % Check if signal object exists in base workspace
    varExists = evalin('base', ['exist(''', name, ''', ''var'');']);
    if ((varExists) && ...
        (evalin('base', ['isa(', name, ', ''Simulink.Signal'');'])))
      doesResolve = true;
    else
      doesResolve = false;
    end
  end

%endfunction
  
% EOF