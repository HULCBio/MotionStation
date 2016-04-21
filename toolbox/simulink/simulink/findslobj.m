function varargout = findslobj(varargin)
%FINDSLOBJ creates and manages the Simulink/Stateflow Integrated Finder

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $
%   Sanjai Singh 08-17-99


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define PERSISTENT variables that track the state of the Finder %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Cell array of find functions on path
persistent FUNCTION_LIST

% Cell array of objects resigtered by above functions
persistent OBJECT_LIST

% Cell array of properties resigtered by above functions
persistent PROPERTY_LIST

% Handles to the Finder
persistent FINDER_PANEL_HANDLE FINDER_FRAME_HANDLE

% Store the RESULTS
persistent RESULTS

% Store the Last selection handle
persistent LAST_SELECTION LAST_SELECTION_FCN

% Store switch for interactive testing
persistent INTERACTIVE_TESTING

% Lock this file now to prevent user tampering
mlock


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine the Action and its Arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
  error('Not enough input arguments');
end
Action = varargin{1};
args   = varargin(2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pass Arguments to Interactive Tester if in testing mode %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(Action, 'Interactive')
   INTERACTIVE_TESTING = strcmp(args{1},'on');
   return;
end

if isequal(INTERACTIVE_TESTING, 1)
  varargout{1} = ifindslobj('Catch', varargin);
  if ~strcmp(Action, 'Create')
     return;
  end
end

switch (Action)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Create Finder if needed or make it visible %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Create'
  
    % Test for existence of java
    if ~usejava('MWT')
      error('The Find dialog requires Java support');
    end
    
    try
      FINDER_FRAME_HANDLE.setVisible(1);
      FINDER_FRAME_HANDLE.show;
      FINDER_PANEL_HANDLE.setSystemField(strrep(args{1}, sprintf('\n'), ' '));
    catch
      [FUNCTION_LIST, OBJECT_LIST, PROPERTY_LIST] = i_FinderInitialize; 
      [FINDER_FRAME_HANDLE, FINDER_PANEL_HANDLE]  = i_FinderCreate(args{:});
      lasterr('');

      %
      % Populate Object List in the Finder
      %
      for i = 1:length(OBJECT_LIST)
	FINDER_PANEL_HANDLE.addObjectList(OBJECT_LIST{i});
      end
  		
      % 
      % Populate Property List in the Finder
      %
      props = [{'** Simulink **'}, sort(PROPERTY_LIST{1})];
      if length(PROPERTY_LIST)==2
          props = [props, {'** Stateflow **'}, sort(PROPERTY_LIST{2})];
      end
      props = [props, {'***************'}, {'other'}];
      FINDER_PANEL_HANDLE.setProperties(props);
    end
    
	%
	% Set the focus correctly
	%
    FINDER_PANEL_HANDLE.requestFocus;
	
    %
    % Populate Model list in the Finder
    %
    systems = find_system('flat');
    if ~isempty(systems)
      FINDER_PANEL_HANDLE.setSystems(systems);
    end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Perform the Find operation and return the results %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'Find'
    RESULTS = i_FinderFind(FUNCTION_LIST, OBJECT_LIST, args);
    if isempty(RESULTS)
      resultsCell = {};
    else
      resultsCell = {RESULTS.Type; RESULTS.Name; RESULTS.Parent; ...
		     RESULTS.Source; RESULTS.Dest};
    end
    varargout{1} = resultsCell(:);

    %
    % Deselect last selection
    %
    i_FinderDeselectObjects(LAST_SELECTION_FCN, LAST_SELECTION);
    LAST_SELECTION     = -1;
    LAST_SELECTION_FCN = '';
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Select object and deselect previous object %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'SelectObjects'
    H = RESULTS(args{1}).Handle;
    F = FUNCTION_LIST{RESULTS(args{1}).FunctionIdx};
    if (H ~= LAST_SELECTION)
      i_FinderSelectObjects(F, H);
      i_FinderDeselectObjects(LAST_SELECTION_FCN, LAST_SELECTION);
      LAST_SELECTION     = H;
      LAST_SELECTION_FCN = F;
    end

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Open Selected object %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'OpenObjects'
    H = RESULTS(args{1}).Handle;
    F = FUNCTION_LIST{RESULTS(args{1}).FunctionIdx};
    i_FinderOpenObjects(F, H);
    if (H ~= LAST_SELECTION)
      i_FinderSelectObjects(F, H);
      i_FinderDeselectObjects(LAST_SELECTION_FCN, LAST_SELECTION);
      LAST_SELECTION     = H;
      LAST_SELECTION_FCN = F;
    end

    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Context menu of particular object %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'ContextMenu'
    type = args{1};
    H = RESULTS(args{2}).Handle;
    F = FUNCTION_LIST{RESULTS(args{2}).FunctionIdx};
    i_FinderExecuteContextMenu(F, H, type);

    
  %%%%%%%%%%%%%%%%%%%%%
  %% Sort Table data %%
  %%%%%%%%%%%%%%%%%%%%%
  case 'Sort'
    % Sort data based on particular column
    % Return only indices to java code for speed
    data     = args{1};
    prefCol  = args{2};
    cellData = cat(1, data{:});
    [m n]    = size(cellData);
    cols     = 1:n;
    cols(find(cols == prefCol)) = [];
    cols = [prefCol cols];
    [dummy idx] = sortrows(cellData, cols);

    if isequal(idx(:), [1:length(idx)]')
      % this is already sorted, lets reverse sort it
      newidx = flipud(idx(:));
    else
      newidx = idx;
    end
    varargout{1} = newidx;
    RESULTS = RESULTS(newidx);
  
    
  %%%%%%%%%%%%%%%%%%%
  %% Clear Results %%
  %%%%%%%%%%%%%%%%%%%
  case 'ClearResults'
    % Deselect last object
    i_FinderDeselectObjects(LAST_SELECTION_FCN, LAST_SELECTION);
    LAST_SELECTION     = -1;
    LAST_SELECTION_FCN = '';
    % Remove results
    RESULTS = [];
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Utility functions for debugging/testing purposes %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 'GetFunctionList'
    varargout{1} = FUNCTION_LIST;
 
  case 'GetObjectList'
    varargout{1} = OBJECT_LIST;
    
  case 'GetPropertyList'
    varargout{1} = PROPERTY_LIST;
    
  case 'GetPanelHandle'
    varargout{1} = FINDER_PANEL_HANDLE;

  case 'GetFrameHandle'
    varargout{1} = FINDER_FRAME_HANDLE;

  case 'GetResults'
    varargout{1} = RESULTS;

  case 'GetLastSelection'
    varargout{1} = LAST_SELECTION;

  case 'GetLastSelectionFcn'
    varargout{1} = LAST_SELECTION_FCN;

  case 'DeleteFinder'
    try
      FINDER_PANEL_HANDLE = [];
      FINDER_FRAME_HANDLE.dispose;
      FINDER_FRAME_HANDLE = [];
      RESULTS = [];
    end

 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [functions, objects, properties] = i_FinderInitialize
% Initialize Finder Setup

% Locate "slfind" and "sffind" and register them
functions{1} = 'slfind';
if (i_StateflowIsHere)
  functions{2} = 'sffind';
end

for i = 1:length(functions)
  objects{i}    = feval(functions{i}, 'RegisterObjects');
  properties{i} = feval(functions{i}, 'RegisterProperties');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isHere = i_StateflowIsHere,
%
% Determines if Stateflow is present at runtime.
%
  isHere = 0;
  [mf, mexf] = inmem;
  isHere = any(strcmp(mexf,'sf'));
  if(~isHere)
    if exist(['sf.', mexext],'file'),
      isHere = 1;
    end;
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [frameH, panelH] = i_FinderCreate(varargin)
% Create the Finder dialog by calling the java constructor

% Invoked from which system
system = varargin{1};
if ishandle(system)
  system = getfullname(system);
end
system = strrep(system, sprintf('\n'), ' ');

% Call Finder constructor
panelH = com.mathworks.toolbox.simulink.finder.Finder.CreateFindDlg(system);
panelH.setVisible(1);

% Make the Finder visible
frameH = panelH.getParent;
frameH.setVisible(1);
frameH.show;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idx, newObjList] = i_DetermineSLFinds(f_list, o_list, objSelection)
% This function figures out if there is a need to call a particular 
% find function and which objects are selected to be found

idx = [];
count = 1;
for i = 1:length(f_list)
  currObjList = o_list{i};
  sel = [];
  for j = 1:length(currObjList)
    sel(j) = strcmp(objSelection(count), 'true');
    count = count + 1;
  end
  if (any(sel)) 
    idx = [idx i];
  end
  newObjList{i} = sel;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function results = i_FinderFind(f_list, o_list, args)
% Call the find operations for respective objects and return the results
% in a cell array that can be passed to the finder and used for display

results = [];

% Determine if the object to search on exists.
errorFlag = 0;
sys = args{3};
try
  get_param(sys, 'Handle');
catch
  rootMDL = strtok(sys, '/');
  try
    open_system(rootMDL);
    get_param(sys, 'Handle');
  catch
    errorFlag = 1;
  end
end

if errorFlag
  errordlg(['System ''' sys ''' does not exist.'])
  return;
end

% Need to determine which slfinds to call based on what the object
% selection is.
[idx newObjList] = i_DetermineSLFinds(f_list, o_list, args{2});
for i = 1:length(idx)
  fcn = f_list{idx(i)};
  % search for that object
  if (any(newObjList{idx(i)}))
    tmp = feval(fcn, 'FindObjects', newObjList{idx(i)}, args{3:end});
    if ~isempty(tmp)
      [tmp.FunctionIdx] = deal(idx(i)); % Cache which function was called
      results = [results tmp];
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_FinderSelectObjects(F, H)
% Select this object
try
  feval(F, 'SelectObjects', H);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_FinderDeselectObjects(F, H)
% Deselect this object
try
  feval(F, 'DeselectObjects', H);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_FinderOpenObjects(F, H)
% Open this object
try
  feval(F, 'OpenObjects', H);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_FinderExecuteContextMenu(F, H, type)
% Execute context menu
try
  feval(F, 'ContextMenu', H, type);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = unique_unsorted(data)
% Returns a unique list of names, maintaining their original order

len   = length(data);
[b i] = unique(data(len:-1:1));
out   = data(sort(abs(i-len-1)));


