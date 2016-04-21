function varargout = signalselector(varargin)
% SIGNALSELECTOR creates and manages the Signal Selector

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.13 $  $Date: 2004/05/03 01:39:11 $
%   Sanjai Singh 08-17-00

  try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define PERSISTENT variables that track the state of the Selector %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    persistent USERDATA;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Lock the file to prevent tampering %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mlock
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% Determine arguments %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
    Action = varargin{1};
    args   = varargin(2:end);
    
    %%%%%%%%%%%%%%%%%%%%
    %% Process Action %%
    %%%%%%%%%%%%%%%%%%%%
    switch (Action)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Create Signal Selector if needed or make it visible %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     case 'Create'
      
      % Test for existence of java
      if ~usejava('MWT')
        error('The Signal selector requires Java support');
      end
      
      % Get data to be stored
      FunctionHandle = args{1};
      BlockHandle    = args{2};
      NumInputs      = args{3};
      ShowInputNum   = args{4};
      PortPrefix     = args{5};
      MultipleSigs   = args{6};
      DialogTitle    = args{7};
      
      % Check if dialog already created
      dialog_exists = 0;
      idx = FindSignalSelector(USERDATA, BlockHandle);
      if ~isempty(idx)
        PanelHandle   = USERDATA(idx).PanelHandle;
        dialog_exists = 1;
      end
      
      % Create dialog for Signal Selector block and store it
      if (dialog_exists == 0)
        PanelHandle                  = SignalSelectorCreate(BlockHandle, ...
                                                          NumInputs, ShowInputNum, PortPrefix, ...
                                                          MultipleSigs, DialogTitle);
        USERDATA(end+1).BlockHandle  = BlockHandle;
        USERDATA(end).NumInputs      = NumInputs;
        USERDATA(end).PanelHandle    = PanelHandle;
        USERDATA(end).FunctionHandle = FunctionHandle;
      end
      
      PanelHandle.selectInputNumber(ShowInputNum);
      
      % Now make it visible
      frame = PanelHandle.getParent;
      frame.show;
      
     case {'Close', 'Delete'}
      BlockHandle = args{1};
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      
      % Check if dialog exists
      if ~isempty(idx)
        PanelHandle = USERDATA(idx).PanelHandle;
        Function    = USERDATA(idx).FunctionHandle;
        frame       = PanelHandle.getParent;
        frame.dispose;
        USERDATA(idx) = [];
        
        % Inform function that has registered with this that the dialog is closing
        if strcmp(Action, 'Close')
          try
            feval(Function, 'DialogClosing', BlockHandle);
          end
        end
      end
      
     case 'UpdateInputNum',
      BlockHandle = args{1};
      InputNumber = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);

      if ~isempty(idx),
        PanelHandle = USERDATA(idx).PanelHandle;
        PanelHandle.selectInputNumber(InputNumber);
        PanelHandle.populate;
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Find signal data for population %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     case 'Populate'
      BlockHandle = args{1};
      InputNumber = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);

      if (~isempty(idx) & ishandle(BlockHandle))
        Function    = USERDATA(idx).FunctionHandle;
        newNumPorts = sigandscopemgr('GetNumPorts', BlockHandle);
        
        [varargout{1}, varargout{2}, varargout{3},...
         varargout{4}, varargout{5}, varargout{6},...
         varargout{7}, varargout{8}, varargout{9},...
         varargout{10}, varargout{11}]= DeterminePopulationData(USERDATA(idx), InputNumber, newNumPorts, args(3:end));
        
        %
        % Update current axes on scope.
        %  xxx need better way of knowing that parent is scope or need to make
        %      a new required method by all clients so that we can blindly
        %      let the client know everytime that the popup changes.
        %
        bType = lower(get_param(BlockHandle,'BlockType'));
        if findstr('scope',bType),
          scopeFig = get_param(BlockHandle,'Figure');
          if ishandle(scopeFig),
            feval(Function,'SetSelectedAxes', scopeFig, InputNumber);
          end
        end
      end
      
     case 'UpdateName'
      BlockHandle = args{1};
      NewName     = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      if ~isempty(idx)
        PanelHandle = USERDATA(idx).PanelHandle;
        PanelHandle.updateTitleBar(NewName);
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% API Definition for GET/ADD/REMOVE %%
      %% port selection for a block        %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     case 'GetSelection'
      BlockHandle = args{1};
      InputNumber = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      Function    = USERDATA(idx).FunctionHandle;
      try
        varargout{1} = feval(Function, 'GetSelection', BlockHandle, InputNumber);
      catch
        varargout{1} = [];
      end
      
     case 'AddSelection'
      BlockHandle = args{1};
      InputNumber = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      Function    = USERDATA(idx).FunctionHandle;
      slObjects       = args{3};
      if iscell(slObjects)
        slObjects = [slObjects{:}]';
      end

      if(isempty(slObjects)) 
        return 
      end
      
      parentBlock = get_param(slObjects(1),'Parent')
      parentBlockIsInsideModelRef = i_IsObjectInsideModelRef(BlockHandle, parentBlock);

      if(parentBlockIsInsideModelRef)
         blkHandleToBeAdded = args{5};
       else
         blkHandleToBeAdded = slObjects(1);
       end
       
      if(strcmp(get_param(slObjects(1),'Type'),'block') || parentBlockIsInsideModelRef)
        % args{3} is a block
        % args{4} is relativepath
        relPath = args{4};
        sIOSigs = get_param(BlockHandle,'IOSignals');
        ioSigs{InputNumber}.Handle = blkHandleToBeAdded;
        for k=1:length(relPath)                                          
          ioSigs{InputNumber}.RelativePath = relPath{k};
          if(~isempty(sIOSigs))
            % Remove bad handles
            sIOSigs{InputNumber}([sIOSigs{InputNumber}.Handle] == -1) = [];
            sIOSigs{InputNumber}(end+1) = ioSigs{InputNumber};
          else
            error('M Assert: unexpected empty return of IOSignals');
          end
        end
        set_param(BlockHandle,'IOSignals', sIOSigs)   
      else
        % slObjects is a port
        ports = slObjects;
        try
          feval(Function, 'AddSelection', BlockHandle, InputNumber, ports);
        end
        if i_LinkedToSignalAndScopeMgr(BlockHandle),
          sigandscopemgr('UpdateSelections', BlockHandle);
        end                    
      end
     
     case 'RemoveSelection'
      BlockHandle = args{1};
      InputNumber = args{2};
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      Function    = USERDATA(idx).FunctionHandle;
      slObjects       = args{3};
      if iscell(slObjects)
        slObjects = [slObjects{:}]';
      end

      if(isempty(slObjects)) 
        return 
      end

      parentBlock = get_param(slObjects(1),'Parent')
      parentBlockIsInsideModelRef = i_IsObjectInsideModelRef(BlockHandle, parentBlock);

       if(parentBlockIsInsideModelRef)
         blkHandleToBeRemoved = args{5};
       else
         blkHandleToBeRemoved = slObjects(1);
       end
       
      if(strcmp(get_param(slObjects(1),'Type'),'block') || parentBlockIsInsideModelRef)
         % args{3} is a block
         % args{4} is relativepath
         relPath = args{4};
         rC = [];
         scopeIOSigs = get_param(BlockHandle,'IOSignals');
         for k=1:length(relPath)
           for(m=1:length(scopeIOSigs{InputNumber}))
             if( strcmp(relPath{k} , scopeIOSigs{InputNumber}(m).RelativePath))
               if(blkHandleToBeRemoved  == scopeIOSigs{InputNumber}(m).Handle )
                 rC = [rC m];                 
               end
             end                
           end
         end
         scopeIOSigs{InputNumber}(rC) = [];
         set_param(BlockHandle,'IOSignals', scopeIOSigs)
      else
        % slObjects is a port
        ports = slObjects;
        try
          feval(Function, 'RemoveSelection', BlockHandle, InputNumber, ports);
        end
        if i_LinkedToSignalAndScopeMgr(BlockHandle),
          sigandscopemgr('UpdateSelections', BlockHandle);
        end        
      end
      
     case 'SwitchSelection'
      BlockHandle = args{1};
      InputNumber = args{2};
      % abort if simulation is running
      if(strcmp(get_param(bdroot(BlockHandle),'SimulationStatus'),'running'))
        warning('Cannot select signal while simulation is running')
        return
      end
      
      idx         = FindSignalSelector(USERDATA, BlockHandle);
      Function    = USERDATA(idx).FunctionHandle;
      oldPort     = args{3};
      newPort     = args{4};
      parentBlock = get_param(newPort,'Parent')
      parentBlockIsInsideModelRef = i_IsObjectInsideModelRef(BlockHandle, parentBlock);
      
      if(parentBlockIsInsideModelRef)
        blkHandleToBeAdded = args{6};
       else
         blkHandleToBeAdded = newPort;
       end
      
      if(strcmp(get_param(newPort,'type'), 'block') || parentBlockIsInsideModelRef)       
        sIOSigs = get_param(BlockHandle,'IOSignals');
        relPath = args{5};
        if(~isempty(sIOSigs))
          sIOSigs{InputNumber} = struct('Handle',blkHandleToBeAdded,'RelativePath',relPath);
          set_param(BlockHandle,'IOSignals', sIOSigs)
        end
      else
        try
          feval(Function, 'SwitchSelection', BlockHandle, InputNumber, oldPort, newPort);
        end
      end
      if i_LinkedToSignalAndScopeMgr(BlockHandle),
        sigandscopemgr('UpdateSelections', BlockHandle);
      end
     case 'BlockStart', 
      BlockHandle = args{1};
      lockStatus  = 1;
      updateUILockStatus(BlockHandle, lockStatus, USERDATA)                        
     case 'BlockTerminate'
      BlockHandle = args{1};
      lockStatus  = 0;
      updateUILockStatus(BlockHandle, lockStatus ,USERDATA)  
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %% Get UserData for testing %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     case 'GetUserData'
      varargout{1} = USERDATA;
      
     case 'GetBlockUserData'
      BlockHandle  = args{1};
      idx          = FindSignalSelector(USERDATA, BlockHandle);
      varargout{1} = USERDATA(idx);
      
    end

  catch 
    % Display an error message window if any error occurs
    errordlg(lasterr);
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = FindSignalSelector(UD, H)
% Find the Signal Selection dialog for the given block and the given args

