function val = lineMethods(this,fcn,varargin)
% LINEMETHODS - methods for line class

%   Copyright 1984-2004 The MathWorks, Inc.

val = [];
% one arg is methods(obj) call
if nargin==1
    cls = this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = {fcn,this,varargin{:}};
if nargout == 0
  feval(args{:});
else
  val = feval(args{:});
end

%-----------------------------------------------------------------------%
function postdeserialize(h)

% delete children not created in constructor and children involved in
% pinning (Pintext, Pinrect).
goodchildren(1) = double(h.Tail);
goodchildren(2:3) = double(h.Srect);
allchildren = get(double(h),'Children');
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
  delete(badchildren);
end

updateXYData(h);

%{
% repin head 1 if it was pinned
if ~isempty(h.PinnedAxes1) || ~isempty(h.PinnedObject1)
    h.PinnedAxes1 = [];
    h.PinnedObject1 =[];
    methods(h,'pin_at_current_position',1);
end
% repin head 2 if it was pinned
if ~isempty(h.PinnedAxes2) || ~isempty(h.PinnedObject2)
    h.PinnedAxes2 = [];
    h.PinnedObject2 =[];
    methods(h,'pin_at_current_position',2);
end
%}
h.Pin = [];

% set deselected (no saving selected)
setselected(h,'off');

%-----------------------------------------------------------------------%
function over=mouseover(h,point)
% Return the cursor to use if the mouse is over this object.
scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
obj = hittest(fig);
over = 0; % not over object

if strcmpi('off',scribeax.InteractiveCreateMode)
    if ishandle(obj)
        [intail,inaff] = parts_containing_point(h,point);
        if inaff>0 
            over = 'movepoint'; % move endpoint
        elseif intail>0
            over = 1; % move cursor
        end
    end
end

%-----------------------------------------------------------------------%
function moved = has_moved(h)

moved = ~isequal(h.Xlast,h.X) || ~isequal(h.Ylast,h.Y);

%-----------------------------------------------------------------------%
function on=ispointon(h,point)

on=false;
fig = ancestor(h,'figure');
% obj = hittest(fig);
% [intail,inaff] = parts_containing_point(h,obj);
[intail,inaff] = parts_containing_point(h,point);
% if selected need to consider affordances too
if intail>0 || (isequal(h.Selected,'on') && inaff>0)
    on=true;
end

%-----------------------------------------------------------------------%
function inaff = affordance_at_point(h,point)

[intail,inaff] = parts_containing_point(h,point);

%----------------------------------------------------------------%
function [intail,inaff] = parts_containing_point(h,point)

fig = ancestor(h,'figure');
scribeax = handle(get(h,'Parent'));
% initial values
intail=0;
inaff=0;
% get pixel point position
ppos = scribeax.methods('getpixelpos');
ppoint(1) = point(1)*ppos(3);
ppoint(2) = point(2)*ppos(4);

R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','pixel',fig);
R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','pixel',fig);
PX = [R1(3) R2(3)];
PY = [R1(4) R2(4)];

% test if mouse is over tail
if (PX(1)<=ppoint(1)&&PX(2)>=ppoint(1) || PX(2)<=ppoint(1)&&PX(1)>=ppoint(1)) && ...
        (PY(1)<=ppoint(2)&&PY(2)>=ppoint(2) || PY(2)<=ppoint(2)&&PY(1)>=ppoint(2))
    % point is within rectangular bounds of line
    if isequal(PX(1),PX(2)) && isequal(PX(1),ppoint(1)) || ...
            abs(ppoint(2) - (PY(1) + (diff(PY)/diff(PX))*(ppoint(1) - PX(1)))) < 2
        % line is vertical and point has same x (or) y calculated at x of
        % point from point and slope of line is 0 or 1 pixels from actual y
        % of point
        intail=1;
    end
