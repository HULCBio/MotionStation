function Hdoublearrow=doublearrow(varargin)
%DOUBLEARROW creates the double-headed arrow object
%  H=scribe.DOUBLEARROW creates a double-headed arrow instance

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
h = scribe.doublearrow('Parent',double(scribeaxes));
scribeaxes.methods('addshape',h);
h.ShapeType = 'doublearrow';
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
nlength = sqrt((abs(h.X(1) - h.X(2)))^2 + (abs(h.Y(1) - h.Y(2)))^2);
R1 = hgconvertunits(fig,[0 0 nx(1) ny(1)],'normalized','pixels',fig);
R2 = hgconvertunits(fig,[0 0 nx(2) ny(2)],'normalized','pixels',fig);
px = [R1(3) R2(3)];
py = [R1(4) R2(4)];
plength = sqrt((diff(px)).^2 + (diff(py)).^2);
% frational (frx of whole arrow length) Head lengths and widths
Head1FLength = h.Head1Length/plength;
Head1FWidth = h.Head1Width/plength;
Head2FLength = h.Head2Length/plength;
Head2FWidth = h.Head2Width/plength;
% unrotated x,y,z vectors for line part
x = [0, nlength*(1 - Head2FLength)];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% create a tail
h.Tail = hg.line('xdata',xx,'ydata',yy,'zdata',z,...
    'color',h.TailColor,...
    'linewidth',h.TailLineWidth,...
    'linestyle',h.TailLineStyle,...
    'parent',double(h),...
    'Interruptible','off');
setappdata(double(h.Tail),'ScribeGroup',h);
set(double(h.Tail),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h.Tail),'bdown'});
% HEAD 1 - off to start
% unrotated x,y,z vectors for arrow
switch h.Type
    case 'double'
        x = nlength.*[Head1FLength, 0, Head1FLength];
        y = nlength.*[Head1FWidth/2, 0, -Head1FWidth];
        z = [0, 0, 0];
    case {'auto','line','single','text'}
        x = 0; y = 0; z = 0;
end 
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% Create Head1 - ignoring style and everything for now.
h1 = hg.patch('xdata',xx,'ydata',yy,'zdata',z,...
    'facecolor',h.Head1FaceColor,'linewidth',h.Head1LineWidth,...
    'edgecolor',h.Head1EdgeColor,'linestyle',h.Head1LineStyle,...
    'parent',double(h),'Interruptible','off');
setappdata(double(h1),'ScribeGroup',h);
set(double(h1),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h1),'bdown'});
% HEAD 2
% unrotated x,y,z vectors for arrow
switch h.Type
    case {'auto','single','double','text'}
        x = nlength.*[1-Head2FLength, 1, 1-Head2FLength];
        y = nlength.*[Head2FWidth/2, 0, - Head2FWidth/2];
        z = [0, 0, 0];
    case 'line'
        x = nlength; y = nlength; z = 0;
end       
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + h.X(1);
yy = x.*sinth + y.*costh + h.Y(1);
% Create Head2 - ignoring style and everything for now.
h2 = hg.patch('xdata',xx,'ydata',yy,'zdata',z,...
    'facecolor',h.Head1FaceColor,'linewidth',h.Head1LineWidth,...
    'edgecolor',h.Head1EdgeColor,'linestyle',h.Head2LineStyle,...
    'parent',double(h),'Interruptible','off');
setappdata(double(h2),'ScribeGroup',h);
set(double(h2),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(h2),'bdown'});
h.Heads = [h1,h2];
% SELECTION HANDLES
afsiz = h.Afsiz;
for k=1:2
    sr(k) = hg.line('XData', h.X(k), 'YData', h.Y(k), 'LineWidth', 0.01, 'Color', 'k', ...
        'Marker','square','Markersize',afsiz,'MarkerFaceColor','k','MarkerEdgeColor','w',...
        'parent',double(h),'Interruptible','off','Visible','off');
    setappdata(double(sr(k)),'ScribeGroup',h);
    set(double(sr(k)),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(sr(k)),'srbdown',k});
