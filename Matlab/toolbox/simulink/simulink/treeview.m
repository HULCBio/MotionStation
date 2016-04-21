function handle = treeview(varargin)
% TREEVIEW   Create a tree view uicontrol
%   This function creates a listbox with a tree structure and manages
%   expanding and collapsing of the nodes in the tree via its
%   callback. The currently supported forms of data that can be passed
%   to the treeview are :
%   1) A structure, where the field names represent the nodes of the
%      tree.
%   2) A cell array. If an element of the cell array is a string, it
%   represents a node with no children. If the element is a cell
%   array, the first element of that cell array represents the name of
%   the node and the second element contains the children of that node.
%
%   TREEVIEW('Create', FIGURE, DATA) creates a listbox uicontrol in 
%   the specified figure and returns a handle to the uicontrol.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $
%   Sanjai Singh 01-17-98

Action = varargin{1};

switch Action
  
  case 'Create'
    FigH   = varargin{2};
    data   = varargin{3};
    handle = LocalCreateTreeView(FigH, data);

  case 'Update'
    Update;
    
end


function H = LocalCreateTreeView(FigH, data);
%
% Called when its time to create the tree listbox
% with the input data
%

if ~isstruct(data) & ~iscell(data)
  error(' Input data must be a structure or a cell array.');
end

if ~isempty(data)
  % Convert from Structure array 
  if isstruct(data)
    userData   = ProcessStructureData(data, 0, '');
    listString = CreateTree(userData);
  end
  
  % Convert from cell array
  if iscell(data)
    userData   = ProcessCellData(data, 0, '');
    listString = CreateTree(userData);
  end

else
  userData   = [];
  listString = {};
end

  
% .Signal      : signal name 
% .IsExpanded  : -1 ==> not expandable, 
%                 0 ==> not expanded
%                 1 ==> expanded 
% .IsDisplayed :  0 ==> shown in listbox
%                 1 ==> not shown in listbox 
% .Level       :  levels deep
% .IsSelected  :  1 if selected
%


%
% Create the listbox and the 4 pushbuttons for this UI
%
backgroundColor = [1 1 1];
fontname        = 'FixedWidth';

%
% If we got passed in a figure, we need to create
% the uicontrol, else we got passed in the uicontrol itself
%
if strcmpi(get(FigH, 'Type'), 'figure')
  H = uicontrol(FigH, ...
      'Style',               'listbox',...
      'Callback',            'treeview Update',...
      'HorizontalAlignment', 'left', ...
      'Units',               'points', ...
      'fontname',            fontname,...
      'Visible',             'on',...
      'BackgroundColor',     backgroundColor, ...
      'Max',                 2, ...
      'Min',                 0, ...
      'Value',               [], ...
      'Enable',              'on' ...
      );
else
  H = FigH;
end

% Set the string for the listbox
if length(listString) < get(H, 'Value')
  set(H , 'Value'  , []);
end
set(H , 'String'  , listString);
set(H , 'UserData', userData);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function element = DefaultDataElement;

element.Signal      = '';
element.Fullname    = '';
element.Level       = 0;
element.IsExpanded  = -1;
element.IsDisplayed = 0;
element.IsSelected  = 0;
element.Children   = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function ud = ProcessStructureData(data, level, pname)
%
% userData will contain all the information needed for
% displaying the tree view for this block.
%
% userData.Signal      (name of the signal)
% userData.Fullname    (fullname of the signal)
% userData.Level       (number of levels deep)
% userData.IsExpanded  (-1 for "N/A", 0 for "no", 1 for "yes")
% userData.IsDisplayed (should it be displayed in the listbox)
% userData.IsSelected  (is this selected)
% userData.Children    (immediate children of this element)

% Number of fields
signals = fieldnames(data);

% Create an empty data structure
ud    = DefaultDataElement;
ud(1) = [];	      
index = 0;

for i = 1:length(signals)
  index = index+1;
  ud(index) = DefaultDataElement;
  ud(index).Signal = signals{i};
  ud(index).Level  = level;
  if level==0
    % top level of the tree
    ud(index).IsDisplayed = 1;
    ud(index).Fullname = signals{i};
  else  
    ud(index).Fullname = [pname '.' signals{i}];
  end

  isExpandable = isstruct(eval(['data.' signals{i}])) & ~isempty(eval(['data.' signals{i}]));
  ud(index).IsExpanded = isExpandable - 1;
    
  if (isExpandable)
    parentName = ud(index).Fullname;
    tempData = ProcessStructureData(eval(['data.' signals{i}]), level+1, parentName );
    % update children of this element
    child = find([tempData.Level] == (level+1));
    ud(index).Children   = child; % store relative position to parent
    index = index + length(tempData);
    ud = [ud tempData];
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = ProcessCellData(data, level, pname)
%
% userData will contain all the information needed for
% displaying the tree view for this block.
%
% userData.Signal      (name of the signal)
% userData.Fullname    (fullname of the signal)
% userData.Level       (number of levels deep)
% userData.IsExpanded  (-1 for "N/A", 0 for "no", 1 for "yes")
% userData.IsDisplayed (should it be displayed in the listbox)
% userData.IsSelected  (is this selected)
% userData.Children    (immediate children of this element)

