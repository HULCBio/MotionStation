function h=scribegrid(varargin)
%SCRIBEGRID creates the scribe snap-to grid object
%  H=scribe.SCRIBEGRID creates a scriberect instance
%  Only one may exist per figure
%
%  See also PLOTEDIT

%   Copyright 1984-2003 The MathWorks, Inc.
%   $  $  $  $

if nargin>0 && isa(handle(varargin{1}),'hg.figure')
    fig = varargin{1};
    varargin(1)=[];
    nargs = nargin-1;
else
    fig = gcf;
    nargs = nargin;
end
curax = get(fig,'currentaxes');

% if no scribeaxes for this figure create one.
scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if isempty(scribeaxes)
    scribeaxes = scribe.scribeaxes(fig);
end
set(scribeaxes,'HandleVisibility','on');

% if there is not a scribe overlay for this figure, create one.
% scribeunder is the hg axes, scribeuaxes is the object containing it.
scribeunder = findall(fig,'Tag','scribeUnderlay');
if isempty(scribeunder)
    scribeunder = scribe.scribeuaxes(fig);
    scribeaxes.ScribeUAxes = scribeunder;
end
set(scribeunder,'HandleVisibility','on');
% seek and remove any old grids in figure - only one is allowed.
underkids = findall(scribeunder,'type','hggroup');
found=false;
for k=1:length(underkids)
    if strcmpi('scribegrid',get(handle(underkids(k)),'shapetype'))
        delete(underkids(k)); found=true;
    end
end
if found
    % remove figure listener
    figlis = get(handle(fig),'ScribeGridFigListeners');
    if ~isempty(figlis)
        delete(figlis);
    end
    set(handle(fig),'ScribeGridFigListeners',[]);
end

h = scribe.scribegrid('Parent',double(scribeunder));

h.ScribeUAxes = scribeunder;

hBehavior = hggetbehavior(double(h),'Print');
set(hBehavior,'PrePrintCallback',@printCallback);
set(hBehavior,'PostPrintCallback',@printCallback);

setappdata(double(h),'scribeobject','on');
h.ObservePos = 'on';

% set superclass properties
h.ShapeType = 'scribegrid';

ppos = hgconvertunits(fig,get(scribeunder,'Position'),...
                      get(scribeunder,'Units'),'pixels',...
                      get(scribeunder,'Parent'));

% Get grid properties for figure
gridstruct = snaptogrid(fig,'noaction');