idx = [];
if ~isempty(UD)
  idx = find([UD.BlockHandle] == H);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function panel = SignalSelectorCreate(H, numInputs, showNum, portPrefix, multipleSigs, title)
% Create the Signal Selection dialog for the given block

% Call constructor
name  = strrep(getfullname(H), sprintf('\n'), ' ');

isForGenerator = false;
showModelRef   = false;

blockType = get_param(H, 'BlockType');
ioType    = get_param(H, 'IOType');

if (strcmp(blockType, 'Scope') | strcmp(blockType, 'SignalViewerScope')) ...
      & strcmp(ioType, 'viewer')
  showModelRef = true;
end
  
try
  isForGenerator = strcmpi(get_param(H, 'IOType'), 'siggen');
end

panel = ...
    com.mathworks.toolbox.simulink.signalselector.SignalSelector ...
    .CreateSignalSelector(name, bdroot(H), H, numInputs, showNum, ...
                          portPrefix, multipleSigs, title, isForGenerator, showModelRef);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = UpdateSelectionData(block, inputNumber, ports)

flags      = zeros(length(ports), 1);
blockPorts = signalselector('GetSelection', block, inputNumber);

for i = 1:length(flags)
  flags(i) = ~isempty(find(ports(i) == blockPorts));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flags = UpdateModelReferenceSelectionData(block, mdlrefblock, inputNumber, portParent, checkfullPathName)

