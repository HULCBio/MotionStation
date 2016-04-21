function varargout = slfind(varargin)
%SLFIND implements find for Simulink objects

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.14.2.2 $
%   Sanjai Singh 08-17-99


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

objList = {'Simulink objects',...
           'Annotations',...
           'Blocks',...
           'Signals'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function propList = i_RegisterProperties
% Register properties for the Find dialog

propList = {'Name',...
            'Tag',...
            'BlockDialogParams',...
            'Description',...
            'BlockDescription',...
            'MaskDescription',...
            'BlockType',...
            'MaskType',...
            'LinkStatus',...
            'TestPoint'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_SelectObjects(H);
% Implement selection for the object

switch (get_param(H, 'Type'))
 case 'annotation'
   set_param(H, 'Selected', 'on', 'HiliteAncestors', 'find');
 case 'block'
   set_param(H, 'Selected', 'on', 'HiliteAncestors', 'find');
 case 'port'
   LineH = get_param(H, 'line');
   set_param(LineH, 'Selected', 'on', 'HiliteAncestors', 'find');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_DeselectObjects(H);
% Implement deselection of the object

switch (get_param(H, 'Type'))
 case 'annotation'
   set_param(H, 'Selected', 'off', 'HiliteAncestors', 'none');
 case 'block'
   set_param(H, 'Selected', 'off', 'HiliteAncestors', 'none');
 case 'port'
   LineH = get_param(H, 'line');
   set_param(LineH, 'Selected', 'off', 'HiliteAncestors', 'none');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_OpenObjects(H);
% Open system containing object

switch (get_param(H, 'Type'))
 case 'annotation'
  open_system(get_param(H, 'Parent'), 'force');

 case 'block'
  open_system(get_param(H, 'Parent'), 'force');

 case 'port'
  parentBlock = get_param(H, 'Parent');
  open_system(get_param(parentBlock, 'Parent'), 'force');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_ExecuteContextMenu(H, type)
% Context menu callback

switch (get_param(H, 'Type'))
 case 'block'
  % "type" can be property or parameter
  if strncmpi(type, 'Prop', 4)
    open_system(H, 'property');
  elseif strncmpi(type, 'Param', 5) && ...
	isempty(get_param(H, 'OpenFcn')) && ...
	~hasmaskdlg(H)
    open_system(H, 'parameter');
  else
    open_system(H);
  end
  
 case 'port'
  spdialog('Open', H);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function results = i_FindObjects(varargin)
% Find objects that match property/value pairs and return them

results = [];

% Determine all selected objects
selections = varargin{1};
f_SL       = selections(1);
f_ANNO     = selections(2);
f_BLKS     = selections(3);
f_SIG      = selections(4);

% find arguments
findArgs  = varargin(2:end);

% A simple search implies search by name
simpleLoc = find(strncmp(findArgs,'Simple',6));
simpleSearch = ~isempty(simpleLoc);
searchBlockParameters = ~isempty(find(strcmpi(findArgs,'SimpleAndParams')));
if simpleSearch
  findArgs{simpleLoc} = 'Name';
  % Default search implies find everything
  if isempty(findArgs{simpleLoc+1})
    findArgs(simpleLoc:simpleLoc+1)=[];
    simpleSearch          = 0;
    searchBlockParameters = 0;
  end
end

annoH = []; blkH = []; portH = [];

% Search for Annotations
if (f_SL || f_ANNO)
  if simpleSearch 
    findArgs{simpleLoc} = 'Text';
  end
  annoH = find_system(findArgs{1}, 'Findall','on', ...
                      findArgs{2:end}, ...
                      'Type', 'annotation');
  if simpleSearch
    findArgs{simpleLoc} = 'Name';
  end
end
% Search for Blocks
if (f_SL || f_BLKS)
  blks = find_system(findArgs{:}, 'Type', 'block');
  blkH = get_param(blks, 'Handle');
  if iscell(blkH)
    blkH = [blkH{:}]';
  end

  % Search of block parameters also
  if searchBlockParameters
    findArgs{simpleLoc} = 'BlockDialogParams';
    blks_more = find_system(findArgs{:}, 'Type', 'block');
    blkH_more = get_param(blks_more, 'Handle');
    if iscell(blkH_more)
      blkH_more = [blkH_more{:}]';
    end
    
    % Add these to list of blocks found
    blkH = unique([blkH;blkH_more]);
    
    % Restore find arguments
    findArgs{simpleLoc} = 'Name';
  end
  
end

% Filter out block diagram because we may have accidentally found
% it during our search for blocks (if regexp was on)
blkType = get_param(blkH, 'Type');
blkdiag_idx = find(strcmpi(blkType, 'block_diagram'));
if ~isempty(blkdiag_idx)
  blkH(blkdiag_idx) = [];
end

% Search for Signals
if (f_SL || f_SIG)
  portH = find_system(findArgs{1}, 'findall','on', ...
                      findArgs{2:end}, ...
                      'Type', 'port', 'PortType','outport');
  
  % Show only those ports which have lines connected to them
  lineH = get_param(portH, 'Line');
  if iscell(lineH)
    portH = portH(ishandle([lineH{:}]'));
  else
    portH = portH(ishandle(lineH(:)));
  end
  
end

% All found objects
H = [annoH; blkH; portH];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prune any Simulink objects within Stateflow blocks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parents = get_param(H, 'Parent');
if ~iscell(parents)
  parents = {parents};
end
% Filter out root level objects (since get_param(model,'MaskType') fails)
nonSFparent  = strcmp(parents, bdroot(findArgs{1}));
% Determine candidate objects (since root levels objects can't be within SF blocks)
candidateIdx = find(nonSFparent == 0);

if ~isempty(candidateIdx)
  % Determine if object lives within Stateflow subsystem and filter it out
  maskType     = get_param(parents(candidateIdx), 'MaskType');
  candidateIdx(find(strcmp(maskType, 'Stateflow'))) = [];
  % Reconstruct object list
  nonSFparent(candidateIdx) = 1;
  H = H(nonSFparent);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Form results structure %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Store Types
types = get_param(H, 'Type');
if ischar(types)
  types = {types};
end
types = strrep(types,'annotation','Annotation');
types = strrep(types,'block',     'Block');
types = strrep(types,'port',      'Signal');

%% Store Names
names = get_param(H, 'Name');
if ischar(names)
  names = {names};
end

%% Store Parents
parents=get_param(H, 'Parent');
if ischar(parents)
  parents = {parents};
end

%% Store Sources and Destinations (and fill for Signals)
sources      = cell(size(types)); 
if ~isempty(sources)
  [sources{:}] = deal('');
end
dest         = sources;

% Find all signals
sigIdx = find(strcmp(types, 'Signal'));
for i = sigIdx'
  lineH = get_param(H(i),'Line');
  % Use port for sources because the port might be unconnected
  sources{i} = get_param(get_param(H(i),'Parent'), 'Name');
  if ishandle(lineH)
    dstBlocks = get_param(lineH,'DstBlockHandle');
    % Until we get popups in tables we use only the first handle
    dstH = dstBlocks(1);
    if ishandle(dstH)
      dest{i} = get_param(dstH, 'Name');
    end
  end
end

%% Replace new lines with spaces
names   = strrep(names,   sprintf('\n'),' ');
parents = strrep(parents, sprintf('\n'),' ');
sources = strrep(sources, sprintf('\n'),' ');
dest    = strrep(dest,    sprintf('\n'),' ');

%% Store Results
for i = 1:length(H)
  results(i).Handle = H(i); 
  results(i).Type   = types{i};
  results(i).Name   = names{i};
  results(i).Parent = parents{i};
  results(i).Source = sources{i};
  results(i).Dest   = dest{i};
end