end
% test if mouse over affordance
afsize = h.Afsiz/2;
% affordance points
afpt = [PX(1),PY(1);PX(2),PY(2)];
k=1;
while ~inaff && k<=2
    if all(abs(ppoint(:)'-afpt(k,:))<afsize)
        % point within half affordance size from affordance center.
        inaff = k;
    end
    k=k+1;
end

%-----------------------------------------------------------------------%
function updateXYData(h)

fig = ancestor(h,'figure');
scribeax = handle(get(h,'Parent'));

% Get pixel position of overlay ax
ppos = scribeax.methods('getpointpos');

R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','points',fig);
R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','points',fig);
PX = [R1(3) R2(3)];
PY = [R1(4) R2(4)];

% Angle of arrow
dx = PX(2) - PX(1);
dy = PY(2) - PY(1);
theta = atan2(dy,dx);
costh = cos(theta);
sinth = sin(theta);
% length of whole arrow in points
PAL = sqrt((abs(PX(1) - PX(2)))^2 + (abs(PY(1) - PY(2)))^2);

x = [0,PAL];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by h.X(1),h.Y(1).
xx = x.*costh - y.*sinth + PX(1);
yy = x.*sinth + y.*costh + PY(1);
% convert to normalized
if ppos(3)>0 & ppos(4)>0
    xx = xx ./ ppos(3);
    yy = yy ./ ppos(4);
end
set(double(h.Tail),'xdata',xx,'ydata',yy);

h.setidentity;

%-----------------------------------------------------------------------%
function setmovemode(h, mode)

h.MoveMode = mode;
fig = ancestor(h,'figure');
scribecursors(fig,mode);
point = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],...
                         get(fig,'Units'),'normalized',fig);
point = point(3:4);

switch mode
    case 0
    case 1
    case 2
    case 3
    case 4
        set(h,'moveX0',point(1));
        set(h,'moveY0',point(2));
    case 5
    case 6
    case 7
    case 8
    case 9
end

%-----------------------------------------------------------------------%
function bup(h,varargin)
fig = ancestor(h,'figure');
scribecursors(fig,0)
% be sure toggle is off
arrowtogg = uigettoolbar(fig,'Annotation.Arrow');
if ~isempty(arrowtogg)
    set(arrowtogg,'state','off');
end

%-----------------------------------------------------------------------%
function bdown(h)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
if strcmpi('off',scribeax.InteractiveCreateMode)
  scribeax.methods('setselectedshape',h);
  if isequal(scribeax.PinMode,'on')
    scribeax.methods('setselectedshape',h);
    pin_at_currentpoint(h);
    set(fig,'WindowButtonDownFcn',{graph2dhelper('scribemethod'),fig,'wbdown',0});
    set(fig,'WindowButtonMotionFcn',{graph2dhelper('scribemethod'),fig,'wbmotion'});
    scribecursors(fig,0);
    % be sure toggle is off
    pintogg = uigettoolbar(fig,'Annotation.Pin');
    set(pintogg,'state','off');
    scribeax.PinMode ='off';
  else
    % if pinned and control is not pressed, set pointer to no way and
    % clear the windowbuttonmotionfcn (to be reset upon buttonup in the
    % scribeaxes wbup function)
    point = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],...
                           get(fig,'Units'),'normalized',fig);
    point = point(3:4);
    h.MoveMode=1;
    set(h,'moveX0',point(1));
    set(h,'moveY0',point(2));
    scribecursors(fig,1);
  end
end

%-----------------------------------------------------------------------%
function srbdown(h,n)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
if strcmpi('off',scribeax.InteractiveCreateMode)
  scribeax.methods('setselectedshape',h);
  if isequal(scribeax.PinMode,'on')
    pin_at_currentpoint(h);
    set(fig,'WindowButtonDownFcn',{graph2dhelper('scribemethod'),fig,'wbdown',0});
    set(fig,'WindowButtonMotionFcn',{graph2dhelper('scribemethod'),fig,'wbmotion'});
    scribecursors(fig,0);
    % be sure toggle is off
    pintogg = uigettoolbar(fig,'Annotation.Pin');
    set(pintogg,'state','off');
    scribeax.PinMode ='off';
  else
    h.MoveMode=n+1;
    scribecursors(fig,1);
  end
end

%-----------------------------------------------------------------------%
function set_last_position(h)

h.Xlast = h.X;
h.Ylast = h.Y;

%-----------------------------------------------------------------------%
function undo_last_move(h)

if ~isempty(h.Xlast) && ~isempty(h.Ylast)
    xl = h.X;
    yl = h.Y;
    h.X = h.Xlast;
    h.Y = h.Ylast;
    h.Xlast = xl;
    h.Ylast = yl;
