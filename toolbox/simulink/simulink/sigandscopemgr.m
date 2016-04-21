function varargout = sigandscopemgr(varargin)

% Store the Model handles and their corresponding IO Signal managers

%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $
%   Sanjai Singh

persistent DIALOG_USERDATA

persistent HILITE_DATA

% Lock this file now to prevent user tampering
mlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error(nargchk(1, Inf, nargin));

% Determine what the action is
Action = varargin{1};
args   = varargin(2:end);

switch (Action)
  case 'Create'
    ModelHandle   = get_param(args{1}, 'Handle');
    dialog_exists = 0;
  
    % Check if dialog already created
    if ~isempty(DIALOG_USERDATA)
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
      if ~isempty(idx)
        PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
        dialog_exists = 1;
      end
    end

    % Create IO manager and store it
    if (dialog_exists == 0)
      [ModelHandle PanelHandle] = CreateSigAndScopeMgr(args{:});
      DIALOG_USERDATA(end+1).ModelHandle = ModelHandle;
      DIALOG_USERDATA(end).PanelHandle   = PanelHandle;
    end
    
    % Update simulation status
    isSimulating = ~strcmp(get_param(bdroot(ModelHandle), 'SimulationStatus'), 'stopped');
    PanelHandle.setIsSimulating(isSimulating);

    % Make it visible
    frame = PanelHandle.getParent;
    frame.show;

  case {'AddObject'}
    ModelHandle = args{1};
    ioType      = args{2};

    % Add io object
    try
      fullpath = char(ioType.getFullpath);
      load_system(strtok(fullpath, '/'))
      mdlName = get_param(ModelHandle, 'Name');
      % If block, get fullname
      if strcmp(get_param(ModelHandle, 'type'), 'block')
        mdlName = getfullname(ModelHandle);
      end
      ioTypeName = get_param(fullpath, 'Name');
      newName = [ioTypeName, '1'];
      object = add_block(fullpath, [mdlName '/' newName], 'MakeNameUnique', 'on');

      numPorts = i_GetNumPorts(object);
      varargout{1} = com.mathworks.toolbox.simulink.iomanager.IOObject(ioType, ...
        get_param(object, 'Name'), ...
        get_param(object, 'Handle'), numPorts, ... 
        i_GetNumPortsChangeable(object), ioType.isGenerator);
    catch
      errordlg(lasterr, 'Error', 'modal');
    end

  case 'DeleteObject'
    BlockHandle = args{1};
    signalselector('Delete', BlockHandle);
    delete_block(BlockHandle);

  case 'SelectObject'
    BlockHandle = get_param(args{1}, 'Handle');
    ModelHandle = get_param(bdroot(BlockHandle), 'Handle');
    % Check if dialog exists
    if ~isempty(DIALOG_USERDATA)
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
      if ~isempty(idx)
        PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
        PanelHandle.showObject(BlockHandle);
      end
    end
    
  case {'Delete', 'Cancel', 'Close'}
    ModelHandle   = args{1};

    % Check if dialog exists
    if ~isempty(DIALOG_USERDATA)
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
      if ~isempty(idx)
        PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
        if(~ishandle(ModelHandle)) 
          % Destroy client objects(i.e SignalSelector)
          PanelHandle.doDestroyObject();
        end
        frame = PanelHandle.getParent;
        frame.dispose;
        DIALOG_USERDATA(idx) = [];
      end
    end

    % Unhilite last selection
    i_Unhilite(HILITE_DATA)
        
  case 'Help'
    slprophelp('sigandscopemgr')
    
  case 'Hilight'
    % Unhilite last selection
    i_Unhilite(HILITE_DATA)
    
    % Hilite and cache port
    PortHandle   = args{1};
    HILITE_DATA.lastHilited = PortHandle;
    blk                     = get_param(PortHandle, 'Parent');
    HILITE_DATA.lastBlock   = blk;
    
    try
      hilite_system(PortHandle, 'find');
    end
    try
      hilite_system(blk, 'find');
    end
    
  case 'SigPropDialog'
    portH = args{1};
    blkHandle = args{2};
    if feature('SignalLogging')
      if(ishandle(blkHandle))
          ports = get_param(blkHandle,'PortHandles')
          try
            portH = ports.Outport(1);
          end
      end
      set_param(portH,'OpenSigPropDialog','on')
    else
      spdialog('Open', portH);
    end
    
  case 'GetLibraries'
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = i_GetSignalLibraries;

  case 'GetGeneratorLibraries'
    [varargout{1}, varargout{2}, vlibNames, vlibs] = i_GetSignalLibraries;
  
  case 'GetViewerLibraries'
    [glibNames, glibs, varargout{1}, varargout{2}] = i_GetSignalLibraries;
  
  case 'GetLibraryBlocks'
    [varargout{1}, varargout{2}] = LoadLibData(args{1});
    
  case 'GetSigAndScopeMgr'
    ModelHandle = args{1};
    idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
    else
      PanelHandle = [];
    end
    varargout{1} = PanelHandle;

  case 'GetViewers'
    ModelHandle = args{1};
    varargout{1} = i_GetViewers(ModelHandle);

  case 'GetGenerators'
    ModelHandle = args{1};
    varargout{1} = i_GetGenerators(ModelHandle);

  case 'GetNumPorts'
    % used by signal selector
    BlockHandle = args{1};
    varargout{1} = i_GetNumPorts(BlockHandle);

  case 'GetSelectionData'
    BlockHandle = args{1};
    varargout{1} = i_GetNumPorts(BlockHandle);
    [varargout{2} varargout{3}] = i_GetSelections(BlockHandle);

  case 'UpdateSelections'
    BlockHandle = args{1};
    ModelHandle = get_param(get_param(BlockHandle, 'Parent'), 'Handle');
    idx         = [];
    
    if ~isempty(DIALOG_USERDATA),
      idx = find([DIALOG_USERDATA.ModelHandle] == ModelHandle);
    end
    
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
      PanelHandle.updateCurrentSelection;
    end

  case 'PopulateObjects'
    [varargout{1}, varargout{2}] = i_PopulateObjects(args{1});
    
  case 'RenameObject'
    BlockHandle = args{1};
    NewName     = args{2};
    nextName    = i_RenameObject(BlockHandle, NewName);
    signalselector('UpdateName', BlockHandle, nextName);
    varargout{1} = nextName;

  case 'ChangeNumPorts'
    BlockHandle = args{1};
    number      = args{2};
    newNumber   = i_ChangeNumPorts(BlockHandle, number);
    varargout{1} = i_GetNumPorts(BlockHandle);
    [varargout{2} varargout{3}] = i_GetSelections(BlockHandle);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Add default implementation for SignalSelector API %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  case 'GetSelection'
    BlockHandle  = args{1};
    InputNumber  = args{2};
    vs = get_param(BlockHandle, 'IOSignals');
    varargout{1} = [vs{InputNumber}.Handle];

  case 'AddSelection'
    BlockHandle  = args{1};
    InputNumber  = args{2};
    addSel       = args{3};
    % Can be multiple selections
    addCell = cell(1, length(addSel));
    for k = 1:length(addSel)
      addCell{k} = addSel(k);
    end
    vs = get_param(BlockHandle, 'IOSignals');
    if ~isempty(vs)
      %
      % When setting a handle on a multi-output port signal generator, make
      % sure none of the other output ports are driving the same signal.
      %
      nPorts = length(vs);
      ioType = get_param(BlockHandle,'IOType');
      siggen = strcmpi(ioType, 'siggen');
      if siggen & nPorts > 1
        for i=1:nPorts,
          if i==InputNumber,
            continue;
          end
          ports = vs{i};
          ports = ports(find([ports.Handle] ~= addSel));
          if isempty(ports)
            ports = struct('Handle',-1,'RelativePath','');
          end
          vs{i} = ports;
        end
      end

      currPorts = vs{InputNumber};
      currPorts = [currPorts(:)' struct('Handle', addCell, 'RelativePath', '')];
      currPorts = currPorts(find([currPorts.Handle] ~= -1));

      % The particular port of the signal generator must be always
      % providing input to a unique set of ports, so check for uniqueness
      if (siggen)
        [unused uniqueIdx] = unique([currPorts.Handle]);
        currPorts = currPorts(uniqueIdx);
      end
      
      vs{InputNumber} = currPorts;
    else
      error('M Assert: unexpected empty return of IOSignals');
      vs{InputNumber} = struct('Handle', addCell, 'RelativePath', '');
    end
    i_SetIOParam(BlockHandle, vs);

  case 'RemoveSelection'
    BlockHandle  = args{1};
    InputNumber  = args{2};
    remSel       = args{3};
    vs = get_param(BlockHandle, 'IOSignals');
    currPorts = vs{InputNumber};
    idx = [];
    allH = [currPorts.Handle];
    for k = 1:length(remSel)
      idx = [idx, find(allH == remSel(k))];
    end
    currPorts(idx) = [];
    if isempty(currPorts)
      currPorts = struct('Handle',-1,'RelativePath','');
    end
    vs{InputNumber} = currPorts;
    i_SetIOParam(BlockHandle, vs);

  case 'SwitchSelection'
    BlockHandle = args{1};
    InputNumber = args{2};
    oldSel      = args{3};
    newSel      = args{4};

    vs = get_param(BlockHandle, 'IOSignals');
    vs{InputNumber} = struct('Handle',newSel,'RelativePath','');
    i_SetIOParam(BlockHandle, vs);
    
 case 'UpdateCache',
  bd = args{1};
  UpdateCache(bd);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H, panel] = CreateSigAndScopeMgr(varargin)