% VERTICAL LINES
Vlines = [];
x = 0; ydata = [0 1];
while x <= ppos(3)
    %add a line
    xn = x/ppos(3);
    newline = hg.line('parent',double(h),'XData', [xn xn], 'YData', ydata, 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Vlines = [Vlines, newline]; 
    x = x + gridstruct.xspace;
end
h.Vlines = Vlines;

% HORIZONTAL LINES
Hlines = [];
y = 0; xdata = [0 1];
while y <= ppos(4)
    %add a line
    yn = y/ppos(4);
    newline = hg.line('parent',double(h),'XData', xdata, 'YData', [yn yn], 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Hlines = [Hlines, newline];
    y = y + gridstruct.yspace;
end
h.Hlines = Hlines;

%set up listeners-----------------------------------------
l = handle.listener(h,h.findprop('color'),...
    'PropertyPostSet',@changedScribeGridStyle);
l(end+1)= handle.listener(h,h.findprop('lineWidth'),...
    'PropertyPostSet',@changedScribeGridStyle);
l(end+1)= handle.listener(h,h.findprop('lineStyle'),...
    'PropertyPostSet',@changedScribeGridStyle);
l(end+1)= handle.listener(h,h.findprop('visible'),...
    'PropertyPostSet',@changedScribeGridStyle);
l(end+1)= handle.listener(h,h.findprop('xspace'),...
    'PropertyPostSet',@changedScribeGridXSpacing);
l(end+1)= handle.listener(h,h.findprop('yspace'),...
    'PropertyPostSet',@changedScribeGridYSpacing);
h.PropertyListeners = l;

%figure position listener-----------------------------------
if ~isprop(handle(fig),'ScribeGridFigListeners')
    fl = schema.prop(handle(fig),'ScribeGridFigListeners','MATLAB array');
    fl.AccessFlags.Serialize = 'off';
    fl.Visible = 'off';
end
cls = classhandle(handle(fig));
figlis = handle.listener(fig, cls.findprop('Position'), 'PropertyPostSet', {@changedFigPosition, h, fig});
set(handle(fig),'ScribeGridFigListeners',figlis);

% set other properties passed in varargin
for k=1:(nargs/2)
    set(h,varargin{(k*2) - 1},varargin{k*2});
end
set(scribeaxes,'HandleVisibility','off');

if ~isempty(curax)
    set(fig,'currentaxes',curax);
end

%-------------------------------------------------------%
function changedScribeGridStyle(hProp,eventData)

h=eventData.affectedObject;

for k=1:length(h.Vlines)
    L = double(h.Vlines(k));
    set(L,'Color',h.color,...
        'lineWidth',h.lineWidth,...
        'lineStyle',h.lineStyle,...
        'visible',h.visible);
end
for k=1:length(h.Hlines)
    L = double(h.Hlines(k));
    set(L,'Color',h.color,...
        'lineWidth',h.lineWidth,...
        'lineStyle',h.lineStyle,...
        'visible',h.visible);
end

%-------------------------------------------------------%
function changedScribeGridXSpacing(hProp,eventData)

h=eventData.affectedObject;
fig = ancestor(h,'Figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
scribeax.ObserveFigChildAdded='off';

% recreate all lines
scribeunder = double(h.scribeUAxes);
ppos = hgconvertunits(fig,get(scribeunder,'Position'),...
                      get(scribeunder,'Units'),'pixels',...
                      get(scribeunder,'Parent'));

% Get grid properties for figure
gridstruct = snaptogrid(fig,'noaction');

% VERTICAL LINES
Vlines = double(h.Vlines);
if ~isempty(Vlines) && all(ishandle(Vlines))
    delete(Vlines);
end

Vlines = [];
x = 0; ydata = [0 1];
nlines = 0;
while x <= ppos(3)
    %add a line
    xn = x/ppos(3);
    nlines = nlines + 1;
    newline = hg.line('parent',double(h),'XData', [xn xn], 'YData', ydata, 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Vlines = [Vlines, newline]; 
    x = x + gridstruct.xspace;
end
h.Vlines = Vlines;
scribeax.ObserveFigChildAdded='on';

%-------------------------------------------------------%
function changedScribeGridYSpacing(hProp,eventData)

h=eventData.affectedObject;
fig = ancestor(h,'Figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
scribeax.ObserveFigChildAdded='off';

% recreate all lines
scribeunder = double(h.scribeUAxes);
ppos = hgconvertunits(fig,get(scribeunder,'Position'),...
                      get(scribeunder,'Units'),'pixels',...
                      get(scribeunder,'Parent'));

% Get grid properties for figure
gridstruct = snaptogrid(fig,'noaction');

% HORIZONTAL LINES
Hlines = double(h.Hlines);
if ~isempty(Hlines) && all(ishandle(Hlines))
    delete(Hlines);
end
Hlines = [];
y = 0; xdata = [0 1];
while y <= ppos(4)
    %add a line
    yn = y/ppos(4);
    newline = hg.line('parent',double(h),'XData', xdata, 'YData', [yn yn], 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Hlines = [Hlines, newline];
    y = y + gridstruct.yspace;
end
h.Hlines = Hlines;
scribeax.ObserveFigChildAdded='on';

%-------------------------------------------------------%
function editgrid(hProp,eventData,h)

% start grid edit gui

%-------------------------------------------------------%
function gridvistogg(hProp,eventData,h)

% toggle visibility

%-------------------------------------------------------%
function changedFigPosition(hProp,eventData,h,fig)

scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
scribeax.ObserveFigChildAdded='off';

% recreate all lines
scribeunder = double(h.scribeUAxes);
ppos = hgconvertunits(fig,get(scribeunder,'Position'),...
                      get(scribeunder,'Units'),'pixels',...
                      get(scribeunder,'Parent'));


% Get grid properties for figure
gridstruct = snaptogrid(fig,'noaction');

% VERTICAL LINES
Vlines = double(h.Vlines);
if ~isempty(Vlines) && all(ishandle(Vlines))
    delete(Vlines);
end
Vlines = [];
x = 0; ydata = [0 1];
while x <= ppos(3)
    %add a line
    xn = x/ppos(3);
    newline = hg.line('parent',double(h),'XData', [xn xn], 'YData', ydata, 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Vlines = [Vlines, newline]; 
    x = x + gridstruct.xspace;
end
h.Vlines = Vlines;

% HORIZONTAL LINES
Hlines = double(h.Hlines);
if ~isempty(Hlines) && all(ishandle(Hlines))
    delete(Hlines);
end
Hlines = [];
y = 0; xdata = [0 1];
while y <= ppos(4)
    %add a line
    yn = y/ppos(4);
    newline = hg.line('parent',double(h),'XData', xdata, 'YData', [yn yn], 'Color', gridstruct.color, ...
        'Marker','none', 'linestyle',gridstruct.lineStyle, 'linewidth',gridstruct.lineWidth,...
        'visible',gridstruct.visible);
    setappdata(double(newline),'ScribeGroup',h);
    Hlines = [Hlines, newline];
    y = y + gridstruct.yspace;
end
h.Hlines = Hlines;

scribeax.ObserveFigChildAdded='on';

%-------------------------------------------------------%

function printCallback(hSrc, callbackName)
%PRINTCALLBACK Pre and Post printing callback

h = hSrc;
fig = ancestor(h,'figure');
if strcmp(callbackName,'PrePrintCallback')
  set(h,'PrintVisibleTemporary',get(h,'Visible'));
  if strcmp(get(h,'Visible'),'on')
    set(h,'Visible','off');
    listeners = get(handle(fig),'ScribeGridFigListeners');
    set(listeners,'enable','off');
  end
elseif strcmp(get(h,'PrintVisibleTemporary'),'on')
  set(h,'Visible','on');
  listeners = get(handle(fig),'ScribeGridFigListeners');
  set(listeners,'enable','on');
end