end
h.Srect = sr;
% UPDATE XYDATA FOR HEAD PATCHES
h.methods('updateXYData');
% PIN RECTANGLE
h.Pinrect = [];
% LISTENERS
l       = handle.listener(h,h.findprop('X'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('Y'),...
    'PropertyPostSet',{@changedPos,'normalized'});
l(end+1)= handle.listener(h,h.findprop('Head1Style'),...
    'PropertyPostSet',@changedHead1Style);
l(end+1)= handle.listener(h,h.findprop('Head1BackDepth'),...
    'PropertyPostSet',@changedHead1BackDepth);
l(end+1)= handle.listener(h,h.findprop('Head1RosePQ'),...
    'PropertyPostSet',@changedHead1RosePQ);
l(end+1)= handle.listener(h,h.findprop('Head1HypocycloidN'),...
    'PropertyPostSet',@changedHead1HypocycloidN); 
l(end+1)= handle.listener(h,h.findprop('Head1FaceColor'),...
    'PropertyPostSet',@changedHead1FaceColor);
l(end+1)= handle.listener(h,h.findprop('Head1EdgeColor'),...
    'PropertyPostSet',@changedHead1EdgeColor);
l(end+1)= handle.listener(h,h.findprop('Head1LineWidth'),...
    'PropertyPostSet',@changedHead1LineWidth);
l(end+1)= handle.listener(h,h.findprop('Head1LineStyle'),...
    'PropertyPostSet',@changedHead1LineStyle);
l(end+1)= handle.listener(h,h.findprop('Head1FaceAlpha'),...
    'PropertyPostSet',@changedHead1FaceAlpha);
l(end+1)= handle.listener(h,h.findprop('Head1Width'),...
    'PropertyPostSet',@changedHead1Width);
l(end+1)= handle.listener(h,h.findprop('Head1Length'),...
    'PropertyPostSet',@changedHead1Length);
l(end+1)= handle.listener(h,h.findprop('Head2Style'),...
    'PropertyPostSet',@changedHead2Style);
l(end+1)= handle.listener(h,h.findprop('Head2BackDepth'),...
    'PropertyPostSet',@changedHead2BackDepth);
l(end+1)= handle.listener(h,h.findprop('Head2RosePQ'),...
    'PropertyPostSet',@changedHead2RosePQ);
l(end+1)= handle.listener(h,h.findprop('Head2HypocycloidN'),...
    'PropertyPostSet',@changedHead2HypocycloidN); 
l(end+1)= handle.listener(h,h.findprop('Head2FaceColor'),...
    'PropertyPostSet',@changedHead2FaceColor);
l(end+1)= handle.listener(h,h.findprop('Head2EdgeColor'),...
    'PropertyPostSet',@changedHead2EdgeColor);
l(end+1)= handle.listener(h,h.findprop('Head2LineWidth'),...
    'PropertyPostSet',@changedHead2LineWidth);
l(end+1)= handle.listener(h,h.findprop('Head2LineStyle'),...
    'PropertyPostSet',@changedHead2LineStyle);
l(end+1)= handle.listener(h,h.findprop('Head2FaceAlpha'),...
    'PropertyPostSet',@changedHead2FaceAlpha);
l(end+1)= handle.listener(h,h.findprop('Head2Width'),...
    'PropertyPostSet',@changedHead2Width);
l(end+1)= handle.listener(h,h.findprop('Head2Length'),...
    'PropertyPostSet',@changedHead2Length);
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
    Hdoublearrow=h;
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
h.Head1Style = h.HeadStyle;
h.Head2Style = h.HeadStyle;

%-------------------------------------------------------%
function changedHeadBackDepth(hProp,eventData)

h=eventData.affectedObject;
h.Head1BackDepth = h.HeadBackDepth;
h.Head2BackDepth = h.HeadBackDepth;

%-------------------------------------------------------%
function changedHeadRosePQ(hProp,eventData)

h=eventData.affectedObject;
h.HeadStyle = 'rose';
h.Head1RosePQ = h.HeadRosePQ;
h.Head2RosePQ = h.HeadRosePQ;

%-------------------------------------------------------%
function changedHeadHypocycloidN(hProp,eventData)

h=eventData.affectedObject;
h.HeadStyle = 'hypocycloid';
h.Head1HypocycloidN = h.HeadHypocycloidN;
h.Head2HypocycloidN = h.HeadHypocycloidN;

%-------------------------------------------------------%
function changedHeadFaceColor(hProp,eventData)

h=eventData.affectedObject;
h.Head1FaceColor = h.HeadFaceColor;
h.Head2FaceColor = h.HeadFaceColor;

%-------------------------------------------------------%
function changedHeadEdgeColor(hProp,eventData)

h=eventData.affectedObject;
h.Head1EdgeColor = h.HeadEdgeColor;
h.Head2EdgeColor = h.HeadEdgeColor;

%-------------------------------------------------------%
function changedHeadLineWidth(hProp,eventData)

h=eventData.affectedObject;
h.Head1LineWidth = h.HeadLineWidth;
h.Head2LineWidth = h.HeadLineWidth;

%-------------------------------------------------------%
function changedHeadLineStyle(hProp,eventData)

h=eventData.affectedObject;
h.Head1LineStyle = h.HeadLineStyle;
h.Head2LineStyle = h.HeadLineStyle;

%-------------------------------------------------------%
function changedHeadFaceAlpha(hProp,eventData)

h=eventData.affectedObject;
h.Head1FaceAlpha = h.HeadFaceAlpha;
h.Head2FaceAlpha = h.HeadFaceAlpha;

%-------------------------------------------------------%
function changedHeadSize(hProp,eventData)

h=eventData.affectedObject;
h.HeadLength = h.HeadSize;
h.HeadWidth = h.HeadSize;

%-------------------------------------------------------%
function changedHeadLength(hProp,eventData)

h=eventData.affectedObject;
h.Head1Length=h.HeadLength;
h.Head2Length=h.HeadLength;

%-------------------------------------------------------%
function changedHeadWidth(hProp,eventData)

h=eventData.affectedObject;
h.Head1Width=h.HeadWidth;
h.Head2Width=h.HeadWidth;

%-------------------------------------------------------%
function changedHead1Style(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead1BackDepth(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.Head1BackDepth<0
        h.Head1BackDepth=0;
    elseif h.Head1BackDepth>1
        h.Head1BackDepth=1;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead1RosePQ(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.Head1RosePQ<0
        h.Head1RosePQ=0;
    elseif mod(h.Head1RosePQ,2)>0
        h.Head1RosePQ = 2 * floor(h.Head1RosePQ/2);
    end
    h.Head1Style = 'rose';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead1HypocycloidN(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.Head1Style = 'hypocycloid';
    h.Head1HypocycloidN = floor(h.Head1HypocycloidN);
    if h.Head1HypocycloidN < 3
        h.Head1HypocycloidN = 3;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead1FaceColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(1)),'facecolor',h.Head1FaceColor);

%-------------------------------------------------------%
function changedHead1EdgeColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(1)),'edgecolor',h.Head1EdgeColor);

%-------------------------------------------------------%
function changedHead1LineWidth(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(1)),'linewidth',h.Head1LineWidth);