% number of signals
len = size(data,1);

% signals
signals = {};
for i = 1:len
  if iscell(data{i})
    signals{i} = data{i}{1};
  else
    signals{i} = data{i};
  end
end

% Create an empty data structure
ud    = DefaultDataElement;
ud(1) = [];	      
index = 0;

for i = 1:length(signals)
  index = index+1;
  ud(index) = DefaultDataElement;
  ud(index).Signal = signals{i};
  ud(index).Level  = level;
  if level==0
    % top level of the tree
    ud(index).IsDisplayed = 1;
    ud(index).Fullname = signals{i};
  else  
    ud(index).Fullname = [pname '.' signals{i}];
  end

  try
    isExpandable = iscell(data{i}) & ~isempty(data{i}{2});
  catch
    isExpandable = 0;
  end
  ud(index).IsExpanded = isExpandable - 1;
    
  if (isExpandable)
    parentName = ud(index).Fullname;
    tempData = ProcessCellData(data{i}{2}, level+1, parentName );
    % update children of this element
    child = find([tempData.Level] == (level+1));
    ud(index).Children   = child; % store relative position to parent
    index = index + length(tempData);
    ud = [ud tempData];
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function listString = CreateTree(ud)
% Create the string to be set in the tree listbox.

listString = {};
idx = 0;
for i = 1:length(ud)
  gap    = '  ';  % one space
  
  switch ud(i).IsExpanded
    case -1
      expand = '';
    case 0
      expand = '+ ';
    case 1
      expand = '- ';
    end
  
  
  indent = [gap(ones(1,2*ud(i).Level)) expand];
  if ud(i).IsDisplayed
    idx = idx + 1;
    listString{idx,1} = [indent ud(i).Signal];
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Update
% Update the listbox containing the tree
H = gcbf;

if strcmp(get(H,'SelectionType'),'open')
  UpdateTreeView;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dd, idx] = FindDisplayedData(ud)

dd  = ud;
idx = [];
rem = [];

for i = 1:length(ud)
  if ud(i).IsDisplayed
    idx = [idx i];
  else
    rem = [rem i];
  end
end
dd(rem) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateSelection
%
% Update the selections of the list box
%
H = gcbo;

ud = get(H, 'UserData');

[dd idx] = FindDisplayedData(ud);

% Get the current selections
sels = get(H, 'Value');
if length(sels) > 0
  sel = sels(1);
  
  % Current state of that selection is:
  state = dd(sel).IsSelected;

  % reset the selected state of other elements
  for i = 1:length(dd)
    dd(i).IsSelected = 0;
  end

  % Now toggle the state and update treeview
  if state
    dd(sel).IsSelected = 0;
    set(H, 'Value', [])
  else
    dd(sel).IsSelected = 1;
    set(H,'Value',sel)
  end

  ud(idx) = dd;
  set(H, 'UserData', ud)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateTreeView

H  = gcbo;
ud = get(H, 'Userdata');
[dd idx] = FindDisplayedData(ud);

sel = get(H,'value');

for i = 1:length(sel)
  switch dd(sel(i)).IsExpanded
   case -1
    % element is not expandable
    % do nothing;
    
   case 0
    % expand element and set display state of its children to TRUE
    dd(sel(i)).IsExpanded = 1;
    index = idx(sel(i)); %index into ud
    ud(idx) = dd;
    ud = UpdateChildren(ud, index, 1);

   case 1
    % collapse element and set display state of its children to FALSE
    dd(sel(i)).IsExpanded = 0;
    index = idx(sel(i)); %index into ud
    ud(idx) = dd;
    ud = UpdateChildren(ud, index, 0);
    
  end
end

set(H, 'UserData', ud)
set(H, 'String', CreateTree(ud))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ud = UpdateChildren(ud, i, top)


switch ud(i).IsExpanded
  
  case 0
    ch = i + ud(i).Children;
    for k = ch
      ud(k).IsDisplayed = 0;
      if (ud(k).IsExpanded ~= -1)
	% expandable, then recurse
	ud = UpdateChildren(ud, k, 0);
      end
    end

  case 1
    ch = i + ud(i).Children;
    for k = ch
      ud(k).IsDisplayed = top;
      if (ud(k).IsExpanded ~= -1)
	% expandable, then recurse
	newtop = top & ud(k).IsExpanded;
	ud = UpdateChildren(ud, k, newtop);
      end
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
