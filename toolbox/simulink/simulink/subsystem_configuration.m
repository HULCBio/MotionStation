function subsystem_configuration(Action,varargin)
%SUBSYSTEM_CONFIGURATION  Sets up and manages configurable subsystems.
%   This function is used to manage the Configurable Subsystem block 
%   behavior in Simulink.  It can be called with one of five
%   (string) arguments.
%
%   subsystem_configuration new
%   ===========================
%   The current block (gcb) is designated as the "shell" 
%   which will represent any of the blocks in a library. 
%   A GUI prompts the user for the name of the library.  This
%   is the default action if the function is called without
%   an input argument.
%
%   subsystem_configuration establish
%   =================================
%   At this stage, the mask for the shell is filled with 
%   the library block names and parameters.  A reference
%   block which resides underneath the mask is established 
%   and connected to inports and outports which represent
%   a superset of all the inputs and outputs of the various
%   library selections available.  The default identity of 
%   the block is the first in the list.  Normally the GUI
%   figure window is deleted at this stage.  If a second
%   argument of 'apply' is used, the GUI remains open.  
%   That is: subsystem_configuration('establish','apply')
%
%   subsystem_configuration reestablish
%   ===================================
%   A new library name has been entered into the mask variable
%   LibraryName, so the present contents are discarded and a new
%   configuration is established.  A second argument is used to
%   indicate the configuration block to which this applies, i.e., 
%   subsystem_configuration('reestablish', ConfigBlock).  The 
%   default is gcb.  
%
%   subsystem_configuration update
%   ==============================
%   This is called when the user changes the configuration.
%   The identity of the underlying reference changes and any
%   necessary reconnections of inputs and outputs is performed.
%   A second argument is used to indicate the configuration block 
%   to which this applies (the default is gcb), i.e., 
%   subsystem_configuration('update', ConfigBlock).
%
%   The last two functions may also be accessed from the command 
%   line via set_param to 'LibraryName' or 'Choice'.  That is, to change 
%   the library (reestablish):
%       set_param(configblk, 'LibraryName', 'newLib')
%   or to change the current block choice (update):
%       set_param(configblk, 'Choice', 'newchoice')
%
%   subsystem_configuration copy
%   ===================================
%   This function is called when the user copies a configurable
%   subsystem block. It breaks the link with the parent block
%   and deletes the Empty Subsystem that is included for the 
%   block to show up in the Simulink Library Browser.
%  
%
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.31 $

% The default input arguments are 'new' and gcb.
%Action
%if nargin>1,
%  varargin
%end

if nargin < 1
  Action = 'new';
end
if nargin < 2
  varargin{1} = gcb;
end

curFig=[];
curPointerData={'arrow',ones(16,16)};
if ~isempty(gcbf),
  curFig=gcbf;
  curPointerData=get(curFig,{'Pointer','PointerShapeCData'});
  set(curFig,'Pointer','watch');
end

switch Action,
  
  case 'new'
    locOpenBlockDialog
    
  case 'establish'
    if strcmp(varargin{1}, 'apply')
      locApplyLibraryName('apply');
    else
      locApplyLibraryName('eval');
    end

  case 'initFcn',
    ConfigBlockStatus = get_param(gcb,'UserData');
    ConfigBlockStatus.allData=evalin('base','who');
    ConfigBlockStatus.Initializing=logical(1);
    
    set_param(gcb,'UserData',ConfigBlockStatus);
    
  case 'reestablish'
    % Called from mask init
    if nargin>2,
      locNewLibraryName(varargin{1},logical(1))
    else,
      locNewLibraryName(varargin{1},logical(0))
    end
    
  case 'copy'   
    locCopyConfiguration
    
  case 'update'
    locUpdateConfiguration(varargin{1})
    
    ConfigBlockStatus = get_param(varargin{1},'UserData');
    ConfigBlockStatus.Initializing=logical(0);
    set_param(varargin{1},'UserData',ConfigBlockStatus);

    
  case 'updateDialog',
    locUpdateConfiguration(varargin{1},logical(1))
    
  otherwise
    errordlg(['subsystem_configuration must be called with one of the ',...
          'following five arguments: ''new'', ''establish'', ',...
          '''reestablish'', ''copy'' or ''update'''])
end


if ishandle(curFig),
  set(curFig,{'Pointer','PointerShapeCData'},curPointerData);
end

%********************************************************************
%********************************************************************
%
function locApplyLibraryName(evalApply)
%
%  This function is called from the locOpenBlockDialog GUI to 
%  transfer the user library information to the config block.  If
%  evalApply is 'apply' the GUI is not destroyed and 
%  its figure handle is retained in status.fig.  
%
%  f = GUI figure window
%  D = data attached to figure
%    D.LibEdit = string representing library entered in GUI
%    D.ConfigBlock = configurable subsystem block
%  LibraryName = user-entered library location
%  mdlName = name of mdl file containing LibraryName
%  status = structure saved in UserData to detect future changes

f = gcbf;
D = get(f, 'Userdata');
LibraryName = get(D.LibEdit, 'string');
ConfigBlock = D.ConfigBlock;
mdlName = strtok(LibraryName, '/');

