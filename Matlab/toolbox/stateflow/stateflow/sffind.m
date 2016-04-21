function varargout = sffind(varargin)
% SFFIND Implements the unified finder API for 
%   Stateflow objects.  This function is
%   for internal use only.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10.2.1 $
% Sanjai Singh 08-17-99


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine the Action and its Arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Action = varargin{1};
args   = varargin(2:end);

switch (Action)

  case 'RegisterObjects'
    varargout{1} = i_RegisterObjects;
  
  case 'RegisterProperties'
    varargout{1} = i_RegisterProperties;
  
  case 'FindObjects'
    varargout{1} = i_FindObjects(args{:});
    
  case 'SelectObjects'
    i_SelectObjects(args{1});

  case 'DeselectObjects'
    i_DeselectObjects(args{1});
  
  case 'OpenObjects'
    i_OpenObjects(args{1});
 
 case 'ContextMenu'
    i_ExecuteContextMenu(args{1}, args{2});
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objList = i_RegisterObjects
% Register objects with the Find dialog

objList = {'Stateflow objects',...
	   'States',...
	   'Transitions',...
	   'Junctions',...
	   'Events',...
	   'Data',...
	   'Targets'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function propList = i_RegisterProperties
% Register properties for the Find dialog

propList = {'Any',...
	    'Label',...
	    'Name',...
	    'Description',...
	    'Document Link',...
	    'Custom Code'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_SelectObjects(H);
% Select the object

select_valid_handles(H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_DeselectObjects(H);
% Deselect the object

select_valid_handles([]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_OpenObjects(H);
% Select the object

dlg_open(H);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_ExecuteContextMenu(H, type)
% Context menu callback

switch (type)
 case 'Explore'
  sfexplr;
  sf('Explr', 'VIEW', H);
  		
 case 'Edit'
  open_chart_window(H);
  		
 case 'Property',
  dlg_open(H);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function results = i_FindObjects(varargin);
% Find objects that match property/value pairs and return them
%
% The arguments that are coming in are:
% 1)    Types of Stateflow Objects
% 2)    System name
% 3-6)  LookUnderMasks and FollowLinks
% 7-8)  Regular Expressions
% 9-10) Match Case
% 11+   Property/Value pairs

results = [];
chartH = [];

% First determine all Stateflow blocks within the selected system
system = varargin{2};

% Determine relevant Stateflow blocks
sysH = get_param(system, 'Handle');
sfH = find_system(sysH, varargin{3:6}, 'MaskType', 'Stateflow');

% Determine all charts associated with these blocks
for i = 1:length(sfH)
  chartH(i) = slsf('getBlockChartId', sfH(i));
end

% Determine search space
searchSpace = [];
for chart = chartH
  space = sf('related',chart);
  searchSpace = [searchSpace space];
end

% Create search Criteria
types = varargin{1};
searchCriteria.type = types(2:end);

% Use of regular expressions
searchCriteria.searchMethod = 1 + strcmp(varargin{8}, 'off');

% Case Sensitivity
searchCriteria.caseInsensitive = strcmp(varargin{10}, 'off');

% List of allowable properties
propList = i_RegisterProperties;

% Determine if Simple or Advanced search
% and determine search criteria
StringLocation = {};
String         = {};
if length(varargin)==10  
  StringLocation{1} = 1;  
  String{1} = '';
elseif strncmp(varargin{11}, 'Simple', 6)
  StringLocation{1} = 1;
  String{1}         = varargin{12};
else
  numPairs = (length(varargin) - 10)/2;
  for i = 1:numPairs    
    idx = find(strcmpi(varargin{9 + i*2}, propList));
    StringLocation{i} = idx;
    String{i}         = varargin{9 + i*2 + 1};
  end
end

% Determine number of pairs
numPairs = length(StringLocation);

% If there are any invalid properties, return
if length([StringLocation{:}]) ~= numPairs
  return;
end

% Now search over criteria
for i = 1:numPairs
  % search using criteria
  searchCriteria.string = String{i};
  searchCriteria.stringLocation = StringLocation{i};
  % Make the search call
  searchSpace = fnd_runsearch(searchCriteria, searchSpace);
end

% Find object properties
[resultsCell, handles] = fnd_objprop(searchSpace);

% Store Results
for i = 1:length(searchSpace)
  results(i).Handle = handles(i); 
  results(i).Type   = resultsCell{1}(i,:);
  results(i).Name   = resultsCell{2}(i,:);;
  results(i).Parent = [resultsCell{3}(i,:) resultsCell{4}(i,:)];
  results(i).Source = resultsCell{5}(i,:);
  results(i).Dest   = resultsCell{6}(i,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_valid_handles(sfHandles),
%
% Selects valid handles in the input vector, sfHandles.  Valid implies 
% that you are a Stateflow state, junction, or transition handle AND you're 
% not on the clipboard.
%
GET = sf('method','get');
stateISA = sf(GET, 'default', 'state.isa');
junctionISA = sf(GET, 'default', 'junction.isa');
transitionISA = sf(GET, 'default', 'transition.isa');  

validHandles = sf('find', sfHandles, '.isa', [stateISA;junctionISA;transitionISA]);

if ~isempty(validHandles),
  validHandles = filter_deleted_ids(validHandles);
  charts = [];
  for obj=validHandles,
    charts = [charts sf(GET, obj, '.chart')];
  end
  
  charts = unique(charts);
  for i=1:length(charts),
    chart = charts(i);
    ids = sf('find', validHandles, '.chart', chart);
    chartFig = sf('get',chart,'chart.hg.figure');
    if chartFig>0 & ishandle(chartFig)
      sf('Select', chart, validHandles);
    end
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  open_chart_window(sfId)
%
%  Function to find the relavent explorer object.  This is the parent of data
%  events, transitions, and junctions or the same object that was passed in 
%  for machines, charts and machines.
%
GET        = sf('method','get');
chartISA   = sf(GET, 'default', 'chart.isa');
machineISA = sf(GET, 'default', 'machine.isa');  
objIsa     = sf(GET, sfId, '.isa');
	
if (objIsa == chartISA)
  chartId = sfId;
elseif (objIsa == machineISA)
  return;
else
  chartId = sf('get',sfId,'.chart');
end

sf('Open',sfId);
	