end

%-------------------------------------------------------%
function pin_at_point(h,point)

fig = ancestor(h,'figure');
% find axes - if any - at that point
axlist = findobj(fig,'type','axes');
pinax = [];
for i=1:length(axlist)
  if 1==pointinaxes(axlist(i),point) && ~isappdata(axlist(i),'NonDataObject')
    pinax = axlist(i);
  end
end    
d1 = sqrt(  (point(1) - h.X(1))^2 + (point(2) - h.Y(1))^2  );
d2 = sqrt(  (point(1) - h.X(2))^2 + (point(2) - h.Y(2))^2  );
if d1<d2 
  n = 1;
else
  n = 2;
end
pins = h.Pin;
pinsrect = h.Pinrect;
existing_pin = [];
for pin = pins
  if isequal(getappdata(pin,'LineEndpoint'),n)
    existing_pin = pin;
  end
end
if isempty(pinax)
  delete(existing_pin);
else
  % can't pin to object if no object returned from hittest or if the
  % object returned is part of a scribe object (parent has shapetype
  % property).
  set(double(h.Tail),'hittest','off');
  if isprop(h,'Heads') && ~isempty(h.Heads)
    set(double(h.Heads),'hittest','off');
  end
  set(double(h.Srect),'hittest','off');
  pixpt = hgconvertunits(fig,[0 0 point],'normalized','pixels',fig);
  obj=hittest(fig,pixpt(3:4));
  set(double(h.Tail),'hittest','on');
  if isprop(h,'Heads') && ~isempty(h.Heads)
    set(double(h.Heads),'hittest','on');
  end
  set(double(h.Srect),'hittest','on');
  pinobj = [];
  if ~isempty(obj) && ~isprop(handle(get(obj,'parent')),'shapetype') && ...
        ~strcmpi(get(obj,'tag'),'DataTipMarker')
    type = get(obj,'type');
    if strcmpi(type,'surface')||strcmpi(type,'patch')||strcmpi(type,'line')
      pinobj = obj;
    end
  end
  if ~isempty(existing_pin)
    methods(handle(existing_pin),'repin',point,pinax,pinobj);
  else
    existing_pin = double(scribe.scribepin('Parent',pinax,'Target', ...
                                         h,'PinnedObject',pinobj));
    pins = [pins existing_pin];
    setappdata(existing_pin,'LineEndpoint',n);
    pin = line('XData', point(1), 'YData', point(2), 'LineWidth', 0.01, 'Color', 'k', ...
                  'Marker','square','Markersize',4,'MarkerFaceColor','k','MarkerEdgeColor','y','Visible','on',...
                  'parent',double(h));
    uic = uicontextmenu('Parent',fig,'HandleVisibility','off');
    uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
           {graph2dhelper('scribecallback'),'unpin_scribepin',h});
    set(pin,'uicontextmenu',uic);
    setappdata(pin,'ScribeGroup',h);
    set(pin,'ButtonDownFcn',{graph2dhelper('scribemethod'),double(pin),'pinbdown',1});
    pinsrect = [pinsrect pin];
  end
  if ~isempty(pinobj)
    figpt = hgconvertunits(fig,pixpt,'pixels',get(fig,'Units'),0);
    set(fig,'CurrentPoint',figpt(3:4));
    [vint,vert,indx] = vertexpicker(handle(pinobj),'-force');
    if ~isempty(vint)
      vert=vint;
    end
    set(existing_pin,'Units','data')
    set(existing_pin,'Position',vert);
  else
    ptpoint = hgconvertunits(fig,[0 0 point],'normalized','points',fig);
    axpos = hgconvertunits(fig,get(pinax,'Position'),...
                           get(pinax,'Units'),'points',get(pinax,'Parent'));
    set(existing_pin,'Units','points');
    set(existing_pin,'Position',[ptpoint(3:4)-axpos(1:2) 0]);
    set(existing_pin,'Units','data');
  end
  set(existing_pin,'enable','on');
  h.Pin = pins;
  h.Pinrect = pinsrect;
end  

%-----------------------------------------------------------------------%
function pin_at_currentpoint(h)
    
fig = ancestor(h,'figure');
point = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],...
                       get(fig,'Units'),'normalized',fig);