if ~isempty(mdlName) & isequal(exist(mdlName),4),
  existFlag=0;
  % we have a simulink model, load it
  feval(mdlName,[],[],[],'load')
  % and make sure that LibraryName is exists in it
  if ~strcmp(mdlName, LibraryName)
    all_sys = find_system(mdlName, 'lookundermasks', 'all');
    if isempty(find(strcmp(all_sys, LibraryName)))
      errordlg(['System ''' LibraryName ''' not found in ''' ...
            mdlName '''']);
      
    elseif length(find_system(LibraryName,'searchdepth',1,'type','block')) == 1
      % LibraryName is a single block without children
      errordlg(['System ''' LibraryName ...
            ''' is a single block, not a library']);
      
    else,
      existFlag=1;  
    end
  else
    existFlag=1;
    
  end
  
  if existFlag==1,
    
    if strcmp(evalApply,'eval'),
      close(f)
    end
    
    % at this point, we know that mdlName == LibraryName and it exists
    % proceed with setup
    status = locSetupBlockInfo(ConfigBlock, LibraryName, mdlName,logical(0)); 
    if strcmp(evalApply,'eval'),
      deleteFcn='';
    else,
      status.fig = f;
      deleteFcn='close(getfield(get_param(gcb, ''UserData''),''fig''))';
    end
    
    set_param(ConfigBlock, ...
        'UserData', status, ...
        'DeleteFcn', deleteFcn ...
        )
  end
  
else
  % otherwise, return the user to the GUI
  errordlg(['Library ''' LibraryName ''' not found on the path']); 
end

%********************************************************************
%********************************************************************
%
function str = locCell2SepStr(array, sep)
%
% convert cell array to token-separated string
%
str = '';
for i = 1:length(array)
  str = [str array{i} sep];
end
str(end) = [];


%********************************************************************
%********************************************************************
%
function sty = locConvertToMaskStyles(type, enum)
%
%  The type and enumeration fields of dialog parameter are combined
%  in the form of MaskStyles.
%
%  type = dialogparameter.Type
%  enum = dialogparameter.Enum
%  sty = MaskStyles{i}
%

sty = {};

for i = 1:length(type)

  switch type{i}
    case 'string'
      sty{i} = 'edit';
      
    case 'boolean'
      sty{i} = 'checkbox';
      
    case 'enum'
      Str = '';
      specEnum = enum{i}; 
      for j = 1:length(specEnum)
        Str = [Str specEnum{j} '|'];
      end
      Str(end) = [];
      sty{i} = ['popup(' Str ')'];
      
  end
end

%********************************************************************
%********************************************************************
%
function locCopyConfiguration
%
%  This function is executed when the CopyFcn of the block is invoked
% 
ConfigBlock = gcb;

if strcmp(get_param(ConfigBlock,'linkstatus'),'resolved')
  set_param(ConfigBlock,'linkstatus','none');
  eval('delete_block([ConfigBlock ''/EmptySubsystem''])','');
end


%********************************************************************
%********************************************************************
%
function array = locDelimitString(str, sep)
%
% convert token-separated string to cell array
%
array = {};
while ~isempty(str)
  [array{length(array)+1}, str] = strtok(str, '|');
end

%********************************************************************
%********************************************************************
%
function locEstablishInports(ConfigBlock, Parent)
%
%  Build a superset of all inport names.  If any blocks have unnamed ports,
%  insure that there enough names to cover the maximum number of inputs.
%  For any names for which ports don't exist, add them.  Delete any ports
%  that don't have corresponding names.
%
%  ConfigBlock = configurable subsystem block
%  Parent = configuration library (LibraryName)
%

% collect a list of all inport names
inportnames = unique(get_param(find_system(Parent,'lookundermasks','all',...
    'FollowLinks', 'on','searchdepth',2,'blocktype','Inport'),'name'));
Nin = length(inportnames);

% if any blocks require more inports than in inportnames, 
% append dummy names to list

% find the greatest number of inports of any block
maxportsize = locMaxPorts(Parent);   
% (dialog parameter changes may have increased the shell block's inport count)
shellports = get_param([ConfigBlock, '/shell'], 'ports');
while length(inportnames) < max(maxportsize(1), shellports(1))
  Nin = Nin + 1;
  % new names: in7, in8, etc.
  inportnames = cat(1, inportnames, {['in', num2str(Nin)]});  
end

% delete excess inports or add new ones
cb_inports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Inport');
cb_inportnames = get_param(cb_inports, 'name');

% delete useless ports
extras = setdiff(cb_inportnames, inportnames);
for i = 1:length(extras)
  delete_block(char(find_system(ConfigBlock, 'lookundermasks', 'all',...
      'searchdepth', 1, 'blocktype', 'Inport', 'name', extras{i})))
end

% position the existing ports and add new ones, as required
locPlaceAndAdd(ConfigBlock, inportnames, cb_inports, cb_inportnames, 'in')

%********************************************************************
%********************************************************************
%
function locEstablishOutports(ConfigBlock, Parent)
%
%  Build a superset of all outport names.  If any blocks have unnamed ports,
%  insure that there enough names to cover the maximum number of outputs.
%  For any names for which ports don't exist, add them.  Delete any ports
%  that don't have corresponding names.
%
%  ConfigBlock = configurable subsystem block
%  Parent = configuration library (LibraryName)
%

% collect a list of all outport names
outportnames = unique(get_param(find_system(Parent,'lookundermasks','all',...
    'FollowLinks','on','searchdepth',2,'blocktype','Outport'),'name'));

% if any blocks require more outports than in outportnames, append 
% dummy names to list

% find the greatest number of outports of any block
maxportsize = locMaxPorts(Parent);   

% (dialog parameter changes may have increased the shell block's port count)
shellports = get_param([ConfigBlock, '/shell'], 'ports');
while length(outportnames) < max(maxportsize(2), shellports(2))
  newnum = length(outportnames) + 1;
  % new names: out7, out8, etc.
  outportnames{newnum} = ['out', num2str(newnum)];  
end

% delete excess outports or add new ones
cb_outports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Outport');
cb_outportnames = get_param(cb_outports, 'name');

% delete useless ports
extras = setdiff(cb_outportnames, outportnames);
for i = 1:length(extras)
  delete_block(char(find_system(ConfigBlock, 'lookundermasks', 'all',...
      'searchdepth', 1, 'blocktype', 'Outport', 'name', extras{i})))
end

% position the existing ports and add new ones, as required
locPlaceAndAdd(ConfigBlock, outportnames, cb_outports, cb_outportnames, 'out')

%********************************************************************
%
function maxportsize = locMaxPorts(Parent)
%
%  This function looks at the blocks in Parent and determines what the
%  greatest number of each type of ports is.
%
%  Parent = system under which the blocks to be examined lie.  
%  maxportsize = vector of max sizes: [in out enable trigger state]
%

% get all the blocks
blocks = find_system(Parent,...
    'lookundermasks', 'all',...
    'FollowLinks', 'on',...
    'searchdepth', 1,...
    'type', 'block');

% eliminate Parent from list
if strcmp(Parent, blocks(1))
  blocks(1) = []; 
end

% get the port counts and find the max
ports = get_param(blocks, 'ports');
ports = cat(1, ports{:});
maxportsize = max(ports, [], 1);
%********************************************************************
%********************************************************************
%
function locNewBlockChoice(ConfigBlock, BlockChoice, BadLink)
%
%  This function inserts BlockChoice into ShellBlock and inserts it in
%  the system beneath ConfigBlock.  
%
%  ConfigBlock = configurable subsystem
%  BlockChoice = system which will functionally occupy ConfigBlock
%  ShellBlock = library reference that links to BlockChoice
%

% add this block
ShellBlock = [ConfigBlock '/shell'];
BlockPosition = get_param(ConfigBlock, 'position');
blockWidth=BlockPosition(3)-BlockPosition(1);
blockHeight=BlockPosition(4)-BlockPosition(2);
BlockPosition=[200 100 200+blockWidth 100+blockHeight];

if BadLink==0
  feval(bdroot(BlockChoice), [], [], [], 'load')
  add_block(BlockChoice, ShellBlock, 'position', BlockPosition)
  
  % open unmasked subsystems if checkbox says to
  shouldopen = get_param(ConfigBlock, 'shouldOpen');
  blocktype = get_param(BlockChoice, 'BlockType');
  
  Data=get_param(ConfigBlock,'UserData');
  if isstruct(Data),
    if isfield(Data,'Initializing'),
      Initializing=Data.Initializing;
    else,
      Initializing=logical(0);
    end
  else,
    Initializing=logical(0);
  end
  
  if strcmp(shouldopen, 'on') & ...
        (hasmask(BlockChoice) ~= 2) & ...
        strcmp(blocktype, 'SubSystem') & ...
        ~Initializing, ...
    open_system(ShellBlock);
  end
  
else
  add_block('built-in/reference', ShellBlock, 'position', BlockPosition, ...
      'SourceBlock', BlockChoice)
end

%********************************************************************
%********************************************************************
%
function locNewLibraryName(ConfigBlock,maskInitFlag)
%
%  This function is called from the command line or m code when the 
%  mask variable LibraryName changes.  The function is to give the config
%  block a new identity according to the new LibraryName.  
%
%  ConfigBlock = configurable subsystem
%  LibraryName = user-entered library location
%  mdlName = name of mdl file containing LibraryName
%

LibraryName = get_param(ConfigBlock, 'LibraryName');
status = get_param(ConfigBlock, 'UserData');

% if the status doesn't have a LibraryName field, build the status structure
if ~isfield(status, 'LibraryName')
  status.LibraryName = LibraryName;
  status.Choice = get_param(ConfigBlock, 'Choice');
  status.shouldOpen = get_param(ConfigBlock, 'shouldOpen');
  status.values = get_param(ConfigBlock, 'MaskValues');
  status.allData={};
  set_param(ConfigBlock, 'UserData', status);
end

if ~isfield(status, 'dlgOnlyUpdated'),
  status.dlgOnlyUpdated=logical(0);
end

% if no change has been made, don't update
if isstruct(status),
  if strcmp(LibraryName, status.LibraryName) & ~status.dlgOnlyUpdated,
    return
  %else,
  %  maskInitFlag=logical(0);
  end
end
mdlName = strtok(LibraryName, '/');

if isequal(exist(mdlName),4),
  % we have a simulink model, load it
  feval(mdlName,[],[],[],'load')
  % and make sure that LibraryName is exists in it
  if ~strcmp(mdlName, LibraryName)
    all_sys = find_system(mdlName, 'lookundermasks', 'all');
    if isempty(find(strcmp(all_sys, LibraryName)))
      errordlg(['System ''' LibraryName ''' not found in ''' mdlName '''']);
    elseif length(find_system(LibraryName,'searchdepth',1,'type','block')) == 1
      % LibraryName is a single block without children
      errordlg(['System ''' ...
            LibraryName ''' is a single block, not a library']);
    else
      % at this point we know that LibraryName exists within mdlName
      % gut the current underlying system
      locShellEmpty(ConfigBlock);   
      % and replace 
      status = locSetupBlockInfo(ConfigBlock,LibraryName,mdlName,maskInitFlag);
      set_param(ConfigBlock, 'UserData', status)
    end
  else
    % at this point, we know that mdlName == LibraryName and it exists
    % gut the current underlying system
    locShellEmpty(ConfigBlock);   
    
    % proceed with setup
    %LPD
    status = locSetupBlockInfo(ConfigBlock, LibraryName, mdlName,maskInitFlag);
    set_param(ConfigBlock, 'UserData', status)
  end
  
else
  % otherwise, inform the user of the situation
  errordlg(['Library ''' LibraryName ''' not found on the path']); 
  
end

%********************************************************************
%********************************************************************
%
function [MaskPrompts,MaskStyles,MaskValues] = locParamInfo( ...
    BlockList,LibraryName,ConfigBlock)
%
%  This routine is used to build prompt, style and value lists for the 
%  ConfigBlock mask which contain the corresponding information for each 
%  of the candidate blocks represented.  
%
%  BlockList = cell array of blocks to be included
%  LibraryName = full path name of system containing blocks to represent 
%

% set MaskPrompts, Styles and Values for the native ConfigBlock parameters
MaskPrompts = {'Block choice:', 'Number of parameters:', 'Library name',...
      'Open subsystems when selected'};
BlockNames = get_param(BlockList, 'name');
% Remove new-line characters from names
BlockNames = strrep(BlockNames,sprintf('\n'),' ');
MaskStyles = {['popup(' locCell2SepStr(BlockNames, '|') ')'], ...
      'edit', 'edit', 'checkbox'};

% #2 gets [parameter counts], below
name=BlockNames{1};
try,
  name=get_param(ConfigBlock,'Choice');
  if ~any(strcmp(BlockNames,name)),
    name=BlockNames{1};
  end
end
MaskValues = {name, '', LibraryName, 'on'}; 

% Loop through the other blocks for their prompts, styles and values
for i = 1:length(BlockList)
  
  % Masked subsystems with prompts have an explicit prompt list
  PromptList = get_param(BlockList{i}, 'MaskPrompts');
  % if not a masked block or subsystem, get info from dialogparameters
  if isempty(PromptList) & ...
        ~strcmp(get_param(BlockList{i}, 'BlockType'),'SubSystem'),
    dp = get_param(BlockList{i}, 'dialogparameters');
    if ~isempty(dp)
      PromptList = fieldnames(dp);
      TypeList   = {};
      EnumList   = {};
      ValueList  = {};
      % accumulate types and enumerations, then convert to styles
      for j = 1:length(PromptList)
        TypeList{j} = getfield(dp, PromptList{j}, 'Type');
        EnumList{j} = getfield(dp, PromptList{j}, 'Enum');
        ValueList{j} = get_param(BlockList{i}, PromptList{j});
      end
      StyleList = locConvertToMaskStyles(TypeList, EnumList);
    else   % no parameters
      PromptList = {};
      StyleList = {};
      ValueList = {};
    end
  else
    % masked subsystem styles and values
    StyleList = get_param(BlockList{i}, 'MaskStyles'); 
    ValueList = get_param(BlockList{i}, 'MaskValues'); 
  end
  
  % Append block-specific info to master lists
  MaskPrompts = [cat(1, MaskPrompts(:), PromptList(:))];
  ParamLengths(i) = length(PromptList);
  MaskStyles = [cat(1, MaskStyles(:), StyleList(:))];
  MaskValues = [cat(1, MaskValues(:), ValueList(:))];
end

MaskValues{2} = mat2str(ParamLengths);

%********************************************************************
%********************************************************************
%
function locPlaceAndAdd(ConfigBlock,portnames,cb_ports,cb_portnames,porttype)
%
%  This routine is used to position the inports or outports under ConfigBlock
%  so that they correspond to those of the initial ShellBlock selection.
%  Ports that are not used by ShellBlock but are required by other library
%  blocks are placed below them.
%
%  ConfigBlock = configurable subsystem
%  portnames = list of the names of all the ports that are required
%  cb_ports = pool of existing ports to draw on
%  cb_portnames = corresponding names
%  porttype = 'in' or 'out'
%

PortHeight = 20;
PortWidth = 20;
ShellBlock = [ConfigBlock, '/shell'];
sb_position = get_param(ShellBlock, 'Position');
if strcmp(porttype, 'in')
  blocktype = 'Inport';
  libport = 'built-in/inport';
  x = sb_position(1)-PortWidth-80;
  if x < 5,
    x = sb_position(1)/4;   % place inports half way to left edge
                            % of page
  end
else
  blocktype = 'Outport';
  libport = 'built-in/outport';
  x = sb_position(3) + 5*PortWidth; % place outports to the right of block
end

% assemble the port names for the ShellBlock, and determine their positions
sb_ports = find_system(ShellBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'FollowLinks', 'on', ...
    'blocktype', blocktype);
sb_portnames = get_param(sb_ports, 'name');
Nsb = length(sb_portnames);
sb_pc = get_param(ShellBlock, 'PortConnectivity');
sb_ppos = cat(1, sb_pc.Position);

% put the ShellBlock names at the beginning of the overall list
portnames = cat(1, sb_portnames, setdiff(portnames, sb_portnames));
Npn = length(portnames);

% place inports at heights corresponding to ShellBlock inputs, 
% with others below
if isequal(Nsb,0),
  y = sb_position(2) + 3*PortHeight/2 + 2*PortHeight*[0:(Npn -1)]';
else,
  y = sb_ppos(1,2) + 2*PortHeight*[0:(Npn - 1)]';
end


% add ports, as needed, and move into position
% but error out if a block of the same name is already present
allpresent = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1);
allnames = get_param(allpresent,'name');
for i = 1:length(portnames)
  cb_index = find(strcmp(portnames{i}, cb_portnames));
  if isempty(cb_index)
    % check to see if an existing block already has this name.  
    % If so, error out
    if ~isempty(find(strcmp(portnames{i}, allnames)))
      errMsg= ...
  ['An ',blocktype,' named ',portnames{i},' cannot be added because an ',...
   get_param(allpresent{find(strcmp(portnames{i}, allnames))},'blocktype'),...
   ' of the same name already exists.  You will need to modify your library'...
   ' to eliminate this conflict.'];

      errordlg(errMsg);
      close(gcbf)
      error(errMsg);
    end
    
    % add the port
    add_block(libport, [ConfigBlock '/' strrep(portnames{i},'/','//')],...
        'name', portnames{i},...
        'position', ...
        [x-PortWidth/2, y(i)-PortHeight/2, x+PortWidth/2, y(i)+PortHeight/2]);
  else
    % reposition an existing port
    set_param(cb_ports{cb_index},...
        'position', ...
        [x-PortWidth/2, y(i)-PortHeight/2, x+PortWidth/2, y(i)+PortHeight/2]);
  end
end

%********************************************************************
%********************************************************************
%
function status = locSetupBlockInfo(ConfigBlock, LibraryName, mdlName,maskInitFlag)
%
%  This routine (called by locApplyLibraryName) builds the dynamic dialog used 
%  to control the block configuration and access its parameters.  The
%  routine locShellFill is then used to populate the underlying system.
%
%  ConfigBlock = configurable subsystem block
%  LibraryName = user-entered library location
%  mdlName = name of mdl file containing LibraryName
%  MaskParam1 = Choice = current block Choice
%  MaskParam2 = lengths = vector of parameter lengths for each choice
%  MaskParam3 = LibraryName
%  MaskParam4 = shouldOpen = checkbox status, open unmasked
%  subsystems when selected?
%  MaskParam5:end = parameters for each of the block choices
%  status = record with fields for LibraryName and choice

% Load the model and extract a list of the candidate blocks
BlockList  = find_system(LibraryName,'searchdepth',1,'type','block');
if ~(strcmp(mdlName, LibraryName))
  BlockList(1) = []; % eliminate LibraryName from the list
end
BlockNames = get_param(BlockList, 'name');
BlockNames = strrep(BlockNames,sprintf('\n'),' ');

temp=get_param(ConfigBlock,'UserData');
if ~isstruct(temp)|~strcmp(LibraryName,temp.LibraryName),
  maskInitFlag=logical(0);
  CHOICE=BlockNames{1};
else,
  CHOICE=temp.Choice;
end

% Assemble the prompts, styles and values for the master mask
[MaskPrompts, MaskStyles, MaskValues] = ...
    locParamInfo(BlockList,LibraryName,ConfigBlock);

% Set up MaskVisible 
MaskVisible{1} = 'on';     % for popup menu
MaskVisible{2} = 'off';    % the parameter lengths
MaskVisible{3} = 'off';    % the library name
notmasked = find(hasmask(BlockList) ~= 2);
nmtype = get_param(BlockList(notmasked), 'blocktype');
if any(strcmp(nmtype, 'SubSystem'))
  MaskVisible{4} = 'on'; % open subsystem checkbox off if
                         % applicable
  MaskCallback{4} = 'subsystem_configuration update';
else
  MaskVisible{4} = 'off'; % invisible if inapplicable to this library
  MaskCallback{4}='';
end

% and MaskCallback
MaskCallback{1} = 'subsystem_configuration updateDialog'; 
MaskCallback{2} = '';
% new LibraryName, new identity
%MaskCallback{3} = 'subsystem_configuration reestablish'; 
MaskCallback{3} = ''; 
% open_system performed in locNewBlockChoice
ParamLengths = eval(MaskValues{2});

% determine the placement of CHOICE in the popup menu list

index = find(strcmp(BlockNames, CHOICE)); % locate CHOICE in array
range = sum(ParamLengths(1:(index-1))) + 5 : sum(ParamLengths(1:index)) + 4;

% make others invisible, except for those corresponding to CHOICE
for i = 5:(sum(ParamLengths) + 4)
  if ismember(i,range)
    MaskVisible{i} = 'on';
  else
    MaskVisible{i} = 'off';
  end
   MaskCallback{i} = '';
end

MaskDescription = ['This block is configured to represent any of the top ' ...
      'level blocks and subsystems in the ''' LibraryName ''' Library'];

% MaskNames are assigned to the first four (see above) for accesibility
MaskVariables = 'Choice = @1; lengths = @2; LibraryName = &3; shouldOpen = @4';


if ~maskInitFlag,
set_param(ConfigBlock, ...
    'MaskType'       , 'Configuration Block', ...
    'MaskSelfModifiable', 'on',...
    'MaskDescription', MaskDescription, ...
    'MaskPrompts'    , MaskPrompts, ...
    'MaskStyles'     , MaskStyles, ...
    'MaskValues'     , MaskValues, ...
    'MaskIconFrame'  , 'on',...
    'MaskIconOpaque' , 'off',...
    'OpenFcn'        , '', ...
    'MaskCallbacks',   MaskCallback,...
    'MaskInitialization', '',...
    'MaskVariables',   MaskVariables, ...
    'MaskDisplay',     'disp('''')'); % (for an icon that can be ~opaque)

set_param(ConfigBlock, ...
    'LoadFcn','subsystem_configuration(''reestablish'')')
end

set_param(ConfigBlock,'MaskVisibilities',MaskVisible);
                                      

% Populate the block with the shell for the selected library system
locShellFill(ConfigBlock, BlockNames{1}, MaskValues(5:ParamLengths(1)+4))
status.LibraryName = LibraryName;
status.Choice = BlockNames{1};
status.shouldOpen = get_param(ConfigBlock, 'shouldOpen');
status.values = MaskValues;
status.dlgOnlyUpdated=logical(0);
status.allData={};

if ~maskInitFlag,
  set_param(ConfigBlock, ...
      'MaskInitialization','subsystem_configuration_blkinit', ...
      'InitFcn','subsystem_configuration(''initFcn'')');
end

%********************************************************************
%********************************************************************
%
function locShellDrawIcon(ConfigBlock)
%% This function determines when to show the block icon
%  on the configurable subsystem

% The icon of the shell block is NOT used if the choice  
%  1) is a subsystem (built-in), and
%  2) has showportlabels on, and
%  3) is not masked or (is masked and maskiconopaque is off), and
%  4) has unequal i/o count 

