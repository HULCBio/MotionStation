function varargout = plottoolfunc (type, varargin)
% PLOTTOOLFUNC:  Support function for the plot tool

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $


error(nargchk(1,inf,nargin));

% initialize varargout to something useful
for i=1:nargout, varargout{i} = []; end

try
    switch type,
        
    case 'makePolarAxes'
        varargout = makePolarAxes (varargin{:});

    case 'plotExpressions'
        plotExpressions (varargin{:});
        
    case 'setSelection'
        setSelection (varargin{:});

    case 'getFigureChildrenList'
        varargout = getFigureChildrenList (varargin{:});
        
    case 'getAxesTitle'
        varargout = getAxesTitle (varargin{:});
            
    case 'getAxisCanvas'
        varargout = getAxisCanvas (varargin{:});
        
    case 'prepareAxesForDnD'
        varargout = prepareAxesForDnD (varargin{:});
        
    case 'makeSubplotGrid'
        makeSubplotGrid (varargin{:});
           
    case 'setPropertyValue'
        setPropertyValue (varargin{:});
        
    case 'deleteObjects'
        deleteObjects (varargin{:});
        
    case 'getAxesHandle'
        varargout = getAxesHandle (varargin{:});

    case 'getBarAreaColor'
        varargout = getBarAreaColor (varargin{:});
        
    case 'getPlotManager'
        varargout = getPlotManager (varargin{:});
        
    case 'getNearestKnownParentClass'
        varargout = getNearestKnownParentClass (varargin{:});
        
    case 'showErrorDialog'
        if nargout
            varargout{1:nargout} = showErrorDialog (varargin{:});
        else
            showErrorDialog (varargin{:});
        end
    end

catch
    if nargout
        varargout{1:nargout} = showErrorDialog;
    else
        showErrorDialog;
    end
end


%% --------------------------------------------
function out = makePolarAxes (varargin)
% Arguments:  none; uses current figure
axes;
hline = polar ([0 2*pi], [0 1]);
% delete (hline);     % This line freezes MATLAB.  TODO: Fix it.
out = {gca};


%% --------------------------------------------
function out = getFigureChildrenList (varargin)
% Arguments:  1. figure handle

out = {};
fig = varargin{1};
if ~ishandle (fig)
    % out = showErrorDialog ('The first argument must be a figure handle!');
    out = {{}};
    return;
end
allAxes = findDataAxes (fig);
for i = length(allAxes):-1:1
    out{end+1} = java (handle (allAxes(i)));
    allChildren = graph2dhelper ('get_legendable_children', allAxes(i), true);
    for j = 1:length(allChildren)
        out{end+1} = java (handle (allChildren(j)));
    end
    if i > 1
        out{end+1} = 'separator';
    end
end
out = {out};


%% --------------------------------------------
function setSelection (varargin)
% Arguments:  1. figure handle
%             2. cell array of objects to select

if isempty (varargin), return, end
fig = varargin{1};
objs = varargin{2};

if iscell (objs)
    objs = [objs{:}];
end
selectobject (objs, 'replace');



%% --------------------------------------------
function plotExpressions (varargin)
% Arguments:  1. axes handle
%             2. plot command ('bar', 'contour', etc.)
%             3. expressions to plot
%             4. other PV pairs, e.g. 'XDataSource'
%
% Right now, this is used only by the AddDataDialog class.  Therefore,
% 'hold all' is called before the plot is made.

if isempty (varargin), return, end
axesHandle = varargin{1};
if ~ishandle (axesHandle)
    showErrorDialog ('The first argument to plotExpressions must be a figure handle!');
    return;
end
axes (axesHandle);
exprs = varargin{3};
args = varargin{4};
evalExprs = {};
try
    for i = 1:length(exprs)
        evalExprs{end+1} = evalin('base', exprs{i});
    end
catch
    errordlg (sprintf ('%s\n\n%s', lasterr, 'Please enter a variable name or a valid M expression.'), ...
        'Unknown data source');
    return;
end
for i = 1:length(args)
    if (strncmpi (args{i}, 'makedisplaynames', 16) == 1)
        evalExprs{end+1} = evalin('base', args{i});
    else
	    evalExprs{end+1} = args{i};
    end
end
hold all;
feval (varargin{2}, evalExprs{:});


%% --------------------------------------------
function out = getAxesTitle (varargin)
% Arguments:  1. axes handle

out = {};
if isempty (varargin) return, end
axesHandle = varargin{1};
if ~ishandle (axesHandle)
    showErrorDialog ('The first argument to getAxesTitle must be an axes handle!');
    return;
end
out = java (handle (get (axesHandle, 'Title')));
out = {out};


%% --------------------------------------------
function out = getAxisCanvas (varargin)
% Arguments:  1. figure handle

out = {};
fig = varargin{1};
if ~ishandle (fig)
    out = showErrorDialog ('The first argument must be a figure handle!');
    return;
end
fp = get (fig, 'javaframe');
out = fp.getAxisCanvas;
out = {out};


%% --------------------------------------------
function out = getPlotManager (varargin)
% Arguments:  1. figure handle

out = {};
fig = varargin{1};
if ~ishandle (fig)
    out = showErrorDialog ('The first argument must be a figure handle!');
    return;
end
pm = graphics.plotmanager;
setappdata (fig, 'PlotManager', pm);
out = java (pm);
out = { out };



%% --------------------------------------------
function out = prepareAxesForDnD (varargin)
% Arguments:  1. figure handle
%             2. drop point

out = {};
fig = varargin{1};
pt =  varargin{2};