point = point(3:4);
pin_at_point(h,point);

%-----------------------------------------------------------------------%
function arrow_unpinhead(h,n)

pins = h.Pin;
existing_pin = [];
for pin = pins
  if isequal(getappdata(pin,'LineEndpoint'),n)
    existing_pin = pin;
  end
end
if nargin==2
  if ~isempty(existing_pin)
    delete(existing_pin);
  end
else
  scribeax = handle(get(h,'Parent'));
  point = methods(scribeax,'get_current_normalized_point');
  d1 = sqrt(  (point(1) - h.X(1))^2 + (point(2) - h.Y(1))^2  );
  d2 = sqrt(  (point(1) - h.X(2))^2 + (point(2) - h.Y(2))^2  );
  if abs(d1/d2)>4 
    arrow_unpinhead(h,2);
  elseif abs(d2/d1)>4
    arrow_unpinhead(h,1);
  else
    arrow_unpinhead(h,1);
    arrow_unpinhead(h,2);
  end
end  

%-----------------------------------------------------------------------%
function unpinheads(h)

arrow_unpinhead(h,1);
arrow_unpinhead(h,2);
    
%-----------------------------------------------------------------------%
function pinhead(h,n)

if nargin==2
    h.methods('pin_at_current_position',n);
else
    scribeax = handle(get(h,'Parent'));
    point = methods(scribeax,'get_current_normalized_point');
    d1 = sqrt(  (point(1) - h.X(1))^2 + (point(2) - h.Y(1))^2  );
    d2 = sqrt(  (point(1) - h.X(2))^2 + (point(2) - h.Y(2))^2  );
    if abs(d1/d2)>4 
        arrow_unpinhead(h,2);
    elseif abs(d2/d1)>4
        arrow_pinhead(h,1);
    else
        arrow_pinhead(h,1);
        arrow_pinhead(h,2);
    end
end


%-----------------------------------------------------------------------%
function pinheads(h)

pinhead(h,1);
pinhead(h,2);

%-----------------------------------------------------------------------%
function pin_at_current_position(h,n)

% calculate normalized position of pin
point = [h.X(n) h.Y(n)];
pin_at_point(h,point);

%-----------------------------------------------------------------------%
function pinbdown(h,n)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
if strcmpi('off',scribeax.InteractiveCreateMode)    
    scribeax.methods('setselectedshape',h);
    h.MoveMode=n+1;
    scribecursors(fig,10);
end

%-----------------------------------------------------------------------%
function move(h,point)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');
pins = h.Pin;
pins(~ishandle(pins)) = [];
pinPositions = [];
if ~isempty(pins) 
  for pin = pins
    pinPositions(end+1) = getappdata(pin,'LineEndpoint');
  end
end

if isequal('on',getappdata(fig,'scribegui_snaptogrid')) && ...
      isappdata(fig,'scribegui_snapgridstruct')
  snapmove(h,point);
else
  % calculate new X and Y positions for arrow from
  % moveX0 and moveY0 and current point
  X(1) = h.X(1) + (point(1) - h.MoveX0);
  Y(1) = h.Y(1) + (point(2) - h.MoveY0);
  X(2) = h.X(2) + (point(1) - h.MoveX0);
  Y(2) = h.Y(2) + (point(2) - h.MoveY0);
  if ~isequal(X,h.X) || ~isequal(Y,h.Y)
    h.ObservePos = 'off';
    h.X = X;
    h.Y = Y;
    h.ObservePos = 'on';
    % set MoveX0 and MoveY0 to current point
    set(h,'MoveX0',point(1));
    set(h,'MoveY0',point(2));
    methods(h,'updateXYData');
    updateaffordances(h);
  end
end
if ~isempty(pinPositions)
  for pos = pinPositions
    pin_at_current_position(h,pos);
  end
end
  
%-----------------------------------------------------------------------%
function snapmove(h,point)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');

