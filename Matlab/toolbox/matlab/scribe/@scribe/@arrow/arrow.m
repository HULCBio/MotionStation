function Harrow=arrow(varargin)
%ARROW creates the annotation arrow object
%  H=scribe.ARROW creates an annotation arrow instance

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
h = scribe.arrow('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);
h.ShapeType = 'arrow';
% set hittest for the group off
set(double(h),'HitTest','off');
setappdata(double(h),'scribeobject','on');
% Angle of arrow
dx = h.X(2) - h.X(1);
dy = h.Y(2) - h.Y(1);
theta = atan2(dy,dx);
costh = cos(theta); sinth = sin(theta);
% length of whole arrow in normal and pixel coords
nx = h.X;
ny = h.Y;
nlength = sqrt((diff(nx)).^2 + (diff(ny)).^2);
R1 = hgconvertunits(fig,[0 0 nx(1) ny(1)],'normalized','pixels',fig);
R2 = hgconvertunits(fig,[0 0 nx(2) ny(2)],'normalized','pixels',fig);
px = [R1(3) R2(3)];
py = [R1(4) R2(4)];
plength = sqrt((diff(px)).^2 + (diff(py)).^2);
% frational (frx of whole arrow length) Head lengths and widths

HeadFLength = h.HeadLength/plength;
HeadFWidth = h.HeadWidth/plength;
HeadFLength = h.HeadLength/plength;
HeadFWidth = h.HeadWidth/plength;
% unrotated x,y,z vectors for line part
x = [0, nlength*(1 - HeadFLength)];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% create a tail
h.Tail = hg.line('xdata',xx,'ydata',yy,'zdata',z,...
    'Color',h.TailColor,...
    'LineWidth',h.TailLineWidth,...
    'LineStyle',h.TailLineStyle,...
    'Parent',double(h),...
    'Interruptible','off');
setappdata(double(h.Tail),'ScribeGroup',h);
set(double(h.Tail),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Tail),'bdown'});
% HEAD
% unrotated x,y,z vectors for arrow
x = nlength.*[1-HeadFLength, 1, 1-HeadFLength];
y = nlength.*[HeadFWidth/2, 0, - HeadFWidth/2];
z = [0, 0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% Create Head - ignoring style and everything for now.
h.Heads = hg.patch('XData',xx,'YData',yy,'ZData',z,...
    'FaceColor',h.HeadFaceColor,'LineWidth',h.HeadLineWidth,...
    'EdgeColor',h.HeadEdgeColor,'LineStyle',h.HeadLineStyle,...
    'Parent',double(h),'Interruptible','off');
setappdata(double(h.Heads),'ScribeGroup',h);
set(double(h.Heads),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Heads),'bdown'});
% SELECTION HANDLES
afsiz = h.Afsiz;
%THE AFFORDANCES
for k=1:2
    sr(k) = hg.line('XData', h.X(k), 'YData', h.Y(k), 'LineWidth', 0.01, 'Color', 'k', ...
        'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
        'parent',double(h),'Interruptible','off','Visible','off');
    setappdata(double(sr(k)),'ScribeGroup',h);
    set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