%-------------------------------------------------------%
function changedHead1LineStyle(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(1)),'linestyle',h.Head1LineStyle);

%-------------------------------------------------------%
function changedHead1FaceAlpha(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(1)),'facealpha',h.Head1FaceAlpha);

%-------------------------------------------------------%
function changedHead1Length(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead1Width(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2Style(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2BackDepth(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.Head2BackDepth<0
        h.Head2BackDepth=0;
    elseif h.Head2BackDepth>1
        h.Head2BackDepth=1;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2RosePQ(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    if h.Head2RosePQ<0
        h.Head2RosePQ=0;
    elseif mod(h.Head2RosePQ,2)>0
        h.Head2RosePQ = 2 * floor(h.Head2RosePQ/2);
    end
    h.Head2Style = 'rose';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2HypocycloidN(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.Head2Style = 'hypocycloid';
    h.Head2HypocycloidN = floor(h.Head2HypocycloidN);
    if h.Head2HypocycloidN < 3
        h.Head2HypocycloidN = 3;
    end
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2FaceColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(2)),'facecolor',h.Head2FaceColor);

%-------------------------------------------------------%
function changedHead2EdgeColor(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(2)),'edgecolor',h.Head2EdgeColor);

%-------------------------------------------------------%
function changedHead2LineWidth(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(2)),'linewidth',h.Head2LineWidth);

%-------------------------------------------------------%
function changedHead2LineStyle(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(2)),'linestyle',h.Head2LineStyle);

%-------------------------------------------------------%
function changedHead2FaceAlpha(hProp,eventData)

h=eventData.affectedObject;
set(double(h.Heads(2)),'facealpha',h.Head2FaceAlpha);

%-------------------------------------------------------%
function changedHead2Length(hProp,eventData)

h=eventData.affectedObject;
if isequal(h.ObserveStyle,'on')
    h.ObserveStyle = 'off';
    h.methods('updateXYData');
    h.ObserveStyle='on';
end

%-------------------------------------------------------%
function changedHead2Width(hProp,eventData)

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
        h.ObserveStyle='on';
        set(double(h.Tail),'linewidth',w);
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