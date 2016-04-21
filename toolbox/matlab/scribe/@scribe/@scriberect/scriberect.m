function rh=scriberect(varargin)
%SCRIBERECT creates the annotation rectangle object
%  H=scribe.SCRIBERECT creates an annotation rectangle instance
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

h = scribe.scriberect('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);

% set hittest for the group off
set(double(h),'HitTest','off');
setappdata(double(h),'scribeobject','on');

% Create the main rectangle and affordance rectangles
% some locals for positions
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),'normalized',fig);
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
px = [x1 x2; x1 x2];
py = [y1 y1; y2 y2];
pz = [0 0; 0 0];
if isempty(h.Rect) || ~ishandle(h.Rect)
  h.FaceObject = hg.surface(... 
        'EdgeColor','none',...
        'FaceColor','flat',...
        'CData',NaN,...
        'FaceLighting','none',...
        'Parent',double(h),...
        'Interruptible','off');
  h.Rect = hg.rectangle(... 
        'EdgeColor',h.EdgeColor,...
        'LineStyle',h.LineStyle,...
        'LineWidth',h.LineWidth,...
        'Parent',double(h),...
        'Interruptible','off');
end
set(double(h.Rect),'Position',[x1 y1 x2-x1 y2-y1]);
set(double(h.FaceObject),'XData',px,'YData',py,'ZData',pz);
setappdata(double(h.Rect),'ScribeGroup',h);
setappdata(double(h.FaceObject),'ScribeGroup',h);
set(double(h.Rect),'ButtonDownFcn',{graph2dhelper('scribemethod'), ...
                    double(h.Rect),'bdown'});
set(double(h.FaceObject),'ButtonDownFcn',{graph2dhelper('scribemethod'), ...
                    double(h.Rect),'bdown'});

% selection handles
% normalized main rect upper left corner x and y
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
if isempty(h.Srect) || ~all(ishandle(h.Srect))
    for k=1:8
        sr(k) = hg.line('XData', px(k), 'YData', py(k), 'LineWidth', 0.01, 'Color', 'k', ...
            'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
            'Parent',double(h),'Interruptible','off');
        setappdata(double(sr(k)),'ScribeGroup',h);
        set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
    end
end
h.Srect = sr;
set(sr,'Visible','off');

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
l(end+1)= handle.listener(h,h.findprop('FaceAlpha'),...
    'PropertyPostSet',@changedAlpha);
l(end+1)= handle.listener(h,h.findprop('Image'),...
    'PropertyPostSet',@changedImage);
l(end+1)= handle.listener(h,h.findprop('Selected'),...
    'PropertyPostSet',@changedSelected);
h.PropertyListeners = l;
l = handle.listener(h,'ObjectBeingDestroyed',{@beingDeleted,h});
h.DeleteListener = l;

% set other properties passed in varargin
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

%----------------------------------------------------------------%
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
set(double(h.FaceObject),'facecolor',h.FaceColor);

%-------------------------------------------------------%
function changedEdgeProps(hProp,eventData)

h=eventData.affectedObject;
h.Rect.EdgeColor = h.EdgeColor;
h.Rect.LineStyle = h.LineStyle;
h.Rect.LineWidth = h.LineWidth;

%-------------------------------------------------------%
function changedAlpha(hProp,eventData)

h=eventData.affectedObject;
set(double(h.FaceObject),'facealpha',h.FaceAlpha);

%-------------------------------------------------------%
function changedImage(hProp,eventData)

h = eventData.affectedObject;
if isempty(h.Image)
    set(double(h.FaceObject),'faceColor',h.FaceColor);
else
    set(double(h.FaceObject),'cdata',flipud(h.Image));
    set(double(h.FaceObject),'faceColor','texture');
end

%-------------------------------------------------------%
function changedSelected(hProp,eventData)

h = eventData.affectedObject;

