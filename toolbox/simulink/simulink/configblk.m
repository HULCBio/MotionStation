function varargout = configblk(varargin)
%CONFIGBLK controls and manages the Configuration block dialog.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.4 $
%   Sanjai Singh 09-17-99

% Store the Block handles and their corresponding Dialogs
persistent DIALOG_USERDATA

% Lock this file now to prevent user tampering
mlock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
error(nargchk(1, Inf, nargin));

% Determine what the action is
Action = varargin{1};
args   = varargin(2:end);

switch (Action)
 case 'Create'

  % Test for existence of java
  if ~usejava('MWT')
    error(['The Configuration dialog requires Java support. ' ...
	   'Use set_param/get_param of the ''MemberBlocks'' property instead'])
  end
 
  BlockHandle   = get_param(args{1}, 'Handle');
  dialog_exists = 0;
  
  % Check if dialog already created
  if ~isempty(DIALOG_USERDATA)
    idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
      dialog_exists = 1;
    end
  end

  % Create dialog for CS block and store it
  if (dialog_exists == 0)
    [BlockHandle PanelHandle] = ConfigDialogCreate(args{:});
    DIALOG_USERDATA(end+1).BlockHandle = BlockHandle;
    DIALOG_USERDATA(end).PanelHandle   = PanelHandle;
  end
  
  % Now update dialog
  UpdateConfigDialog(BlockHandle, PanelHandle);

  % Now make it visible
  frame = PanelHandle.getParent;
  frame.show;
  
 case 'Delete'
  BlockHandle = args{1};

  % Check if dialog exists
  if ~isempty(DIALOG_USERDATA)
    idx = find([DIALOG_USERDATA.BlockHandle] == BlockHandle);
    if ~isempty(idx)
      PanelHandle = DIALOG_USERDATA(idx).PanelHandle;
      frame = PanelHandle.getParent;
      frame.dispose;
      DIALOG_USERDATA(idx) = [];
    end
  end
 
 case 'DeleteAll'
  % Delete all existing dialogs
  if ~isempty(DIALOG_USERDATA)
    for i = 1:length(DIALOG_USERDATA)
      PanelHandle = DIALOG_USERDATA(i).PanelHandle;
      frame = PanelHandle.getParent;
      frame.dispose;
    end
    DIALOG_USERDATA = [];
  end
 
 case 'Apply'
  % Apply settings of dialog
  try
    ConfigDialogApply(args);
  catch
    errordlg(lasterr);
  end
  
 case 'GetPortNames'
  % Get Inport and Outport names
  varargout = ConfigGetPortNames(args{:});
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H, configPanel] = ConfigDialogCreate(varargin)
% Create the Configuration block Dialog for the given block

block = varargin{1};
name  = strrep(get_param(block, 'Name'),sprintf('\n'), ' ');
H     = get_param(block, 'Handle');
parent= get_param(block, 'Parent'); 

% Call Config constructor
configPanel = com.mathworks.toolbox.simulink.configdlg.ConfigDialog.CreateConfigDialog(name);
configFrame = configPanel.getParent;

% Set the right location
location       = get_param(H, 'Position');
parentLocation = get_param(parent, 'Location');
screenSize     = get(0,'ScreenSize');

dims   = configFrame.getBounds;
width  = dims.width; 
height = dims.height;

xLoc = min(parentLocation(1) + location(3) + width, screenSize(3)) - width;
yLoc = min(parentLocation(2) + location(2) + height, screenSize(4)) - height;
configFrame.setLocation(max(xLoc,0), max(yLoc,0));
  
% Store block handle
configPanel.setBlockHandle(H);
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateConfigDialog(block, configPanel)

H     = get_param(block, 'Handle');
parent= get_param(block, 'Parent'); 

% Populate with potential member blocks
blks = find_system(parent, 'SearchDepth', 1, ... 
                   'Type', 'block', ...
                   'Parent', parent);

% Exclude Configurable subsystems
if ~isempty(blks)
  subsysIdx = find(strcmpi(get_param(blks, 'BlockType'), 'SubSystem'));
  configIdx = find(strcmp(get_param(blks(subsysIdx), 'TemplateBlock'), '')==0);
  blks(subsysIdx(configIdx)) = [];
end


if ~isempty(blks)
  % Massage blks data
  blks = get_param(blks, 'Name');
  blks = strrep(blks, sprintf('\n'),' ');
end
    