if(nargin == 4)
  checkfullPathName = false;
end
flags = 0;

vs     = get_param(block, 'IOSignals');
vsAxes = vs{inputNumber};
for(i=1:length(vsAxes))
  sig = vsAxes(i);
  bH  = [sig.Handle];
  if(checkfullPathName)
    blkRelPath = sig.RelativePath;
  else
    blkRelPath = strtok(sig.RelativePath, ':');
  end
  if(mdlrefblock == bH)
    if(strcmp(blkRelPath, portParent))
      flags = 1;
      return;
    end
  end        
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  updateUILockStatus(BlockHandle, lockStatus, USERDATA)

idx  = FindSignalSelector(USERDATA, BlockHandle);
if ~isempty(idx)
  PanelHandle = USERDATA(idx).PanelHandle;
  PanelHandle.updateUILockStatus(lockStatus);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ports, names, flags, genStrs, parents, tps, types, relPaths] = ...
    CollectStateflowTestPointData(fSigBlk, sfBlk, inputNumber)

sfChart = sf('Private', 'block2chart', sfBlk);
sfChartPath = sf('FullNameOf', sfChart, '/');
sfTps = sf('Private', 'test_points_in', sfChart);

numTps   = length(sfTps);
ports    = zeros(numTps, 1);
names    = cell(numTps, 1);
flags    = zeros(numTps, 1);
genStrs  = cell(numTps, 1);
parents  = cell(numTps, 1);
tps      = cell(numTps, 1);
types    = cell(numTps, 1);
relPaths = cell(numTps, 1);