% Get grid structure values
gridstruct = getappdata(fig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

% Initialize pre-move pixel positions
R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','pixels',fig);
R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','pixels',fig);
EPX = [R1(3) R2(3)];
EPY = [R1(4) R2(4)];
PX=sum(EPX)/2; PY=sum(EPY)/2;

% Get pixel position of overlay ax
ppos = scribeax.methods('getpixelpos');

% Initial moved normal position of center
X = sum(h.X)/2 + (point(1) - h.MoveX0);
Y = sum(h.Y)/2 + (point(2) - h.MoveY0);
% Initial moved pixel position of center
IPX = X*ppos(3);
IPY = Y*ppos(4);

% Width and Height of surrounding box
PRX = abs(EPX(2) - EPX(1));
PRY = abs(EPY(2) - EPY(1));

% Calculate the Snap-to positions.
switch snaptype
    case 'top'
        SX = IPX;
        SY = IPY + PRY/2;
    case 'bottom'
        SX = IPX;
        SY = IPY - PRY/2;
    case 'left'
        SX = IPX - PRX/2;
        SY = IPY;
    case 'right'
        SX = IPX + PRX/2;
        SY = IPY;
    case 'center'
        SX = IPX;
        SY = IPY;
    case 'topleft'
        SX = IPX - PRX/2;
        SY = IPY + PRY/2;
    case 'topright'
        SX = IPX + PRX/2;
        SY = IPY + PRY/2;
    case 'bottomleft'
        SX = IPX - PRX/2;
        SY = IPY - PRY/2;
    case 'bottomright'
        SX = IPX + PRX/2;
        SY = IPY - PRY/2;
end

xoff = mod(SX,xspace);
yoff = mod(SY,yspace);
if xoff>(xspace/2)
    xoff = xoff - xspace;
end
if yoff>(yspace/2)
    yoff = yoff - yspace;
end

update=false;
% Calculate new center X
if xoff < influ % within influence do a snap move
    % get snapped center x
    switch snaptype
        case {'top','bottom','center'}
            PX = (round(SX/xspace) * xspace);
        case {'left','topleft','bottomleft'}
            PX = (round(SX/xspace) * xspace) + PRX/2;
        case {'right','topright','bottomright'}
            PX = (round(SX/xspace) * xspace) - PRX/2;
    end
    if ~isequal(sum(EPX)/2,PX)
        % update the move point
        h.MoveX0 = point(1) + ((PX - IPX)/ppos(3));
        update=true;
    end
elseif ~isequal(IPX,sum(EPX)/2) % otherwise a normal move
    PX = IPX;
    h.MoveX0 = point(1);
    update=true;
end

% Calculate new center Y
if yoff < influ
    % switch again here for snaptype
    switch snaptype
        case {'top','topleft','topright'}
            PY = (round(SY/yspace) * yspace) - PRY/2;
        case {'bottom','bottomleft','bottomright'}
            PY = (round(SY/yspace) * yspace) + PRY/2;
        case {'left','right','center'}
            PY = (round(SY/yspace) * yspace);
    end
    if ~isequal(sum(EPY)/2,PY)
        % update the move point
        h.MoveY0 = point(2) + ((PY - IPY)/ppos(4));
        update=true;
    end
elseif ~isequal(IPY,sum(EPY)/2)
    PY = IPY;
    h.MoveY0 = point(2);
    update=true;
end

% Update the Object if needed
if update
    h.ObservePos = 'off';
    if EPX(1)<EPX(2)
        EPX(1) = PX - PRX/2;
        EPX(2) = PX + PRX/2;
    else
        EPX(2) = PX - PRX/2;
        EPX(1) = PX + PRX/2;
    end
    if EPY(1)<EPY(2)
        EPY(1) = PY - PRY/2;
        EPY(2) = PY + PRY/2;
    else
        EPY(2) = PY - PRY/2;
        EPY(1) = PY + PRY/2;
    end
    R1 = hgconvertunits(fig,[0 0 EPX(1) EPY(1)],'pixels','normalized',fig);
    R2 = hgconvertunits(fig,[0 0 EPX(2) EPY(2)],'pixels','normalized',fig);
    X = [R1(3) R2(3)];
    Y = [R1(4) R2(4)];
    h.X = X;
    h.Y = Y;

    h.ObservePos = 'on';
    methods(h,'updateXYData');
    updateaffordances(h);
end

%-----------------------------------------------------------------------%
function resize(h,point)

fig = ancestor(h,'figure');
pins = h.Pin;
pins(~ishandle(pins)) = [];
pinPositions = [];
if ~isempty(pins) 
  for pin = pins
    pinPositions(end+1) = getappdata(pin,'LineEndpoint');
  end
end
if ~isequal(h.MoveMode,10) && ...
        isequal('on',getappdata(fig,'scribegui_snaptogrid')) && ...
        isappdata(fig,'scribegui_snapgridstruct')
    snapresize(h,point);  
else
    h.ObservePos = 'off';
    if h.MoveMode > 1   
        % move the appropriate x/y values
        switch h.MoveMode
            case 2
                h.X(1) = point(1);
                h.Y(1) = point(2);
            case 3
                h.X(2) = point(1);
                h.Y(2) = point(2);
            otherwise
                return;
        end
    end
    methods(h,'updateXYData');
    updateaffordances(h);
    h.ObservePos = 'on';
end
if ~isempty(pinPositions)
  for pos = pinPositions
    pin_at_current_position(h,pos);
  end
end

%-----------------------------------------------------------------------%
function snapresize(h,point)

scribeax = handle(get(h,'Parent'));
fig = ancestor(scribeax,'figure');

% Get grid structure values
gridstruct = getappdata(fig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

% Get pixel position of overlay ax
ppos = scribeax.methods('getpixelpos');
% Initialize pre-move pixel positions
R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','pixels',fig);
R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','pixels',fig);
X = [R1(3) R2(3)];
Y = [R1(4) R2(4)];
oldX = X;
oldY = Y;

ysnap=false; xsnap=false;

switch h.MoveMode
    case 2
        X(1) = point(1)*ppos(3);
        Y(1) = point(2)*ppos(4);
        xoff = mod(X(1),xspace);
        yoff = mod(Y(1),yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            X(1) = (round(X(1)/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            Y(1) = (round(Y(1)/yspace) * yspace);
        end
    case 3
        X(2) = point(1)*ppos(3);
        Y(2) = point(2)*ppos(4);
        xoff = mod(X(2),xspace);
        yoff = mod(Y(2),yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            X(2) = (round(X(2)/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            Y(2) = (round(Y(2)/yspace) * yspace);
        end
    otherwise
        return;
end

if ~isequal(oldX,X) || ~isequal(oldY,Y)
    h.ObservePos = 'off';
    R1 = hgconvertunits(fig,[0 0 X(1) Y(1)],'pixels','normalized',fig);
    R2 = hgconvertunits(fig,[0 0 X(2) Y(2)],'pixels','normalized',fig);
    X = [R1(3) R2(3)];
    Y = [R1(4) R2(4)];
    h.X = X;
    h.Y = Y;
    h.ObservePos = 'on';
    methods(h,'updateXYData');
    updateaffordances(h);
end

%-----------------------------------------------------------------------%
function figupdateposition(h)
methods(h,'updateXYData');

%-----------------------------------------------------------------------%
function setselected(h,onoff)

pins = h.Pin;
pinsrect = h.Pinrect;
if strcmpi(onoff,'off')
    set(h,'selected','off');
    % make affordances inisible
    afrects = h.Srect;
    for i=1:2
        af = double(afrects(i));
        set(af,'visible','off');
    end
    h.Srect = afrects;    
    % and the pin affordances
    if ~isempty(pinsrect) && ~isempty(pins) && ishandle(pins(1))
        afrects = pinsrect(1);
        for i=1:1
            af = double(afrects(i));
            set(af,'visible','off');
        end
        pinsrect(1) = afrects;
    end
    % and the pin affordances
    if ~isempty(pinsrect) && length(pins)>1 && ishandle(pins(2))
        afrects = pinsrect(2);
        for i=1:1
            af = double(afrects(i));
            set(af,'visible','off');
        end
        pinsrect(2) = afrects;
    end   
elseif ~isequal(h.Selected,'on')    
    set(h,'selected','on');
    % make affordances visible and set buttondown fcn 
    afrects = h.Srect;
    for i=1:2
        af = double(afrects(i));
        set(af,'visible','on');
    end
    h.Srect = afrects;    
    % and the pin affordances
    if ~isempty(pinsrect) && ~isempty(pins) && ishandle(pins(1))
        afrects = pinsrect(1);
        for i=1:1
            af = double(afrects(i));
            set(af,'visible','on');
        end
        pinsrect(1) = afrects;
    end
    % and the other pin affordance
    if ~isempty(pinsrect) && length(pins)>1 && ishandle(pins(2))
        afrects = pinsrect(2);
        for i=1:1
            af = double(afrects(i));
            set(af,'visible','on');
        end
        pinsrect(2) = afrects;
    end
end

%-----------------------------------------------------------------------%
function updateaffordances(h)

pins = h.Pin;
pinsrect = h.Pinrect;
set(double(h.Srect(1)),'XData',h.X(1),'YData',h.Y(1));
set(double(h.Srect(2)),'XData',h.X(2),'YData',h.Y(2));
for m = 1:length(pins)
  if ishandle(pins(m))
    n = getappdata(pins(m),'LineEndpoint');
    set(double(pinsrect(m)),'XData',h.X(n),'YData',h.Y(n));
  end
end

%-----------------------------------------------------------------------%
function updatePinnedPosition(h)

%-----------------------------------------------------------------------%
function update_position_from_pintext(h,pin)

pins = h.Pin;
if isempty(pins), return; end
if nargin == 1
  if ishandle(pins(1))
    update_position_from_pintext(h,pins(1));
  end
  if length(pins)>=2 && ishandle(pins(2))
    update_position_from_pintext(h,pins(2));
  end
end
scribeax = handle(get(h,'Parent'));
ppos = scribeax.methods('getpointpos');
if ~isempty(pin) && ishandle(pin)
  n = getappdata(pin,'LineEndpoint');
  op = h.observePos;
  h.observePos='off';
  pt = pin;

  % preserve data position since switching units corrupts text
  pinax = ancestor(pt,'axes');
  dpos = get(pt,'position');
  if is2D(pinax)
    dpos(3) = 0;
  end
  set(pt,'position',dpos);
  set(pt,'units','points');
  pxpos = get(pt,'position');
  set(pt,'units','data');
  set(pt,'position',dpos);
  fig = ancestor(pinax,'figure');
  R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','points',fig);
  R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','points',fig);
  PX = [R1(3) R2(3)];
  PY = [R1(4) R2(4)];
  X = h.X;
  Y = h.Y;
  paxppos = hgconvertunits(fig,get(pinax,'Position'),...
                           get(pinax,'Units'),'points',get(pinax,'Parent'));
  % adding x and y pix positions of the pinned axes within scribe axes
  % to x and y pix positions of pin position in that axes
  PX(n) = pxpos(1) + paxppos(1);
  PY(n) = pxpos(2) + paxppos(2);
  X(n) = PX(n) / ppos(3);
  Y(n) = PY(n) / ppos(4);
  h.X = X;
  h.Y = Y;
  methods(h,'updateXYData'); 
  updateaffordances(h);
  h.ObservePos=op;
end

%-----------------------------------------------------------------------%
function addPixelOffsets(h)


%-----------------------------------------------------------------------%
function isin = pointinaxes(ax,p)
pos = get(ax,'Position');
isin=0;
if p(1)>=pos(1) && ...
        p(2)>=pos(2) && ...
        p(1)<=(pos(1)+pos(3)) && ...
        p(2)<=(pos(2)+pos(4))
        isin=1;    
end

%------------------------------------------------------------------%
function mcodeIgnoreHandle(this,h)

if isequal(double(this),double(h))
    res = false;
else
    res = true;
end

%------------------------------------------------------------------%
function mcodeConstructor(this,code,name)
% Specify constructor name used in code
setConstructorName(code,'annotation');

fig=ancestor(this,'figure');
arg=codegen.codeargument('IsParameter',true,'Name','figure','Value',fig);
addConstructorArgin(code,arg)

arg=codegen.codeargument('Value',name);
addConstructorArgin(code,arg);

% next args are position
arg=codegen.codeargument('Value',this.X,'Name','X');
addConstructorArgin(code,arg);
arg=codegen.codeargument('Value',this.Y,'Name','Y');
addConstructorArgin(code,arg);

ignoreProperty(code,'HitTest');
ignoreProperty(code,'X');
ignoreProperty(code,'Y');
ignoreProperty(code,'Parent');

% Generate remaining properties as property/value syntax
generateDefaultPropValueSyntax(code);