ShellBlock = [ConfigBlock,'/shell']; 
shellType = get_param(ShellBlock, 'BlockType'); 
CBPorts = get_param(ConfigBlock, 'ports'); 
portInfo = get_param([ConfigBlock,'/shell'], 'ports');
shellMaskType = hasmask(ShellBlock);
shellOpaque = get_param(ShellBlock,'MaskIconOpaque');

if (strcmp(shellType, 'SubSystem') & ...
      strcmp(get_param(ShellBlock,'ShowPortLabels'),'on') & ...
      (isequal(shellMaskType,0)|(~isequal(shellMaskType,0)& ...
      strcmp(shellOpaque,'off')))& ...
      (~isequal(CBPorts(1:2),portInfo(1:2))));
  
  set_param(ConfigBlock,... 
      'MaskDisplay', 'disp('''')',... 
      'MaskIconOpaque', 'off', ... 
      'ShowPortLabels', 'on') 
else
  set_param(ConfigBlock, 'MaskDisplay', 'block_icon(''shell'')'); 
end

%********************************************************************
%********************************************************************
%
function locShellEmpty(ConfigBlock)
%
%  This routine cleans out the contents of the system underneath the
%  user's ConfigBlock.  The ShellBlock, terminators and grounds are 
%  deleted, as well as the connecting lines.  Inports and outports, 
%  however, are retained.  
%
%  ConfigBlock = configurable subsystem 
%

% delete the main block, terminators and grounds if present
ShellBlock = [ConfigBlock '/shell'];
try
  delete_block(ShellBlock)
  terminators = find_system(ConfigBlock,...
      'lookundermasks', 'all',...
      'blocktype', 'Terminator');
  for i = 1:length(terminators)
    delete_block(terminators{i})
  end
  grounds = find_system(ConfigBlock,...
      'lookundermasks', 'all',...
      'blocktype', 'Ground');
  for i = 1:length(grounds)
    delete_block(grounds{i})
  end
catch
end  

% delete all lines inside
sl_lines = get_param(ConfigBlock, 'lines');
for i = 1:length(sl_lines)
  delete_line(sl_lines(i).Handle)
end

%********************************************************************
%********************************************************************
%
function locShellFill(ConfigBlock, Choice, MV)
%
%  This routine places choice in the ShellBlock which resides underneath
%  ConfigBlock, sets its parameter values and wires its inputs and outputs.
%  An important step in this process is establishing the full set of 
%  inports and outports which will show up as inputs and outputs on the
%  ConfigBlock at the user's level.
%
%  ConfigBlock = configurable subsystem in user's model
%  Choice = selected library block to occupy ConfigBlock
%  MV = mask values to place inside choice
%

% Locate the new menu selection and find number of ports
BadLink = 0;
try
  Parent = get_param(ConfigBlock, 'LibraryName');
  BlockChoice = [Parent '/' Choice];
catch
  BadLink  = 1;
end

% Delete any existing ShellBlock, lines, terminators and grounds
locShellEmpty(ConfigBlock)

% Put the new block choice in place 
locNewBlockChoice(ConfigBlock, BlockChoice, BadLink);

% If applicable, set the paramater values
if ~isempty(MV)
  locShellParams(ConfigBlock, MV, BadLink)
end

% Establish inports and outports consistent with those in the library blocks
locEstablishInports(ConfigBlock, Parent);
locEstablishOutports(ConfigBlock, Parent);

% wire the inputs and outputs
portInfo = get_param([ConfigBlock,'/shell'], 'ports');
locWireInputs(ConfigBlock, portInfo(1))
locWireOutputs(ConfigBlock, portInfo(2))
locShellDrawIcon(ConfigBlock);

%********************************************************************
%********************************************************************
%
function locShellParams(ConfigBlock, MV, BadLink)
%
%  Now set up the parameters of the block inside.  If it is a masked
%  subsystem, these are MaskValues.  If it is a block, they're 
%  dialogparameters.  
%
%  ConfigBlock = configurable subsystem
%  MV = MaskValues to apply to the ShellBlock
%  BadLink ~= 0 indicates that we shouldn't try this
%

ShellBlock = [ConfigBlock '/shell'];
if BadLink==0
  % check for masked block
  if isempty(get_param(ShellBlock, 'MaskValues'))
    % not masked block
    a = get_param(ShellBlock,'dialogparameters');
    b = fieldnames(a);
    if length(b) ~= length(MV)
      disp('something is wrong')
    else
      for i = 1:length(b)
        set_param(ShellBlock, b{i}, MV{i})
      end
    end
  else
    set_param(ShellBlock, 'MaskValues', MV)
  end
end

%********************************************************************
%********************************************************************
%
function locShellUpdate(ConfigBlock, Choice, MV)
%
%  This routine changes the choice in the ShellBlock which resides 
%  underneath ConfigBlock, sets its parameter values and wires its 
%  inputs and outputs.  The inport and outport names and locations 
%  are not changed, so the wiring of ConfigBlock itself will not be
%  affected.  
%
%  ConfigBlock = configurable subsystem in user's model
%  choice = selected library block to occupy ConfigBlock
%  MV = mask values to place inside choice
%
% Locate the new menu selection and find number of ports


%
%  The choice needs to be changed only if the choice had changed!
%  Otherwise adding and deleting blocks during initialization/update
%  could lead to disastrous effects like unresolved links/slFatals
%
status = get_param(ConfigBlock, 'UserData');  % the previous configuration
if ~strcmp(Choice, status.Choice)

  BadLink = 0;
  try
    Parent = get_param(ConfigBlock, 'LibraryName');
    BlockChoice = [Parent '/' Choice];
    portInfo = get_param(BlockChoice, 'ports');
  catch
    BadLink  = 1;
    portInfo = [0 0 0 0 0];
  end
  
  % Discard present shell contents
  locShellEmpty(ConfigBlock)

  % Put the new block choice in place
  locNewBlockChoice(ConfigBlock, BlockChoice, BadLink);
  
  % If applicable, set the paramater values
  if ~isempty(MV)
    locShellParams(ConfigBlock, MV, BadLink)
  end
  
  % Wire up the input and output ports
  portInfo = get_param([ConfigBlock,'/shell'], 'ports');
  locWireInputs(ConfigBlock, portInfo(1))
  locWireOutputs(ConfigBlock, portInfo(2))
  locShellDrawIcon(ConfigBlock);

  % Update the choice NOW
  status.Choice = Choice;
  set_param(ConfigBlock, 'UserData', status)
end

%********************************************************************
%********************************************************************
%
function locUpdateConfiguration(ConfigBlock,dlgOnlyFlag)
%
%  This routine is invoked by the dynamic dialog callback that results 
%  from choosing a new block from the configuration menu.  The appropriate
%  mask information is modified and locShellUpdate is called to modify the 
%  underlying system.
%
%  ConfigBlock = configurable subsystem
%

if nargin==1,
  dlgOnlyFlag=logical(0);
end

CHOICE = get_param(ConfigBlock, 'Choice');  % the new menu selection
shouldOpen = get_param(ConfigBlock, 'shouldOpen');  % the checkbox selection
values = get_param(ConfigBlock, 'MaskValues');  % the full list of values
status = get_param(ConfigBlock, 'UserData');  % the previous configuration
libName=get_param(ConfigBlock,'LibraryName');

% if the status doesn't have a choice field, build the status structure
if ~isfield(status, 'Choice')
  status.LibraryName = get_param(ConfigBlock, 'LibraryName');
  status.Choice = CHOICE;
  status.shouldOpen = shouldOpen;
  status.values = values;
  set_param(ConfigBlock, 'UserData', status);
end

% do nothing if no change has been made
if isstruct(status) & dlgOnlyFlag
  if strcmp(CHOICE, status.Choice) & ...
        strcmp(shouldOpen, status.shouldOpen) & ...
        strcmp(values, status.values),
    return
  end
end

styles = get_param(ConfigBlock, 'MaskStyles');  % and styles
visibilities = get_param(ConfigBlock, 'MaskVisibilities'); % and visibilities

% determine the placement of CHOICE in the popup menu list
names  = styles{1};                      % full menu list
names([1:6 end]) = [];                   % ignore 'popup()'
NameArray = locDelimitString(names, '|');   % convert to cell array
index = find(strcmp(NameArray, CHOICE)); % locate CHOICE in array

% find the range of parameters corresponding to CHOICE in the full list
NumParams = eval(values{2});             % parameter count vector
range = sum(NumParams(1:(index-1))) + 5 : sum(NumParams(1:index)) + 4;


%%%%% Update ConfigBlock Mask Visibilities
% the 4 parameters native to ConfigBlock remain unchanged
MaskVisible = visibilities(1:4);

% make others invisible, except for those corresponding to CHOICE
for i = 5:(sum(NumParams) + 4)
  if ismember(i,range)
    MaskVisible{i} = 'on';
  else
    MaskVisible{i} = 'off';
  end
end

%%%%% Set up ShellBlock with CHOICE and parameter values
status = get_param(ConfigBlock, 'Userdata');
LibraryName = get_param(ConfigBlock, 'LibraryName');
status.LibraryName = LibraryName;
status.Choice = CHOICE;
status.shouldOpen = shouldOpen;
status.values = values;

if ~dlgOnlyFlag,
  status.dlgOnlyUpdated=logical(0);
else,
  status.dlgOnlyUpdated=logical(1);
  set_param(ConfigBlock, 'UserData', status, ...
      'MaskVisibilities', MaskVisible)
end


if ~dlgOnlyFlag,
  locShellUpdate(ConfigBlock, CHOICE, values(range))
end % if

%********************************************************************
%********************************************************************
%
function locWireInputs(ConfigBlock, Nin)
%
% Connect the inports underneath ConfigBlock to the inputs of ShellBlock.
%
% ConfigBlock = configurable subsystem in the user's model
% Nin = number of shell block inputs
%

ShellBlock = [ConfigBlock '/shell'];
sb_inports = find_system(ShellBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'followlinks', 'on', ...
    'blocktype', 'Inport');
cb_inports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Inport');
cb_names = get_param(cb_inports, 'name');

% if the shell block requires more inports than are available, 
% update ConfigBlock
if Nin > length(cb_inports)
  Parent = get_param(ConfigBlock, 'LibraryName');
  locEstablishInports(ConfigBlock, Parent);
end
cb_inports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Inport');
cb_names = get_param(cb_inports, 'name');

reorderedIndices=zeros(length(cb_inports),1);
% if shell block's not a subsystem, use inports 1:Nin, without regard to name
if isempty(sb_inports) & (Nin > 0)
  for i = 1:Nin
    reorderedIndices(i)=i;
    add_line(ConfigBlock, [strrep(cb_names{i}, '/', '//'), '/1'],...
        ['shell/' num2str(i)])
  end
else
  % otherwise, base the connection on the port name
  sb_names = get_param(sb_inports, 'name');
  for i = 1:Nin
    index = find(strcmp(cb_names, sb_names{i}));
    reorderedIndices(i)=index;
    add_line(ConfigBlock, [strrep(cb_names{index}, '/', '//'), '/1'],...
        ['shell/' num2str(i)])
  end
end

% terminate unused ConfigurationBlock inports
ct=Nin;
for i = 1:length(cb_inports)
  if isempty(getfield(get_param(cb_inports{i},'portconnectivity'), ...
        'DstBlock')),
    ct=ct+1;
    reorderedIndices(ct)=i;
  end
end


% Reposition inports based on those that are connected to the block
if length(cb_inports)>0,
  inportPositions=get_param(cb_inports,'Position');
  if iscell(inportPositions),
    inportPositions=cat(1,inportPositions{:});
  end
  [y,idx]=sort(inportPositions(:,2));
  inportPositions=inportPositions(idx,:);
  inportPositions=num2cell(inportPositions,2);
  for lp=1:length(cb_inports),
    set_param(cb_inports{reorderedIndices(lp)},'Position',inportPositions{lp});
  end
end

for i = 1:length(cb_inports)
  if isempty(getfield(get_param(cb_inports{i},'portconnectivity'), ...
        'DstBlock')),
    termpos = get_param(cb_inports{i}, 'position') + [60 0 60 0];
    add_block('built-in/Terminator',[ConfigBlock,'/ignore',num2str(i)],...
        'position',termpos,'ShowName','off');
    add_line(ConfigBlock,[strrep(get_param(cb_inports{i},'name'), ...
          '/', '//'),'/1'],['ignore',num2str(i),'/1'])
  end
end


%********************************************************************
%********************************************************************
%
function locWireOutputs(ConfigBlock, Nout)
%
% Connect the ouputs of ShellBlock to the ConfigBlock outports.  Names
% are used to establish connectivity, if available.  
%
% ConfigBlock = configurable subsystem in the user's model
% Nout = number of shell block outputs
%

ShellBlock = [ConfigBlock '/shell'];
sb_outports = find_system(ShellBlock, ...
    'lookundermasks', 'all',...
    'followlinks', 'on', ...
    'searchdepth', 1, ...
    'blocktype', 'Outport');
cb_outports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Outport');
cb_names = get_param(cb_outports, 'name');

% if the shell block requires more outports than are available, 
% update ConfigBlock
if Nout > length(cb_outports)
  Parent = get_param(ConfigBlock, 'LibraryName');
  locEstablishOutports(ConfigBlock, Parent);
end
cb_outports = find_system(ConfigBlock, ...
    'lookundermasks', 'all', ...
    'searchdepth', 1,...
    'blocktype', 'Outport');
cb_names = get_param(cb_outports, 'name');

% if shell block's not a subsystem, use outports 1:Nout, without regard to name
reorderedIndices=zeros(length(cb_outports),1);
if isempty(sb_outports) & (Nout > 0)
  for i = 1:Nout
    reorderedIndices(i)=i;
    add_line(ConfigBlock, ['shell/' num2str(i)], ...
        [strrep(cb_names{i}, '/', '//'), '/1'])
  end
else
  % otherwise, base the connection on the port name
  sb_names = get_param(sb_outports, 'name');
  for i = 1:Nout
    index = find(strcmp(cb_names, sb_names{i}));
    reorderedIndices(i)=index;
    add_line(ConfigBlock, ['shell/' num2str(i)], ...
        [strrep(cb_names{index}, '/', '//'), '/1'])
  end
end

% ground unused ConfigurationBlock outports
ct=Nout;
for i = 1:length(cb_outports)
  if getfield(get_param(cb_outports{i},'portconnectivity'),'SrcBlock') < 0
    ct=ct+1;
    reorderedIndices(ct)=i;
  end
end

% Reposition inports based on those that are connected to the block
if ct>0,
  outportPositions=get_param(cb_outports,'Position');
  if iscell(outportPositions),
    outportPositions=cat(1,outportPositions{:});
  end
  [y,idx]=sort(outportPositions(:,2));
  outportPositions=outportPositions(idx,:);
  outportPositions=num2cell(outportPositions,2);
  for lp=1:length(cb_outports),
    set_param(cb_outports{reorderedIndices(lp)},...
        'Position',outportPositions{lp});
  end
end


for i = 1:length(cb_outports)
  if getfield(get_param(cb_outports{i},'portconnectivity'),'SrcBlock') < 0
    gndpos = get_param(cb_outports{i}, 'position') - [60 0 60 0];
    add_block('built-in/Ground',[ConfigBlock,'/earth',num2str(i)],...
        'position',gndpos,'ShowName','off');
    add_line(ConfigBlock,['earth' num2str(i) '/1'],...
        [strrep(get_param(cb_outports{i},'name'), '/', '//'),'/1'])
  end
end

%********************************************************************
%********************************************************************
%
function locOpenBlockDialog
%
%  This routines builds a GUI in which to enter the library name
%  on which this blocks configuration will be based.  The data
%  structure D is attached to the figure window and communicates
%  information to the callback functions.

ConfigBlock = gcb;
% Don't do anything with the virgin library block
if (strcmp(get_param(bdroot(ConfigBlock),'Lock'), 'on'))
  errordlg(['Configurable Subsystem must be placed in a model in order',...
        ' to operate'], 'Error', 'modal')
  return
end

% Check to see if the figure already exists
FigHandle = get_param(ConfigBlock, 'UserData');
if ishandle(FigHandle)
  set(FigHandle, 'visible', 'on')
  figure(FigHandle)
elseif isstruct(FigHandle) & ishandle(FigHandle.fig) % Apply has been used
  set(FigHandle.fig, 'visible', 'on')
  figure(FigHandle.fig)
else
  % Create a GUI for the Library name
  gray = get(0,'defaultuicontrolbackgroundcolor');


  dialogPos=[1 1 300 150];
  f = figure( ...
      'Numbertitle'     ,'off'                           ,...
      'HandleVisibility', 'callback'                     , ...
      'IntegerHandle'   ,'off'                           , ...
      'Name'            , get_param(ConfigBlock, 'name') , ...
      'Menubar'         ,'none'                          , ...
      'Visible'         , 'on'                           , ...
      'Color'           , gray                           , ...
      'Resize'          , 'off'                          , ...
      'Tag'             , 'Configurable Subsystem Figure', ...
      'Units'           ,'points'                        , ...
      'Position'        , dialogPos                      , ...
      'Pointer'         ,'watch'                         , ...
      'Units'           ,'characters'                      ...
      );
  % Create MAIN frame
  f0 = uicontrol(f     , ...
      'Style'          , 'frame'                , ...
      'Units'          , 'characters'           , ...
      'BackgroundColor', gray                   , ...
      'Tag'            , 'Top Frame'            , ...
      'Position'       , [1.25 6.875 47.5 4.375]  ...
      );
  
  t0 = uicontrol(f         , ...
      'Style'              , 'text'                  , ...
      'Units'              , 'characters'            , ...
      'Position'           , [2.5 10.625 50 2]     , ...
      'BackgroundColor'    , gray                    , ...
      'Tag'                ,'Title'                  , ...
      'String'             , 'Configurable Subsystem:'  ...
      );
  
  %    'HorizontalAlignment','left'                   , ...
  t0E = get(t0, 'Extent');
  set(t0, 'Position', [2.5 10.625 t0E(3)+0.5 t0E(4)])
  
  DescStr = get_param(ConfigBlock, 'MaskDescription');
  
  l0 = uicontrol(f, ...
      'Style'              , 'text'            , ...
      'Units'              , 'characters'      , ...
      'Position'           , [2.5 7.5 45 3.125], ...
      'BackgroundColor'    , gray              , ...
      'Max'                , 2                 , ...
      'Min'                , 0                 , ...
      'HorizontalAlignment', 'left'            , ...
      'Tag'                , 'Description'     , ...
      'Value', [], ...
      'String',  ['This block may be configured to represent any ' ...
        'of the top-level blocks and subsystems in a ' ...
        'user-specified Simulink Library.']  ...
      );
  
  % Create a second frame and title
  f1 = uicontrol(f, ...
      'Style'          , 'frame'                 , ...
      'Units'          , 'characters'            , ...
      'BackgroundColor', gray                    , ...
      'Tag'            , 'Bottom Frame'          , ...
      'Position'       , [1.25 3.125 47.5 2.8125]  ...
      );
  
  t1 = uicontrol(f     , ...
      'Style'          ,'text'              , ...
      'Units'          , 'characters'       , ...
      'Position'       , [2.5 5.15 11.4 1.6], ...
      'BackgroundColor', gray               , ...
      'Tag'            , 'Prompt Title'     , ...
      'String'         , 'Library name:'      ...
      );
  t1E = get(t1, 'Extent');
  set(t1, 'Position', [2.5 5.15 t1E(3)+0.5 t1E(4)])
  
  D.LibEdit = uicontrol(f  , ...
      'Style'              , 'edit'             , ...
      'HorizontalAlignment', 'left'             , ...
      'BackgroundColor'    , [1 1 1]            , ...
      'Units'              , 'characters'       , ...
      'Tag'                , 'Edit'             , ...
      'Position'           , [2.5 3.75 45 1.625]  ...
      );
  
  D.OkButton = uicontrol(f, ...
      'Style'          , 'pushbutton'                       , ...
      'String'         , 'OK'                               , ...
      'BackgroundColor', gray                               , ...
      'Units'          , 'characters'                       , ...
      'Position'       , [2.5 0.5 10.0 1.875 ]              , ...
      'Tag'            , 'OK'                               , ...
      'Callback'       , 'subsystem_configuration establish'  ...
      );
  
  D.CancelButton = uicontrol(f, ...
      'Style'          , 'pushbutton'          , ...
      'String'         , 'Cancel'              , ...
      'Backgroundcolor', gray                  , ...
      'Units'          , 'characters'          , ...
      'Position'       , [13.75 0.5 10.0 1.875], ...
      'Tag'            , 'Cancel'              , ...
      'Callback'       , 'close(gcbf)'           ...
      );
  
  D.HelpButton = uicontrol(f, ...
      'Style'          , 'pushbutton'         , ...
      'String'         , 'Help'               , ...
      'BackgroundColor', gray                 , ...
      'Units'          , 'characters'         , ...
      'Position'       , [25.0 0.5 10.0 1.875], ...
      'Tag'            , 'Help'               , ...
      'Callback'       , ...
      ['slhelp(get_param(getfield(get(gcbf,''UserData''),' ...
        '''ConfigBlock''),''handle''))'] ...
      );
  
  D.ApplyButton = uicontrol(f, ...
      'Style'          , 'pushbutton'          , ...
      'String'         , 'Apply'               , ...
      'BackgroundColor', gray                  , ...
      'Units'          , 'characters'          , ...
      'Position'       , [36.25 0.5 10.0 1.875], ...
      'Tag'            , 'Apply' , ...
      'Callback', 'subsystem_configuration establish apply' ...
      );
  
  D.ConfigBlock = ConfigBlock;

  dialogPos=get(f,'Position');
  ttlPos=get(t0,'Position');
  frmPos=get(f0,'Position');
  
  Temp=get(0,'Units');
  set(0,'Units','pixels');
  screenSize=get(0,'ScreenSize');
  set(0,'Units',Temp);
  bdPos     = get_param(bdroot(ConfigBlock),'Location');
  hgPos=rectconv(bdPos,'hg');
  dialogPos(3)=[frmPos(3)+2*frmPos(1)];
  dialogPos(4)=[sum(ttlPos([2 4]))+0.25];
  set(f,'Position',dialogPos,'Units','pixels');
  dialogPos=get(f,'Position');
  dialogPos(1)=hgPos(1)+(hgPos(3)-dialogPos(3))/2;
  dialogPos(2)=hgPos(2)+(hgPos(4)-dialogPos(4))/2;
  
  set(f, ...
      'Position',dialogPos, ...
      'Units','characters', ...
      'Userdata', D, ...
      'Pointer','arrow', ...
      'CloseRequestFcn', ...
      ['set_param(getfield(get(gcf,''UserData''),''ConfigBlock''),' ...
        '''DeleteFcn'','''');' ...
        'delete(gcf)'] ...
      );
  
  set_param(ConfigBlock, ...
      'UserData', f, ...
      'DeleteFcn', 'close(get_param(gcb, ''UserData''))')
  
end % else

%********************************************************************