for i = 1:length(sfTps)
    objId = sfTps(i);

    ports(i)    = sfBlk;                        % SF Chart block handle
    names{i}    = sf('FullNameOf', objId, sfChart, '.'); % Signal name, relative path for SF testpoints
    %flags(i)    = 0;                            % Is signal selected
    flags(i)    = UpdateModelReferenceSelectionData(fSigBlk, ...
                                                    sfBlk, ...
                                                    inputNumber, ...
                                                    ['StateflowChart/',names{i}]);
    genStrs{i}  = '';
    parents{i}  = sfChartPath;                  % SF Chart path
    tps{i}      = '';
    types{i}    = '';                           % Signal data type
    relPaths{i} = sprintf('StateflowChart/%s:o1', names{i});   % CAPI Signal path
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ports, names, flags, genStrs, parents, tps, types, newNumPorts, relPaths, cascadeModelRef, lockUI] = ...
      DeterminePopulationData(UD, inputNumber, newNumPorts, args)

  ports   = [];  
  names   = {''};
  flags   = [];
  genStrs = {''};
  parents = {''};
  tps     = {''};
  types   = {''};
  relPaths = {''};
  cascadeModelRef = 0;
  lockUI = 0;
  
  if (inputNumber > newNumPorts)
    inputNumber = newNumPorts;
  end

  BlockHandle = UD.BlockHandle;  
  if(strcmp(get_param(bdroot(BlockHandle),'SimulationStatus'),'running'))
    lockUI = 1;
  end
  
  if(strcmp(get_param(args{1},'Type'),'block') && strcmp(determineBlockType(args{1}),'Stateflow'))
      [ports, names, flags, genStrs, parents, tps, types, relPaths] = ...
          CollectStateflowTestPointData(BlockHandle, args{1}, inputNumber);
      return;
  end
  
  blkIsInsideOfModelRefBlock = i_IsObjectInsideModelRef(BlockHandle, args{1});
  parentModelRefHandle = -1;
  originalSigType = args{9};
  mrefPorts = [];
  m_refHandles = [];
  if(blkIsInsideOfModelRefBlock)
    % The block's parent is a model Reference block. 
    % Show the testedpoints signals only  
    args{9} = 'TestPointed';
    parentModelRefHandle = UD.PanelHandle.getParentMRBlockHandleFromSelectedSubsystem;   
  end
 
 if(strcmp(get_param(args{1},'Type'),'block'))     
   if(strcmp(determineBlockType(args{1}),'ModelReference'))
     args{9} = 'TestPointed';
   end
 end 