model = varargin{1};
name  = get_param(model, 'Name');
% If block, get fullname
if strcmp(get_param(model, 'type'), 'block')
  name = strrep(getfullname(model), sprintf('\n'), ' ');
end
H = get_param(model, 'Handle');

% Call constructor
panel = com.mathworks.toolbox.simulink.iomanager.IOManager.CreateIOManager(name);
frame = panel.getParent;

% Set the right location
location   = get_param(H, 'Location');
screenSize = get(0,'ScreenSize');

dims   = frame.getBounds;
width  = dims.width; 
height = dims.height;

xLoc = min(location(1) + width + 50, screenSize(3)) - width;
yLoc = min(location(2) + height + 50, screenSize(4)) - height;
frame.setLocation(max(xLoc, 0), max(yLoc, 0));
  
% Store block handle
panel.setModelHandle(H);

% Now populate viewer types
i_PopulateTypes(panel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [generators, viewers] = i_PopulateObjects(H)

% Get existing generators
generators = i_GetGenerators(H);

% Get existing viewers
viewers = i_GetViewers(H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function viewers = i_GetViewers(model)

viewers = {};

%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
% Beginning of instrumented region ...
% This region of code is instrumented to trap invalid model handles
% being passed to 'i_GetViewers'.  There are two gecked instances:
% G206696: model handle == -1
% G206701: stale model handle is 'Invalid Simulink object specifier'
% When these two gecks are both being closed, the instrumentation
% should be removed and only the call to 'find_system' should remain
% See Tom Weis if this is unclear.
%
msg = '';
lasterr('');
try

if isequal(model,-1)
  others = [];
else
  others = find_system(model, 'AllBlocks', 'on', 'SearchDepth', 1, ...
                              'IOType', 'viewer');
end

catch
    msg = lasterr;
end
if ~isequal(msg,'')
  trapMsg=['Error using ==> find_system',sprintf('\n'), ...
           'Invalid Simulink object specifier.']
  if isequal(msg,trapMsg)
    lasterr('');
    others = [];
  end
end
% ... End of instrumented region
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

for i=1:length(others)
  ioviewer = others(i);
  btype = get_param(ioviewer,'BlockType');
  
  floatingScope = false;
  if strcmp(btype,'Scope') && onoff(get_param(ioviewer,'Floating')),
    floatingScope = true;
  end
  
  signalviewerscope = strcmp(get_param(ioviewer, 'BlockType'), 'SignalViewerScope');
  
  ioType            = i_GetIOType(ioviewer);
  viewerType        = com.mathworks.toolbox.simulink.iomanager.IOType.findIOType(ioType);
  
  if floatingScope || signalviewerscope
    numInputs = str2num(get_param(ioviewer, 'NumInputPorts'));
  else
    numInputs = get_param(ioviewer, 'Ports');
    numInputs = numInputs(1);
  end

  viewers{i} = com.mathworks.toolbox.simulink.iomanager.IOObject(viewerType, ...
                  strrep(get_param(ioviewer, 'Name'), sprintf('\n'), ' '), ...
                  get_param(ioviewer, 'Handle'), numInputs, ...
                  i_GetNumPortsChangeable(ioviewer), 0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function generators = i_GetGenerators(model)

generators = {};

%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-
% Beginning of instrumented region ...
% This region of code is instrumented to trap invalid model handles
% being passed to 'i_GetGenerators'.  There are two gecked instances:
% G206696: model handle == -1
% G206701: stale model handle is 'Invalid Simulink object specifier'
% When these two gecks are both being closed, the instrumentation
% should be removed and only the call to 'find_system' should remain
% See Tom Weis if this is unclear.
%

msg = '';
lasterr('');
try
  if isequal(model,-1)
    gens = [];
  else
    gens = find_system(model, 'AllBlocks', 'on', 'SearchDepth', 1, ...
                              'IOType', 'siggen');
  end
catch
  msg = lasterr;
end
if ~isequal(msg,'')
  trapMsg=['Error using ==> find_system',sprintf('\n'), ...
           'Invalid Simulink object specifier.']
  if isequal(msg,trapMsg)
    lasterr('');
    gens = [];
  end
end
% ... End of instrumented region
%+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-

for i = 1:length(gens)
  ioType     = i_GetIOType(gens(i));
  genType    = com.mathworks.toolbox.simulink.iomanager.IOType.findIOType(ioType);
  portCounts = get_param(gens(i), 'Ports');
  generators{end+1} = com.mathworks.toolbox.simulink.iomanager.IOObject(genType, ...
                        strrep(get_param(gens(i), 'Name'), sprintf('\n'), ' '), ...
                        get_param(gens(i), 'Handle'), portCounts(2), ...
                        i_GetNumPortsChangeable(gens(i)), 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ioType = i_GetIOType(object)

% First try MaskType
ioType = get_param(object, 'MaskType');

% Then try BlockType
if isempty(ioType)
  ioType = get_param(object, 'BlockType');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function numPorts = i_GetNumPorts(object)
  
  portCounts = get_param(object, 'Ports');
  numPorts   = 0;
  blockType  = get_param(object, 'BlockType');
  if strcmp(blockType, 'SignalViewerScope') || ...
     (strcmp(blockType, 'Scope') && onoff(get_param(object,'Floating'))), 
    numPorts = str2num(get_param(object, 'NumInputPorts'));
  elseif strcmp(get_param(object, 'IOType'), 'viewer')
    numPorts = portCounts(1);
  elseif strcmp(get_param(object, 'IOType'), 'siggen')
    numPorts = portCounts(2);
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function canChange = i_GetNumPortsChangeable(object)

% Can this block change its number of ports
  blockType = get_param(object,'BlockType');
  floatingScope = false;
  if strcmp(blockType,'Scope') && onoff(get_param(object,'Floating')),
    floatingScope = true;
  end

  canChange = floatingScope | strcmp(blockType,'SignalViewerScope');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = i_GetHandleIdStr(sigs)

for i = 1:length(sigs)
  handle  = sigs(i).Handle;
  relPath = sigs(i).RelativePath;
  if isempty(relPath)
    str{i} = get_param(sigs(i).Handle, 'Name');
    if isempty(str{i})
      block    = get_param(handle,'parent');
      portNum  = get_param(handle,'PortNumber');
      fullpath = strrep(getfullname(block), sprintf('\n'), ' ');

      % strip model name
      fullpath = fullpath(findstr(fullpath,'/')+1:length(fullpath));

      str{i}   = [fullpath ':' num2str(portNum)];
    else
      str{i}   = strrep(str{i}, sprintf('\n'), ' ');
    end
  else
    fullpath  = getfullname(handle);
    
    % strip model name
    fullpath = fullpath(findstr(fullpath,'/')+1:length(fullpath));

    relPath = strrep(relPath, ':o', ':');  
    relPath = strrep(relPath, ':i', ':');  
    
    % strip submodel/chart name
    relPath = relPath(findstr(relPath,'/')+1:length(relPath));

    str{i}  = strrep([fullpath '/' relPath], sprintf('\n'), ' ');
  end
  
  str{i} = private_sl_enc2normalpath(str{i});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [selections sigs] = i_GetSelections(block)

sigs       = get_param(block, 'IOSignals');
selections = {};

for i = 1:length(sigs),
  if ([sigs{i}.Handle] > 0)
    selections{i} = i_GetHandleIdStr(sigs{i});
  else
    selections{i} = 'no selection';
  end
  sigs{i} = [sigs{i}.Handle];
  if(isempty(sigs{i}))
    sigs{i} = -1;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nextName = i_RenameObject(BlockHandle, NewName)

model = get_param(BlockHandle, 'Parent');
found = 1; num = 0; nextName = NewName;
throwError = 0;

while (found) & ~isequal(model,-1)
  found = ~isempty(find_system(model, 'AllBlocks', 'on', ...
                                      'SearchDepth', 1, 'Name', nextName));
  if (found)
    throwError = 1;
    num        = num + 1;
    nextName   = [NewName num2str(num)];
  end
end

if (throwError)
  text = ['Could not rename viewer to ''' NewName ''' since another ' sprintf('\n') ...
          'Simulink object has the same name. Renaming it to ''' nextName '''.'];
  errordlg(text, 'Rename error', 'modal')
end

set_param(BlockHandle, 'Name', nextName)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newNumber = i_ChangeNumPorts(BlockHandle, number)

newNumber = number;

% Handle Floating scope and SignalViewerScope now
blockType = get_param(BlockHandle,'BlockType');
floatingScope = false;
if strcmp(blockType,'Scope') && onoff(get_param(BlockHandle,'Floating')),
  floatingScope = true;
end

if floatingScope || strcmp(blockType,'SignalViewerScope'),
  if strcmp(get_param(BlockHandle','BlockType'),'SignalViewerScope'),
    simscopesv('SetNewNumPorts', BlockHandle, number);
  else
    simscope('SetNewNumPorts', BlockHandle, number);
  end
    
  newNumber = get_param(BlockHandle, 'NumInputPorts');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% REGISTRATION SUPPORT FOR IO TYPES AS DEFINED IN SLBLOCKS.M %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desc = i_GetDescription(block)

if strcmp(get_param(block, 'Mask'), 'on')
  desc = get_param(block, 'MaskDescription');
else
  desc = get_param(block, 'BlockDescription');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function icon = i_GetIconFile(block)

icon = '';
if (strcmp(get_param(block, 'BlockType'), 'SignalViewerScope'))
  icon = '/com/mathworks/toolbox/simulink/iomanager/resources/scope.gif';
else
  try
    icon = get_param(block, 'IORegIconDisplay');
  catch
    lasterr('');
  end
end

if isempty(icon) || ~strncmp(icon, '/com', 4)
  icon = '/com/mathworks/toolbox/simulink/iomanager/resources/block.gif'; %default
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mode = i_GetSelectionMode(block)

mode = '';
try
  mode = get_param(block, 'IORegSelectionMode');
catch
  lasterr('');
end
if ~(strcmp(mode, 'single') || strcmp(mode, 'multiple'))
  if strcmp(get_param(block, 'IOType'), 'viewer'),
    blockType     = get_param(block,'BlockType');  
    
    floatingScope = false;
    if strcmp(blockType,'Scope') && onoff(get_param(block,'Floating')),
      floatingScope = true;
    end
    
    if floatingScope,
      mode = 'multiple';
    else
      mode = 'single'; %default
    end
  else
    mode = 'multiple';
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prefix = i_GetPortPrefix(block)

prefix = '';
try
  prefix = get_param(block, 'IORegPortPrefix');
catch
  lasterr('');
end

if isempty(prefix)
  ioType = get_param(block,'IOType');
  
  if strcmp(ioType,'viewer'),
    blockType = get_param(block,'BlockType');  
    floatingScope = false;
    if strcmp(blockType,'Scope') && onoff(get_param(block,'Floating')),
      floatingScope = true;
    end
    
    if floatingScope || strcmp(blockType,'SignalViewerScope'),
      prefix = 'Axes';
    else
      prefix = 'Input';
    end
  else
    prefix = 'Output';
  end
end
%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mfile = i_GetCallbackMFile(block)

mfile = '';
try
  mfile = get_param(block, 'IORegCallbackMFile');
catch
  lasterr('');
end

if isempty(mfile)
  blockType     = get_param(block,'BlockType');  
  floatingScope = false;
  if strcmp(blockType,'Scope') && onoff(get_param(block,'Floating')),
    floatingScope = true;
  end
  
  mfile = 'sigandscopemgr'; %default
  if floatingScope,
    mfile = 'simscope';
  elseif (strcmp(get_param(block, 'BlockType'), 'SignalViewerScope'))
    mfile = 'simscopesv';
  end
end
%endfunction  
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_SetIOParam(block, data)
% This catches errors and shows them on a dialog

errState = lasterr;
lasterr('');

try
  set_param(block, 'IOSignals', data)
end

if ~isempty(lasterr)
  errordlg(lasterr);
end

lasterr(errState);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [glibNames, glibs, vlibNames, vlibs] = i_GetSignalLibraries

  if 0,
    all_slblocks = which('-all','slblocks.m');
    glibNames = {}; glibs = {};
    vlibNames = {}; vlibs = {};
    
    % Process all slblocks to get all the libraries
    for i = 1:length(all_slblocks)
      fid  = fopen(all_slblocks{i}, 'r');
      file = fread(fid, '*char')';
      fclose(fid);
      idx = findstr(file, 'slblocks');
      if (idx)
        file(1:(idx(1)+8)) = [];
      end
      clear('blkStruct', 'Generator')
      clear('blkStruct', 'Viewer')
      
      try
        eval(file)
        currentInfo = blkStruct;
 
        if isfield(currentInfo, 'Generator')
          glibNames = [glibNames ; {currentInfo.Generator.Name   }'];
          glibs     = [glibs     ; {currentInfo.Generator.Library}'];
        end
        
        if isfield(currentInfo, 'Viewer')
          vlibNames = [vlibNames ; {currentInfo.Viewer.Name   }'];
          vlibs     = [vlibs     ; {currentInfo.Viewer.Library}'];
        end
      end
    end
    
    % Make the list of libraries unique
    [glibNames idx] = unique(glibNames); glibs = glibs(idx);
    [vlibNames idx] = unique(vlibNames); vlibs = vlibs(idx);
    
    % Set Simulink to be the first Generator library
    simulinkIdx = find(strcmpi(glibNames, 'simulink'));
    if ~isempty(simulinkIdx)
      newOrder  = [simulinkIdx 1:simulinkIdx-1 simulinkIdx+1:length(glibs)];
      glibNames = glibNames(newOrder);
      glibs     = glibs(newOrder);
    end
    
    % Set Simulink to be the first Viewer library
    simulinkIdx = find(strcmpi(vlibNames, 'simulink'));
    if ~isempty(simulinkIdx)
      newOrder  = [simulinkIdx 1:simulinkIdx-1 simulinkIdx+1:length(vlibs)];
      vlibNames = vlibNames(newOrder);
      vlibs     = vlibs(newOrder);
    end
  else,
    dspPath = fullfile(matlabroot,'toolbox','dspblks' ,'dspblks', 'slblocks.m');
    commPath= fullfile(matlabroot,'toolbox','commblks','commblks','slblocks.m');
    
    dspExists  = exist(dspPath, 'file') ~= 0;
    commExists = exist(commPath,'file') ~= 0;
    
    glibNames{1} = 'Simulink';
    glibs{1}     = 'simgens';
    
    vlibNames{1} = 'Simulink';
    vlibs{1}     = 'simviewers';
    
    if commExists,
      glibNames{end+1} = 'Communications';
      glibs{end+1}     = 'commgen2';
      
      vlibNames{end+1} = 'Communications';
      vlibs{end+1}     = 'commviewers2';
    end
    
    if dspExists,
      glibNames{end+1} = 'Signal Processing';
      glibs{end+1}     = 'dspgenerators';
      
      vlibNames{end+1} = 'Signal Processing';
      vlibs{end+1}     = 'dspviewers';
    end
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function count = i_ProcessBlocks(fTypeTree, parentID, blocksTree, blockNames, count, isGenerator)
% Passing around
% blocksTree - part of the tree we are updating
% blockNames - whole thing
% count      - index into blockNames

import com.mathworks.mwt.*;
import com.mathworks.mwt.table.LabeledImageResource;
import com.mathworks.toolbox.simulink.iomanager.*;

fIcon  = '/com/mathworks/toolbox/simulink/iomanager/resources/Subsystem.gif';

% Are we at leaf nodes?
leaf = ischar(blocksTree{1});

if leaf
  for idx = 1:length(blocksTree)
    count = count + 1;
    block = blockNames{count};
    vt = IOType(i_GetIOType(block), ...
                blocksTree{idx}, ...
                block, ...
                i_GetCallbackMFile(block), ...
                i_GetDescription(block), ...
                i_GetIconFile(block), ...
                i_GetSelectionMode(block), ...
                i_GetPortPrefix(block), ...
                isGenerator);
                        
    fTypeTree.addItem(parentID, {vt.getIcon, vt}, 0);
  end
else
  % Add a node for each sublevel and recurse
  for k = 1:length(blocksTree)
    % We add a subnode
    count = count + 1;
    node  = LabeledImageResource(fIcon, blocksTree{k}{1});
    subID = fTypeTree.addItem(parentID, node, 1);

    % Now recurse
    count = i_ProcessBlocks(fTypeTree, subID, blocksTree{k}{2}, blockNames, count, isGenerator);
  end
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_PopulateTypes(panel)

import com.mathworks.mwt.*;
import com.mathworks.mwt.table.LabeledImageResource;
import com.mathworks.toolbox.simulink.iomanager.*;

fModelIcon = '/com/mathworks/toolbox/simulink/iomanager/resources/modelclosed.gif';
fTypeTree  = panel.getTypeTree;

% Steps
% 1) Go through all slblocks.m to get viewer and generator libraries
[glibNames, glibs, vlibNames, vlibs] = i_GetSignalLibraries;

% 2) Build Generator tree based on parsing those libraries
node = LabeledImageResource('foo.gif', 'Generators');
GeneratorID = fTypeTree.addItem(-1, node, 1);
for i = 1:length(glibs)
  % Add top level node
  node = LabeledImageResource(fModelIcon, glibNames{i});
  pID  = fTypeTree.addItem(GeneratorID, node, 1);

  % Add individual generators
  [blocksTree, blockNames] = LoadLibData(glibs{i},true);

  % Prune out top node since we have that info already
  blocksTree = blocksTree{1}{2};
  blockNames = blockNames(2:end);
    
  % Process all the blocks we found
  count = 0;
  count = i_ProcessBlocks(fTypeTree, pID, blocksTree, blockNames, count, 1);
end
fTypeTree.getTreeData.expandItem(GeneratorID);

% 3) Build Viewer tree based on parsing those libraries
node = LabeledImageResource('foo.gif', 'Viewers');
ViewerID = fTypeTree.addItem(-1, node, 1);
for i = 1:length(vlibs)
  % Add top level node
  node = LabeledImageResource(fModelIcon, vlibNames{i});
  pID  = fTypeTree.addItem(ViewerID, node, 1);

  % Add individual viewers
  [blocksTree, blockNames] = LoadLibData(vlibs{i},true);

  % Prune out top node since we have that info already
  blocksTree = blocksTree{1}{2};
  blockNames = blockNames(2:end);
    
  % Process all the blocks we found
  count = 0;
  count = i_ProcessBlocks(fTypeTree, pID, blocksTree, blockNames, count, 0);
end
fTypeTree.getTreeData.expandItem(ViewerID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_Unhilite(data)

if ~isempty(data)
  try
    hilite_system(data.lastHilited, 'none');
  end
  
  try
    hilite_system(data.lastBlock, 'none');
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use the cache, unless it doesn't exist or the model is dirty.
%
function cache = GetCache(lib),
  cache = []; %assume
  
  libH  =  find_system(0,'SearchDepth',0,'Name',lib);
  
  if isempty(libH),
    %
    % Load the lib.  Supress warning as per legacy in libbrowse.m.
    %
    try,
      defwarn = warning;
      warning('off');
      load_system(lib);
    end
    warning(defwarn) 
    
    %
    % Grab the bd handle.  It should be there now.
    %
    libH  =  find_system(0,'SearchDepth',0,'Name',lib);
    if isempty(libH),
      error(['Library ''' lib ''' not found']);
    end
  end
  
  %
  % Return early if the model is dirty.  Cache is out of date.
  %
  dirty = onoff(get_param(libH,'dirty'));
  if dirty, return; end
  
  %
  % Grab the cache, if it exists.
  %
  ws = get_param(libH,'ModelWorkSpace');
  if isempty(ws), return; end
  
  try,
    cache = evalin(ws,'libCache');
  end
   
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the lib info.  Use the cache if possible.
%
function [blocksTree,blockNames] = LoadLibData(lib,forceLoad),
  
  if nargin < 2,
    forceLoad = false;
  end
  
  if ~forceLoad,
    cache = GetCache(lib);
    
    if ~isempty(cache),
      blocksTree = cache.blocksTree;
      blockNames = cache.blockNames;
    else,
      [blocksTree, blockNames] = libbrowse('load', lib);
    end
  else,
    [blocksTree, blockNames] = libbrowse('load', lib);
  end
  
%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the lib info cache (meant to be called from the model presave
% callback).
%
function UpdateCache(lib),

  % 
  % Get the updated cache info.
  %
  [blocksTree, blockNames] = libbrowse('load', lib);
  
  libCache.blocksTree = blocksTree;
  libCache.blockNames = blockNames;
  
  %
  % Set it in the cache.
  %
  ws=get_param(lib,'ModelWorkSpace');
  if isempty(ws),
    warning('Error updating cache.  Model workspace unavailable.');
  end
  
  assignin(ws,'libCache',libCache);
  
%endfunction
