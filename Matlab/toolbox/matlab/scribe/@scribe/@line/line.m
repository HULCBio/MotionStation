function Hline=line(varargin)
%LINE creates the annotation line object
%  H=scribe.LINE creates an annotation line instance

%   Copyright 1984-2003 The MathWorks, Inc. 

fig = [];
if (nargin == 0) || ischar(varargin{1})
  parind = find(strcmpi(varargin,'parent'));
  if ~isempty(parind)
    fig = get(varargin{parind(end)+1},'Parent');
  end
else
  [fig,varargin,nargs] = graph2dhelper('hgcheck','hg.figure',varargin{:});
end
if isempty(fig)
    fig = gcf;
end
curax = get(fig,'currentaxes');
% if no scribeaxes for this figure create one.
scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if isempty(scribeaxes)
    scribeaxes = scribe.scribeaxes(fig);
end
set(scribeaxes,'HandleVisibility','on');
h = scribe.line('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);
h.ShapeType = 'line';
% set hittest for the group off
set(double(h),'HitTest','off');
setappdata(double(h),'scribeobject','on');
% Angle of line
dx = h.X(2) - h.X(1);
dy = h.Y(2) - h.Y(1);
theta = atan2(dy,dx);
costh = cos(theta); sinth = sin(theta);
% length of whole arrow in normal coords
nlength = sqrt((abs(h.X(1) - h.X(2)))^2 + (abs(h.Y(1) - h.Y(2)))^2);
% unrotated x,y,z vectors for line part
x = [0, nlength];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% create a tail (line)
h.Tail = hg.line('xdata',xx,'ydata',yy,'zdata',z,...
    'color',h.Color,...
    'linewidth',h.LineWidth,...
    'linestyle',h.LineStyle,...
    'parent',double(h),...
    'interruptible','off');
setappdata(double(h.Tail),'ScribeGroup',h);
set(double(h.Tail),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Tail),'bdown'});
% SELECTION HANDLES
afsiz = h.Afsiz;
%THE AFFORDANCES
for k=1:2
    sr(k) = hg.line('XData', h.X(k), 'YData', h.Y(k), 'LineWidth', 0.01, 'Color', 'k', ...
        'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
        'parent',double(h),'Visible','off','Interruptible','off');
    setappdata(double(sr(k)),'ScribeGroup',h);
    set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
end
h.Srect = sr;

% % UPDATE XYDATA FOR HEAD PATCHES
% methods(h,'updateXYData');

% PIN RECTANGLE
h.Pinrect = [];

% PROPERTY LISTENERS
l       = handle.listener(h,h.findprop('X'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('Y'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('LineWidth'),...
    'PropertyPostSet',@changedLineWidth);
l(end+1)= handle.listener(h,h.findprop('LineStyle'),...
    'PropertyPostSet',@changedLineStyle);
l(end+1)= handle.listener(h,h.findprop('Color'),...
    'PropertyPostSet',@changedColor);
h.PropertyListeners = l;
l = handle.listener(h,'ObjectBeingDestroyed',{@beingDeleted,h});
h.DeleteListener = l;

scribeaxes.methods('scribe_contextmenu',h,'on');
scribeaxes.CurrentShape=h;

% set other properties passed in varargin
set(h,varargin{:});
set(scribeaxes,'HandleVisibility','off');

if ~isempty(curax)
    set(fig,'currentaxes',curax);
end

if nargout>0
    Hline=h;
end

%-------------------------------------------------------%
function beingDeleted(hProp,eventData,h)

if ishandle(h) 
  if ishandle(h.Tail)
    uic = get(h.Tail,'UIContextMenu');
    if ishandle(uic)
      delete(uic);
    end
  end
  pins = h.Pin;
  if length(pins)>0 && ishandle(pins(1))
    delete(pins(1));
  end
  if length(pins)>1 && ishandle(pins(2))
    delete(pins(2));
  end
end

%-------------------------------------------------------%
function changedPos(hProp,eventData,units)
h=eventData.affectedObject;
if isequal(h.ObservePos,'on')
    % don't let changes made here cause calls to this
    h.ObservePos = 'off';
    h.methods('updateXYData');
    h.methods('updateaffordances');
    h.ObservePos='on';
end

%-------------------------------------------------------%
function changedColor(hProp,eventData)

h=eventData.affectedObject;
set(h.Tail,'color',h.Color);

%-------------------------------------------------------%
function changedLineWidth(hProp,eventData)

h=eventData.affectedObject;
set(h.Tail,'LineWidth',h.LineWidth);

%-------------------------------------------------------%
function changedLineStyle(hProp,eventData)

h=eventData.affectedObject;
set(h.Tail,'LineStyle',h.LineStyle);

%-------------------------------------------------------%