PORTTYPE    = 'OUTPORT';
if strcmp(get_param(BlockHandle, 'IOType'), 'siggen')
  PORTTYPE = 'INPORT';
end

% Determine signal types to look for
sigType = args{find(strcmpi(args, 'SignalType')) + 1};

% Determine searchdepth
depthIdx = find(strcmpi(args, 'SearchDepth')) + 1;
args{depthIdx} = str2num(args{depthIdx});

%%%%%%%%%% DETERMINE IF WE SHOULD SHOW OUTPORTS OR INPORTS %%%%%%%%%%%%
if strcmp(PORTTYPE, 'OUTPORT')
  if (strncmpi(sigType, 'testpoint', 9))
    ports1 = find_system(args{1:7}, 'FindAll',   'on', ...
                         'PortType',  'outport', ...
                         'Testpoint', 'on');
    ports2 = find_system(args{1:7}, 'FindAll',   'on', ...
                         'PortType',  'state', ...
                         'Testpoint', 'on');
  else      
    ports1 = find_system(args{1:7}, 'FindAll', 'on', 'PortType', 'outport');
    ports2 = find_system(args{1:7}, 'FindAll', 'on', 'PortType', 'state');
  end
  ports = [ports1(:) ; ports2(:)]
else
  % Unconnected input ports
  ports1 = find_system(args{1:7}, 'FindAll',  'on', ...
                       'PortType', 'inport', ...
                       'Line',     -1);
  % Unconnected enable ports
  ports2 = find_system(args{1:7}, 'FindAll',  'on', ...
                       'PortType', 'enable', ...
                       'Line',     -1);
  % Unconnected trigger ports
  ports3 = find_system(args{1:7}, 'FindAll',  'on', ...
                       'PortType', 'trigger', ...
                       'Line',     -1);
  % Unconnected lines (with no input)
  unconn = find_system(args{1:7}, 'FindAll',       'on', ...
                       'Type',          'line', ...
                       'SegmentType', 'trunk', ...
                       'SrcBlockHandle', -1);
  ports4 = get_param(unconn, 'DstPortHandle');
  if ~iscell(ports4)
    ports4 = {ports4};
  end
  
  if iscell(ports4)
    ports4 = cell2mat(ports4);
  end
  ports4 = ports4(find(ports4 > 0));
  
  ports = [ports1(:) ; ports2(:) ; ports3(:) ; ports4(:)];
end

% Uniquefy ports
ports = unique(ports);
PortsAndBlocks = [];

ports = removeStateFlowPorts(ports);

[ports, PortsAndBlocks, cascadeModelRef] = getPortsAndBlocksForCurrentSystem(args, ports,...
                                                     PortsAndBlocks, BlockHandle, cascadeModelRef, depthIdx)

if(cascadeModelRef)
  cascadeModelRef = double(~feature('MultilevelModelReferenceSignalLogging'));
end

if isempty(ports), return, end %nothing to do

% Create port data
sigNames = get_param(ports, 'Name');
if ~iscell(sigNames)
  sigNames = {sigNames};
end
emptyIdx = find(strcmp(sigNames, ''));

if (strncmpi(sigType, 'named', 5))
  ports(emptyIdx)    = []; 
  sigNames(emptyIdx) = [];
  % We need this to keep the two arrays in sync
  if(~isempty(PortsAndBlocks))
    PortsAndBlocks(emptyIdx) = [];
  end
