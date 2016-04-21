function rh=scribeellipse(varargin)
%SCRIBEELLIPSE creates the annotation ellipse object
%  H=scribe.SCRIBEELLIPSE creates an annotation ellipse instance
%
%  See also PLOTEDIT

%   Copyright 1984-2004 The MathWorks, Inc.

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

h = scribe.scribeellipse('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);

% set hittest for the group off - so children will receive
set(double(h),'hittest','off');
setappdata(double(h),'scribeobject','on');

% Data for ellipse and bounding rectangle
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),'normalized',fig);
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
px = [x1 x2; x1 x2];
py = [y1 y1; y2 y2];
pz = [0 0; 0 0];

% Create ellipse (rectangle)
h.Ellipse = hg.rectangle(...
    'edgecolor',h.EdgeColor,...
    'facecolor',h.FaceColor,...
    'LineStyle',h.LineStyle,...
    'LineWidth',h.LineWidth,...
    'curvature',[1 1],...
    'parent',double(h),...
    'Interruptible','off');
set(double(h.Ellipse),'position',pos);
setappdata(double(h.Ellipse),'ScribeGroup',h);
set(double(h.Ellipse),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Ellipse),'bdown'});
% Create bounding rectangle
h.Rect = hg.surface( ...
        'EdgeColor','none',...
        'FaceColor','none',...
        'CData',NaN,...
        'FaceLighting','none',...
        'Parent',double(h),...
        'Interruptible','off');
set(double(h.Rect),'XData',px,'YData',py,'ZData',pz);
setappdata(double(h.Rect),'ScribeGroup',h);
set(double(h.Rect),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Ellipse),'bdown'});
% set(double(h.Rect),'Uicontextmenu',uic);

% Create selection handles
% normalized main ellipse upper left corner x and y
ulx = x1;
uly = y2;
rx = pos(3);
ry = pos(4);
cx = pos(1)+pos(3)/2;
cy = pos(2)+pos(4)/2;

% selection handle size;
afsiz = h.Afsiz;  % pixels
%THE AFFORDANCES
px = [ulx,ulx+rx,ulx+rx,ulx,ulx,cx,ulx+rx,cx];
py = [uly,uly,uly-ry,uly-ry,cy,uly,cy,uly-ry];
for k=1:8
    sr(k) = hg.line('XData', px(k), 'YData', py(k), 'LineWidth', 0.01, 'Color', 'k', ...
        'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
        'parent',double(h),'Interruptible','off');
    setappdata(double(sr(k)),'ScribeGroup',h);
    set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
end
h.Srect = sr;
set(sr,'Visible','off');
% initialize pin affordance
h.Pinrect = [];

%set up listeners-----------------------------------------
l       = handle.listener(h,h.findprop('Position'),...
    'PropertyPostSet',@changedPos);
l(end+1)= handle.listener(h,h.findprop('FaceColor'),...
    'PropertyPostSet',@changedFaceColor);
l(end+1)= handle.listener(h,h.findprop('EdgeColor'),...
    'PropertyPostSet',@changedEdgeProps);
l(end+1)= handle.listener(h,h.findprop('LineWidth'),...
    'PropertyPostSet',@changedEdgeProps);
l(end+1)= handle.listener(h,h.findprop('LineStyle'),...
    'PropertyPostSet',@changedEdgeProps);
l(end+1)= handle.listener(h,h.findprop('Selected'),...
    'PropertyPostSet',@changedSelected);
h.PropertyListeners = l;
l = handle.listener(h,'ObjectBeingDestroyed',{@beingDeleted,h});
h.DeleteListener = l;

set(h,varargin{:});

scribeaxes.methods('scribe_contextmenu',h,'on');
scribeaxes.CurrentShape=h;
set(scribeaxes,'HandleVisibility','off');
if ~isempty(curax)
    set(fig,'currentaxes',curax);
end
if nargout>0
    rh=h;
end

%-------------------------------------------------------%
function beingDeleted(hProp,eventData,h)

if ishandle(h) 
  if ishandle(h.Rect)
    uic = get(h.Rect,'UIContextMenu');
    if ishandle(uic)
      delete(uic);
    end
  end
  if ishandle(h.Pin)
    delete(h.Pin);
  end
end

%-------------------------------------------------------%
function changedPos(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObservePos,'on')
  % don't let changes made here cause calls to this
  h.methods('updatePinnedPosition');
  h.methods('updateXYData');
  h.methods('updateaffordances');
end

%-------------------------------------------------------%
function changedFaceColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Ellipse),'facecolor',h.FaceColor);

%-------------------------------------------------------%
function changedEdgeProps(hProp,eventData)

h=eventData.affectedObject;
h.Ellipse.EdgeColor = h.EdgeColor;
h.Ellipse.LineStyle = h.LineStyle;
h.Ellipse.LineWidth = h.LineWidth;

%-------------------------------------------------------%
function changedSelected(hProp,eventData)

h = eventData.affectedObject;

