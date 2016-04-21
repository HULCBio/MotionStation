function [h, old_props] = hgload(filename, varargin)
% HGLOAD  Loads Handle Graphics object from a file.
%
% H = HGLOAD('filename') loads handle graphics objects from the .fig
% file specified by 'filename,' and returns handles to the top-level
% objects. If 'filename' contains no extension, then the extension
% '.fig' is added.
%
% [H, OLD_PROPS] = HGLOAD(..., PROPERTIES) overrides the properties on
% the top-level objects stored in the .fig file with the values in
% PROPERTIES, and returns their previous values.  PROPERTIES must be a
% structure whose field names are property names, containing the
% desired property values.  OLD_PROPS are returned as a cell array the
% same length as H, containing the previous values of the overridden
% properties on each object.  Each cell contains a structure whose
% field names are property names, containing the original value of
% each property for that top-level object. Any property specified in
% PROPERTIES but not present on a top-level object in the file is
% not included in the returned structure of original values.
%
% HGLOAD(..., 'all') overrides the default behavior of excluding
% non-serializable objects saved in the file from being reloaded.
% Items such as the default toolbars and default menus are marked as
% non-serializable, and even if contained in the FIG-file, are
% normally not reloaded, because they are loaded from separate files
% at figure creation time.  This allows for revisioning of the default
% menus and toolbars without affecting existing FIG-files. Passing
% 'all' to HGLOAD insures that any non-serializable objects contained
% in the file are also reloaded. The default behavior of HGSAVE is to
% exclude non-serializable objects from the file at save time, and
% that can be overridden using the 'all' flag with HGSAVE.
%
% See also HGSAVE, HANDLE2STRUCT, STRUCT2HANDLE.
%

%   Copyright 1984-2004 The MathWorks, Inc. 
%   D. Foti  11/10/97

[filePath,file,fileExt]=fileparts(filename);
if isempty(fileExt) | strcmp(fileExt, '.') % see hgsave.m
  filename = fullfile(filePath, [file , fileExt, '.fig']);
end

fileVars = load(filename,'-mat');
if isempty(fieldnames(fileVars));
    try
        % Try just loading if -mat switch fails
        fileVars = load(filename);
    end
end
varNames = fieldnames(fileVars);
index = strmatch('hgS', varNames);
if length(index) ~= 1
    error('invalid Figure file format');
end

varName = varNames{index};
versionStr = varName(find(varName == '_')+1:end);
versionNum = str2double(versionStr);

if versionNum > 70000
    fileVersion = sprintf('%d.%d.%d', str2double(versionStr(1:2)), ...
        str2double(versionStr(3:4)), str2double(versionStr(5:6)));
    warning(['Figure file created with a newer version (' fileVersion ')  of MATLAB']);
end

hgS = fileVars.(varNames{index});

numHandles = prod(size(hgS));
if numHandles == 0
  warning('MATLAB:hgload:EmptyFigFile','Empty Figure file');
  if nargin > 0, h = []; end
  if nargin > 1, old_props = {}; end
  return;
end
parent = zeros(numHandles, 1);

% If we loaded only one top-level object, and it was a figure,
% add the FileName property to handle struct so that it is seen
% by the CreateFcns of figure and its children.
if (numHandles == 1) & strcmpi(hgS.type,'figure')
    try
        fullpath = which(filename);
        if isempty(fullpath)
            fullpath = filename;
        end
    catch
        fullpath = filename;
    end    
    hgS.properties.FileName = fullpath; 
end

for i = 1:numHandles
    switch(hgS(i).type) 
    case 'root'
        parent = 0;
    case 'figure' 
        parent(i) = 0;
    case {'axes' 'uimenu' 'uicontextmenu' 'uicontrol' 'uitoolbar'}
        parent(i) = gcf;
    case {'uipushtool' 'uitoggletool'}
        parent(i) = gctb;
    otherwise
        parent(i) = gca;
    end
end

flags = {'convert'};

for iv = 1:length(varargin)
    if ischar(varargin{iv})
        flags{end+1} = varargin{iv};
    elseif isstruct(varargin{iv})
        % replace property values on all objects, and return any prior values
        new_prop_struct = varargin{iv};
        new_prop_names = fieldnames(new_prop_struct);        
        for ih = 1:numHandles
            prev_vals = [];
            for inp = 1:length(new_prop_names)
                this_prop = new_prop_names{inp};
                if isfield(hgS(ih).properties,this_prop)
                    prev_vals.(this_prop) = hgS(ih).properties.(this_prop);
                end
                hgS(ih).properties.(this_prop) = new_prop_struct.(this_prop);
            end
        end
        if nargout > 1
            old_props{ih} = prev_vals;
        end
    else
        error('optional input arguments must be strings or structs');
    end
end

% create empty cell array for legends - one cell per possible figure handle
legs = cell(1,numHandles);
% extract legends from pre V7 figures
if versionNum < 70000 
    for k=1:numHandles
        if strcmpi(hgS(k).type,'figure')
            [hgS(k),legs{k}] = convert_old_figure_struct(hgS(k));
        end
    end
end

% register graph2d.lineseries class with UDD
lineseries('init');