else
  blkHs = get_param(ports, 'Parent');
  if ~iscell(blkHs)
    blkHs = {blkHs};
  end
  blks  = get_param(blkHs,  'Name');
  if ~iscell(blks)
    blks = {blks};
  end
  port_num = get_param(ports, 'PortNumber');
  if ~iscell(port_num)
    port_num = {port_num};
  end
  port_type = get_param(ports, 'PortType');
  if ~iscell(port_type)
    port_type = {port_type};
  end
  
  % If block has one port, don't add port number, else do
  % and create the default name
  if strcmp(PORTTYPE, 'OUTPORT')
      IDX_CHECK = 2;
  else
      IDX_CHECK = 1;
  end
  for i = 1:length(blkHs)
    p = get_param(blkHs{i}, 'Ports');
    if strcmpi(port_type{i}, 'inport') | strcmp(port_type{i}, 'outport')
      if (p(IDX_CHECK) == 1)
        defNames{i} = blks{i};
      else
        defNames{i} = [blks{i} ' : ' num2str(port_num{i})];
      end
    else
        defNames{i} = [blks{i} ' : (' port_type{i} ')'];
    end
  end

  sigNames(emptyIdx) = defNames(emptyIdx);
end

% Now sort signal names and ports
[sigNames idx] = sort(sigNames);
ports = ports(idx);
if(~isempty(PortsAndBlocks))
  PortsAndBlocks = PortsAndBlocks(idx);
end

% Determine which are selected and which are not
if(blkIsInsideOfModelRefBlock)
  for i=1:length(ports)
    portParent = get_param(ports(i),'Parent');
    sigFlags(i) = UpdateModelReferenceSelectionData(BlockHandle, parentModelRefHandle, inputNumber, portParent);
  end
else
   sigFlags = UpdateSelectionData(BlockHandle, inputNumber, ports);
end

% Tabulate results
names   = strrep(sigNames, sprintf('\n'), ' ');
flags   = sigFlags;
parents = strrep(get_param(ports, 'Parent'), sprintf('\n'), ' ');
if ~iscell(parents)
  parents = {parents};
end

% Cache generator strings
try
  genStrs = strrep(get_param(ports, 'SigGenPortName'), sprintf('\n'), ' ');
  if ~iscell(genStrs)
    genStrs = {genStrs};
  end
catch
  lasterr('');
  genStrs = cell(length(ports));
  [genStrs{:}] = deal('');
end

tps = get_param(ports, 'Testpoint');
if ~iscell(tps)
  tps = {tps};
end

types = get_param(ports, 'CompiledPortDataType');
if ~iscell(types)
  types = {types};
end
for i = 1:length(types)
  relPaths{i} = '?';
  if isempty(types{i})
    types{i} = '???';
  end
end


% Construct the parents and relative paths for blocks 
% inside of a model reference block
if(blkIsInsideOfModelRefBlock)
  sys   = args{1};
  portParent =     get_param(sys,'Name');      
  for i=1:length(relPaths)
    portParent = get_param(ports(i),'Parent');
    pn = get_param(ports(i),'PortNumber');
    relPaths{i} =   [portParent ':o' num2str(pn)];
  end
  for(i=1:length(parents))
    parents{i} = [getfullname(parentModelRefHandle)  '|' getfullname(parents{i}) ]            
  end
end

encPath = char(UD.PanelHandle.getEncodedPathFromSelectedNode);
% Construct parents and relative paths from the PortsAndBlocks array
if(feature('MultilevelModelReferenceSignalLogging'))
  [relPaths, parents, ports, flags] = getRelativePath(UD, relPaths, ports,...
                                                          PortsAndBlocks,...
                                                          flags,...
                                                          BlockHandle,...
                                                          inputNumber);  
else
  if(~isempty(PortsAndBlocks))
    for i=1:length(relPaths)
      sys   = args{1};
      portParent = get_param(ports(i),'Parent');
      if(strcmp(get_param(PortsAndBlocks(i),'type'),'block'))
        flags(i)   = UpdateModelReferenceSelectionData(BlockHandle, PortsAndBlocks(i), inputNumber, portParent);
        parents{i} = [getfullname(PortsAndBlocks(i)) '|' getfullname(portParent)];
        pn = get_param(ports(i),'PortNumber');
        relPaths{i} =   [portParent ':o' num2str(pn)];
      end   
    end
    ports = PortsAndBlocks;
  end