end
h.Srect = sr;
% UPDATE XYDATA FOR HEAD PATCH
methods(h,'updateXYData');
% PIN RECTANGLE
h.Pinrect = [];
% LISTENERS
l       = handle.listener(h,h.findprop('X'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('Y'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('HeadStyle'),...
    'PropertyPostSet',@changedHeadStyle);
l(end+1)= handle.listener(h,h.findprop('HeadBackDepth'),...
    'PropertyPostSet',@changedHeadBackDepth);
l(end+1)= handle.listener(h,h.findprop('HeadRosePQ'),...
    'PropertyPostSet',@changedHeadRosePQ);
l(end+1)= handle.listener(h,h.findprop('HeadHypocycloidN'),...
    'PropertyPostSet',@changedHeadHypocycloidN); 
l(end+1)= handle.listener(h,h.findprop('HeadFaceColor'),...
    'PropertyPostSet',@changedHeadFaceColor);
l(end+1)= handle.listener(h,h.findprop('HeadEdgeColor'),...
    'PropertyPostSet',@changedHeadEdgeColor);
l(end+1)= handle.listener(h,h.findprop('HeadLineWidth'),...
    'PropertyPostSet',@changedHeadLineWidth);
l(end+1)= handle.listener(h,h.findprop('HeadLineStyle'),...
    'PropertyPostSet',@changedHeadLineStyle);
l(end+1)= handle.listener(h,h.findprop('HeadFaceAlpha'),...
    'PropertyPostSet',@changedHeadFaceAlpha);
l(end+1)= handle.listener(h,h.findprop('HeadWidth'),...
    'PropertyPostSet',@changedHeadWidth);
l(end+1)= handle.listener(h,h.findprop('HeadLength'),...
    'PropertyPostSet',@changedHeadLength);
l(end+1)= handle.listener(h,h.findprop('HeadSize'),...
    'PropertyPostSet',@changedHeadSize);
l(end+1)= handle.listener(h,h.findprop('TailColor'),...
    'PropertyPostSet',@changedTailColor);
l(end+1)= handle.listener(h,h.findprop('TailLineWidth'),...
    'PropertyPostSet',@changedTailLineWidth);
l(end+1)= handle.listener(h,h.findprop('TailLineStyle'),...
    'PropertyPostSet',@changedTailLineStyle);
l(end+1)= handle.listener(h,h.findprop('LineWidth'),...
    'PropertyPreSet',@changingLineWidth);
l(end+1)= handle.listener(h,h.findprop('LineWidth'),...
    'PropertyPostSet',@changedLineWidth);
l(end+1)= handle.listener(h,h.findprop('LineStyle'),...
    'PropertyPostSet',@changedLineStyle);
l(end+1)= handle.listener(h,h.findprop('Color'),...
    'PropertyPostSet',@changedColor);
l(end+1)= handle.listener(h,h.findprop('DataXPixOffset'),...
    'PropertyPostSet',@changedDataPos);
l(end+1)= handle.listener(h,h.findprop('DataYPixOffset'),...
    'PropertyPostSet',@changedDataPos);
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
    Harrow=h;
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
h.HeadFaceColor = h.Color;
h.HeadEdgeColor = h.Color;
h.TailColor = h.Color;

%-------------------------------------------------------%
function changedHeadStyle(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHeadBackDepth(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.HeadBackDepth<0
        h.HeadBackDepth=0;
    elseif h.HeadBackDepth>1
        h.HeadBackDepth=1;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHeadRosePQ(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.HeadRosePQ<0
        h.HeadRosePQ=0;
    elseif mod(h.HeadRosePQ,2)>0
        h.HeadRosePQ = 2 * floor(h.HeadRosePQ/2);
    end
    h.HeadStyle = 'rose';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHeadHypocycloidN(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.HeadStyle = 'hypocycloid';
    h.HeadHypocycloidN = floor(h.HeadHypocycloidN);
    if h.HeadHypocycloidN < 3
        h.HeadHypocycloidN = 3;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHeadFaceColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads),'facecolor',h.HeadFaceColor);

%-------------------------------------------------------%
function changedHeadEdgeColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads),'edgecolor',h.HeadEdgeColor);

%-------------------------------------------------------%
function changedHeadLineWidth(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads),'linewidth',h.HeadLineWidth);

%-------------------------------------------------------%
function changedHeadLineStyle(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads),'linestyle',h.HeadLineStyle);

%-------------------------------------------------------%
function changedHeadFaceAlpha(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads),'facealpha',h.HeadFaceAlpha);

%-------------------------------------------------------%
function changedHeadSize(hProp,eventData)

h=eventData.affectedObject;
h.HeadLength = h.HeadSize;
h.HeadWidth = h.HeadSize;

%-------------------------------------------------------%
function changedHeadLength(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHeadWidth(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedTailColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Tail),'color',h.TailColor);

%-------------------------------------------------------%
function changedTailLineWidth(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Tail),'linewidth',h.TailLineWidth);

%-------------------------------------------------------%
function changedTailLineStyle(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Tail),'linestyle',h.TailLineStyle);

%-------------------------------------------------------%
function changingLineWidth(hProp,eventData)

h=eventData.affectedObject;
h.PrevLineWidth = h.LineWidth;

%-------------------------------------------------------%
function changedLineWidth(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    w = h.LineWidth;
    if w>0
        h.ObserveStyle='off';
        h.TailLineWidth = w;
        h.HeadLineWidth = w;
        h.ObserveStyle='on';
        set(double(h.Tail),'linewidth',w);
        set(double(h.Heads),'linewidth',w);
    end
end

%-------------------------------------------------------%
function changedLineStyle(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    set(double(h.Tail),'linestyle',h.LineStyle);
    h.ObserveStyle='on';
end

%-------------------------------------------------------%