setappdata(0,'BusyDeserializing','on');
h = struct2handle(hgS, parent, flags{:});
rmappdata(0,'BusyDeserializing');

% adjustments for figures
if ~isempty(h) & length(h)==numHandles
    for k=1:numHandles
        if strcmpi(get(h(k),'type'),'figure')
            figload_reset(h(k));
            if versionNum < 70000 && ~isempty(legs{k}) && ~isempty(fieldnames(legs{k}))
                update_children(h(k),legs{k});
            end
        end
    end
end

%---------------------------------------------------------------%
function [s,legs] = convert_old_figure_struct(s)

legs = struct;
nlegs = 0;
if ~isempty(s.children)
    % create 2 shortened lists of children
    % one not including legends 
    % and one not including legends or children with hvis off.
    newch = s.children(1); % not legend
    newch(1) = [];
    newch_hvis = s.children(1); % not legend or uimenu
    newch_hvis(1) = [];
    for k=1:length(s.children)
        % determine whether child is a legend
        if isfield(s.children(k).properties,'Tag') && ...
            strcmpi(getfield(s.children(k).properties,'Tag'),'legend')
            % add to list to be readded only if it has user data
            if isfield(s.children(k).properties,'UserData')
                nlegs = nlegs + 1;
                legs(nlegs).ud = getfield(s.children(k).properties,'UserData');
            end
        else
            % if not a legend
            newch(end+1) = s.children(k);
            % get handle visibility
            hvis = 'on';
            if isfield(s.children(k).properties,'HandleVisibility')
                hvis = getfield(s.children(k).properties,'HandleVisibility');
            end                
            if ~strcmpi(hvis,'off')
            % if not a legend and handle visibility is not off
                newch_hvis(end+1) = s.children(k);
            end
        end
    end
    s.children = newch;
    % from shortened list of children (no legends or hv off),
    % find child indices for assigning
    % plothandles when replacing legend
    % hvis off children are not included because get(children) on fig
    % created after struct2handle will not include them
    if nlegs>0
        for k=1:length(legs)
            for m=1:length(newch_hvis)
                if isequal(newch_hvis(m).handle,legs(k).ud.PlotHandle)
                    legs(k).phindex = m;
                end
            end
        end
    end
end

%---------------------------------------------------------------%
function update_children(fig,legs)

% children are in backward order from struct list
ch = flipud(get(fig,'children'));
for k=1:length(legs)
    legs(k).ud.PlotHandle = ch(legs(k).phindex);
end
for k=1:length(legs)
    ud = legs(k).ud;
    lpos = ud.legendpos;
    lstr = ud.lstrings;
    pos = ud.LegendPosition;
    ax = ud.PlotHandle;
    leg=legend(ax,lstr,lpos);
    if ~isempty(pos) && pos(3)>0 && pos(4)>0
        set(leg,'position',pos);
    end
end

%---------------------------------------------------------------%
function tb = gctb

% find the first uitoolbar in the current figure, creating one if
% necessary

tb = findobj(gcf,'type','uitoolbar');
if ~isempty(tb)
    tb = tb(1);
else
    tb = uitoolbar;
end

%---------------------------------------------------------------%
function figload_reset(fig, invisible)
% fix some problems with loading figures 
% saved with scribe functions on
% and colorbar problems with figures saved in r11.
l = findobj(fig,'tag','legend');

% make sure scribe mode, rotate3d and zoom are off
% for figures saved before r12.1
plotedit(fig,'off');
rotate3d(fig,'off');
zoom(fig,'off');

% run post deserialize method on any charting objects
axlist = datachildren(fig);
for k=1:length(axlist)
  ax = axlist(k);
  chlist = findobj(ax);
  for j=1:length(chlist)
    try
      ch = handle(chlist(j));
      if ismethod(ch,'postdeserialize')
        postdeserialize(ch);
      end
    end
  end
end

% if ScribeClearModeCallback is there, remove it
if isappdata(fig,'ScribeClearModeCallback')
    rmappdata(fig,'ScribeClearModeCallback');
end

% if there are any legends, reset them
% this is needed because patches set their cdata
% based on the cdata of the plot axes children
% which may not exist or have their correct cdata
% when a legend is generated by struct2handle
if ~isempty(l)
    for j=1:length(l)
        legend(l(j));
    end
end

% if there are any data children
% make the first one that is an axes the currentaxes
% otherwise last thing saved is currentaxes
dc=datachildren(fig);
if ~isempty(dc)
    foundaxes=0;
    j=1;
    while ~foundaxes & j<(length(dc)+1)
        if strcmpi(get(dc(j),'type'),'axes')
            set(fig,'currentaxes',dc(j));
            foundaxes=1;
        end
        j=j+1;
    end
end

% run postdeserialize on any other figure children.
% Currently this should include scribe layer,
% legend and colorbar
axlist = allchild(fig);
for k=1:length(axlist)
  ax = axlist(k);
  if isappdata(ax,'PostDeserializeFcn')
    feval(getappdata(ax,'PostDeserializeFcn'),ax,'load')
  elseif ismethod(handle(ax),'postdeserialize')
    try
      postdeserialize(handle(ax));
    end
  end
end