end

% If we want only selected ports, get the selection and use that
if (strncmpi(originalSigType, 'selected', 8))
  selected_ports = signalselector('GetSelection', BlockHandle, inputNumber);
  ports = ports(find(flags == 1));
  names = names(find(flags == 1));
  genStrs = genStrs(find(flags == 1));
  parents = parents(find(flags == 1));
  tps     = tps(find(flags == 1));
  types   = types(find(flags == 1));
  relPaths = relPaths(find(flags == 1));
  flags = flags(flags == 1);
  % If the searchdepth is 1, then we have to show ports at this level only.
  % But if the searchdepth is inf, then we have to show all ports below
  % this level.
  if (args{depthIdx} == 1)
    sys   = args{1};
    if iscell(selected_ports)
      selected_ports = [ selected_ports{:}];
    end
    port = intersect(ports, selected_ports);
  else
      % This is tricky - xxx - needs to be implemented
  end
end        
    
%end of DeterminePopulationData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [relPaths, parents, ports, flags] = getRelativePath(UD, relPaths, ports,...
                                                                 PortsAndBlocks,...
                                                                 flags,...
                                                                 BlockHandle,...
                                                                 inputNumber)
% Returns the relative path

encPath = char(UD.PanelHandle.getEncodedPathFromSelectedNode);

if(~isempty(PortsAndBlocks))
  portParent = get_param(ports(1),'Parent');
  % Remove the trailing submodel name. For example:
  % encPath     -> 'mtop_model_hierarchy1/MR|msubmodel_hierarchy/MR|msubmodel_hierarchy1'
  % new encPath -> 'mtop_model_hierarchy1/MR|msubmodel_hierarchy/MR
  IDX = strfind(encPath, ['|' bdroot(portParent)]);
  encPath = encPath(1:IDX);

  for i=1:length(relPaths)
    portParent = get_param(ports(i),'Parent');
    encPortParent = private_sl_encpath(portParent,'','','none');
    pn = get_param(ports(i),'PortNumber');
    relPaths{i}  = [encPath  encPortParent];   
    % remove the path of the top model block
    % Example: 
    %  relPaths{i} -> mtop_model_hierarchy1/MR|msubmodel_hierarchy/MR|msubmodel_hierarchy1/Subsystem/Gain1:o1
    %  relPaths{i} -> msubmodel_hierarchy/MR|msubmodel_hierarchy1/Subsystem/Gain1:o1
    pathParentMdlBlk = private_sl_decpath(relPaths{i});
    relPaths{i} = relPaths{i}(length(pathParentMdlBlk)+2:end);
    if(~isempty(relPaths{i}))
      relPaths{i}  = [relPaths{i} ':o' num2str(pn)];       
      ParentMdlBlkHandle = get_param(pathParentMdlBlk,'Handle');
      flags(i) = UpdateModelReferenceSelectionData(BlockHandle, ParentMdlBlkHandle, inputNumber, relPaths{i}, true);
    end
  end
 ports = PortsAndBlocks;
end

parents = relPaths;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ports] =  removeStateFlowPorts(ports)

blocks = get_param(ports, 'Parent');   % blocks
parents = get_param(blocks, 'Parent'); % parents(i.e subsystem chart) 
if ~iscell(parents)
  parents = {parents};
end

sfBlks = [];
for i=1:length(parents)
  if( strcmp(get_param(parents{i},'type'),'block'))
    if(strcmp(determineBlockType(parents{i}),'Stateflow'))
      sfBlks = [sfBlks i]; 
    end  
  end
end
if(~isempty(sfBlks))
  ports(sfBlks) = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ports, PortsAndBlocks, cascadeModelRef] = getPortsAndBlocksForCurrentSystem(args, ports ,...
                                                       PortsAndBlocks, BlockHandle, cascadeModelRef, depthIdx)