% Set member flags on blocks
members = ParseString(get_param(block, 'MemberBlocks'));
memberFlags = zeros(length(blks),1);
for i = 1:length(blks)
    memberFlags(i) = any(strcmp(blks(i), members));
end

% Place corrent info
if isempty(blks)
  configPanel.addInfoAboutBlockChoices;
else
  configPanel.addBlockChoices(blks, memberFlags);
end
configPanel.enableValueListener;

% This is necessary to refresh the inport and outport list
% since the member block structure could have changed
% In case bad values got stuck on the block, use a try/catch block
try
  if strcmp(get_param(bdroot(block), 'Lock'), 'off')
    set_param(block, 'MemberBlocks', get_param(block, 'MemberBlocks'));
  end
end

% Set inport names
inBlocks = find_system(block,'SearchDepth',1,...
                       'LookUnderMasks','all',...
                       'BlockType','Inport');
inNames = get_param(inBlocks, 'Name');
inNames = strrep(inNames, sprintf('\n'), ' ');
configPanel.setInportNames(inNames);

% Set outport names
outBlocks = find_system(block,'SearchDepth',1,...
                        'LookUnderMasks','all',...
                        'BlockType','Outport');
outNames = get_param(outBlocks, 'Name');
outNames = strrep(outNames, sprintf('\n'), ' ');
configPanel.setOutportNames(outNames);

% Enable or disable dialog
locked = strcmp(get_param(bdroot(H), 'Lock'), 'on');
configPanel.enableDialog(~locked);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = ConfigGetPortNames(H, choices)

% Update port names based on choices
sys = get_param(H, 'Parent');

for i = 1:length(choices)
  mems{i} = [sys '/' choices{i}];
end

% Setup Inport names
inports = find_system(mems,...
                      'Searchdepth', 1,...
                      'LookUnderMasks','on',...
                      'FollowLinks','on',...
                      'BlockType','Inport');
inNames = unique_unsorted(get_param(inports, 'Name'));
inNames = strrep(inNames, sprintf('\n'), ' ');

% Setup Outport Names
outports = find_system(mems,...
                       'Searchdepth', 1,...
                       'LookUnderMasks','on',...
                       'FollowLinks','on',...
                       'BlockType','Outport');
outNames = unique_unsorted(get_param(outports, 'Name'));
outNames = strrep(outNames, sprintf('\n'), ' ');

out{1} = inNames;
out{2} = outNames;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ConfigDialogApply(args)
% Apply Config Dialog settings to the CS block

H = get_param(args{1}, 'Handle');

% Set member list
choice  = get_param(H, 'BlockChoice');
members = args{3};
if (any(strcmp(members, choice)) == 0)
  if ~isempty(members)
    choice = members{1};
  else
    choice = '';
  end
end

membersString = ConvertToString(args{3});
set_param(H,'MemberBlocks', membersString,'BlockChoice',choice)

% Set Inports order
inports = find_system(H,...
                      'Searchdepth', 1,...
                      'LookUnderMasks','on',...
                      'FollowLinks','on',...
                      'BlockType','Inport');
inNames = get_param(inports, 'Name');
newOrder = args{5};

for i = 1:length(newOrder)
  idx = find(strcmp(inNames, newOrder{i}));
  set_param(inports(idx), 'Port', num2str(i));
end

% Set Outports order
outports = find_system(H,...
                       'Searchdepth', 1,...
                       'LookUnderMasks','on',...
                       'FollowLinks','on',...
                       'BlockType','Outport');
outNames = get_param(outports, 'Name');
newOrder = args{7};

for i = 1:length(newOrder)
  idx = find(strcmp(outNames, newOrder{i}));
  set_param(outports(idx), 'Port', num2str(i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = ParseString(str)
% Return a cell array of block names from a comma-separated list
% of names. Take care to handle block names with tick marks.

% Replace single ticks with doubles
str = strrep(str,'''','''''');

% Replace newlines with spaces
str = strrep(str, sprintf('\n'), ' ');

% Create a string to eval
out = eval(['{''' strrep(str,',',''',''') '''}']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = unique_unsorted(data)
% Returns a unique list of names, maintaining their original order

len   = length(data);
[b i] = unique(data(len:-1:1));
out   = data(sort(abs(i-len-1)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = ConvertToString(array)
% Returns a comma separated string using the cell array input
out = '';
for i = 1:length(array)
  out = [out, array{i}, ','];
end
if (length(out) > 1)
  out(end) = [];
end