% Make sure units=pixels, then set it back after the hit test:
oldUnits = get (fig, 'units');
set (fig, 'units', 'pixels');

% The Y axis is reversed, relative to the point Java found:
posn = get (fig, 'position');
pt(2) = posn(4) - pt(2);

ax = ancestor (hittest(fig, pt), 'axes');    % dropped directly onto an axes
set (fig, 'units', oldUnits);
if isempty (ax) 
    if ~isempty (get (fig, 'CurrentAxes'))
        ax = gca;                            % dropped on figure with an existing axes
    else
        ax = addsubplot (fig, 'Bottom');     % dropped on figure with no axes
    end
end
set (fig, 'CurrentAxes', ax);
set (ax, 'NextPlot', 'add');
hold all;
is3d = ~isequal (get (ax, 'View'), [0 90]);  % see also the function "is2d"
javaAx = java (handle (ax));
out = { javaAx, is3d };


%% --------------------------------------------
function makeSubplotGrid (varargin)
% Arguments:  1. figure handle
%             2. width
%             3. height
%             4. cell array of PV pairs, used for each axes created

fig = varargin{1};
if ~ishandle (fig)
    out = showErrorDialog ('The first argument must be a figure handle!');
    return;
end
width  = varargin{2};
height = varargin{3};
numPlots = width * height;
existingAxes = findDataAxes (fig);

% if necessary, delete excess axes
if length(existingAxes) > numPlots
    delete (existingAxes(1 : (length(existingAxes) - numPlots)));
end

% now call "subplot", rearranging existing plots
for i = 1:numPlots
    if i <= length (existingAxes)
        h = subplot (height, width, i, ...
                     existingAxes(length(existingAxes) - (i-1)), ...
                     'Parent', fig);
    else
        if (nargin > 3)
            args = varargin{4};
            h = subplot (height, width, i, args{:}, 'Parent', fig);
        else
            h = subplot (height, width, i, 'Parent', fig);
        end
    end
end
selectobject (h(1), 'replace');


%%---------------------------------------------
function axesList = findDataAxes (fig)
figH = handle(fig);
axesList = figH.find ...
   ('-depth', 8, ...    % 8 is somewhat arbitrary
    'type','axes', ...
    'handlevisibility', 'on', ...
    '-not','tag','legend','-and','-not','tag','Colorbar');
% Note:  this is the same search used in addsubplot.


%% --------------------------------------------
function out = getAxesHandle (varargin)
% Arguments:  1. series handle

out = {};
if isempty (varargin) return, end
series = varargin{1};
if ~ishandle (series)
    showErrorDialog ('The first argument to getAxesHandle must be a series handle!');
    return;
end
out = java (handle (get (series, 'Parent')));
out = {out};



%% --------------------------------------------
function setPropertyValue (varargin)
% Arguments:  1. array of objects
%             2. property name
%             3. new property value
objs = varargin{1};
propname = varargin{2};
propval = varargin{3};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishandle(objs)) = [];
set (objs, propname, propval);


%% --------------------------------------------
function deleteObjects (varargin)
% Arguments:  1. array of objects to delete
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishandle(objs)) = [];
selectobject ([], 'replace');
delete (objs);


%% --------------------------------------------
function out = getBarAreaColor (varargin)
% Arguments:  1. barseries or areaseries
h = varargin{1};
if ~ishandle(h)
    showErrorDialog ('The first argument to getBarAreaColor must be a figure handle!');
    return;
end
color = get (h,'FaceColor'); 
if ischar(color) 
    fig = ancestor(h,'figure'); 
    ax = ancestor(h,'axes'); 
    cmap = get(fig,'Colormap'); 
    clim = get(ax,'CLim'); 
    fvdata = get(get(h,'children'),'FaceVertexCData'); 
    seriesnum = fvdata(1); 
    color = (seriesnum-clim(1))/(clim(2)-clim(1)); 
    ind = max(1,min(size(cmap,1),floor(1+color*size(cmap,1)))); 
    color = cmap(ind,:)
end 
out = {color};

%% --------------------------------------------
function out = getNearestKnownParentClass (varargin)
% Arguments:  1. MATLAB object for which to find the parent class
knownClasses = {'figure', 'axes', 'graph2d.lineseries', ...
                'specgraph.barseries', 'specgraph.stemseries', ...
                'specgraph.areaseries', 'specgraph.errorbarseries', ...
                'specgraph.scattergroup', 'specgraph.contourgroup', ...
                'specgraph.quivergroup', 'graph3d.surfaceplot', ...
                'image', 'uipanel', 'uicontrol,' ...
                'scribe.line', 'scribe.arrow', 'scribe.doublearrow', ...
                'scribe.textarrow', 'scribe.textbox', 'scribe.scriberect', ...
                'scribe.scribeellipse', 'scribe.legend', 'scribe.colorbar', ...
                'line', 'text', 'rectangle', 'patch', 'surface'};
obj = varargin{1};
out = {''};
for i = 1:length(knownClasses)
    if isa (handle(obj), knownClasses{i})
        out = {knownClasses{i}};
        return;
    end
end


%% --------------------------------------------
function varargout = showErrorDialog (varargin)
% Arguments:  1. string containing details about the error

% initialize varargout to something useful
for i=1:nargout, varargout{i} = []; end

if ~isempty (lasterr)
    if ~isempty(varargin)
        details = varargin{1};
        errordlg (sprintf ('%s\n\n%s', lasterr, details), 'MATLAB Error');
    else
        errordlg (sprintf ('%s', lasterr), 'MATLAB Error');
    end
else
    lasterr ('unknown');
end