% Appends ports and block handles for ModelRef block and Stateflows blocks 
% to the 'ports' array and 'PortsAndBlocks' array

 if(strcmp(get_param(args{1},'Type'),'block'))    
   blkType = determineBlockType(args{1})
   switch blkType
    case 'ModelReference'
     [ports, PortsAndBlocks] = AppendPortsForModelRefBlock(args, ports,...
                                                       PortsAndBlocks, BlockHandle)
     if(i_IsObjectInsideModelRef(BlockHandle, args{1}))
       % This is a cascade Model Reference block
       cascadeModelRef = 1;
     end       
   end  
 end
 
  if(isempty(PortsAndBlocks))
    PortsAndBlocks = ports;
  end
    
  if (args{depthIdx} == 1)
    % Don't dive inside of model ref blocks
    return
  end
  
  portParents = strrep(get_param(ports, 'Parent'), sprintf('\n'), ' ');     
  modelRefBlkHandles = [];
  mdlRefBlockPorts = []; 
  if(~isempty(portParents))
    if ~iscell(portParents)
      portParents = {portParents};
    end
  end
  for(i=1:length(portParents))
    blkType = determineBlockType(portParents{i});
    switch blkType
     case 'ModelReference'
       modelRefBlkHandles  = get_param(portParents{i},'Handle');
       modelRefName = get_param(portParents{i},'ModelName');
       try        
         load_system(modelRefName);
       catch
         error(['Model: ''' modelRefName ''' not found'])
       end          
       modelRefHandle = get_param(modelRefName,'Handle');
       mdlRefBlockPortsTmp =   find_system(modelRefName, 'FindAll', 'on',...
                                                          'SearchDepth', args{depthIdx},...
                                                          'Testpoint', 'on');      
       if iscell(mdlRefBlockPorts)
         mdlRefBlockPorts = [mdlRefBlockPorts{:}]';
       end      
       mdlRefBlockPorts = [mdlRefBlockPorts ; mdlRefBlockPortsTmp]
       mdlRefBlockPorts = unique(mdlRefBlockPorts);
       if(~isempty(ports) && ~any(ismember(ports,mdlRefBlockPorts)))
         PortsAndBlocks(end:end+length(mdlRefBlockPorts)) = modelRefBlkHandles;
         ports = [ports ; mdlRefBlockPorts];       
       end         
    end      
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ports, PortsAndBlocks] = AppendPortsForModelRefBlock(args, ports, PortsAndBlocks, BlockHandle)
% Appends ports and block handles for ModelRef block
   
modelRefName = get_param(args{1},'ModelName');
mrefPorts = [];     
try
  modelRefHandle = get_param(modelRefName,'Handle');
catch
  error(['Model: ''' modelRefName ''' not found'])
end
mrefPorts =  find_system(modelRefName, 'FindAll', 'on', 'SearchDepth', 1,...
                         'Testpoint', 'on');     
args{9} = 'TestPointed';   
if(~isempty(mrefPorts))    
  for i=1:length(mrefPorts)
    m_refHandles(i) =  args{1};
  end         
end

if(i_IsObjectInsideModelRef(BlockHandle, args{1}))
  % This is a cascade Model Reference block
  cascadeModelRef = 1;
end

if(~isempty(mrefPorts))
  PortsAndBlocks = [ports ; m_refHandles'];
  ports = [ports ; mrefPorts];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = i_LinkedToSignalAndScopeMgr(block),
  out = ~strcmp(get_param(block,'IOType'),'none');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = i_IsObjectInsideModelRef(ScopeBlock, SubSystemBlock)

 scopeRootName   = get_param(bdroot(ScopeBlock),'Name');
 subsysRootName  = get_param(bdroot(SubSystemBlock),'Name');

 out = ~strcmp(scopeRootName, subsysRootName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blkType = determineBlockType(blkHandle)

blkType  = get_param(blkHandle,'BlockType');
maskType = get_param(blkHandle,'MaskType');

if(strcmp(blkType,'SubSystem') && strcmp(maskType,'Stateflow'))
  blkType = maskType;
end
% end of determineBlockType
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%end of signalselector 
