function val = methods(this,fcn,varargin)
% METHODS - methods for textbox class

%   Copyright 1984-2004 The MathWorks, Inc. 

if nargout>0
    val = [];
end

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
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

%-------------------------------------------------------%
function setmovemode(h, mode)

if isequal(h.Editable,'off')
    return;
end
fig = ancestor(h,'figure');
h.MoveMode = mode;
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

%-------------------------------------------------------%
function postdeserialize(h)

% delete children not created in constructor and children involved in
% pinning (Pintext, Pinrect).
goodchildren(1) = double(h.Rect);
goodchildren(2) = double(h.Text);

goodchildren(3:10) = double(h.Srect);

allchildren = get(double(h),'Children');
badchildren = setdiff(allchildren,goodchildren);
if ~isempty(badchildren)
    delete(badchildren);
end

updateXYData(h);

% repin if rect was pinned
if ~isempty(h.Pin)
    h.Pin = [];
    pin_at_current_position(h);
end

% set deselected (no saving selected)
setselected(h,'off');

%-------------------------------------------------------%
function bup(h)

% wrap text and resize box
resizetext(h,true); 

%-------------------------------------------------------%
function bdown(h)

if strcmpi(h.Editable,'off')
  return;
end
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi('off',scribeax.InteractiveCreateMode)
  th=h.Text;
  t=double(th);
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
    if strcmpi(get(fig,'selectiontype'),'open')
      beginedit(h);
    elseif current_point_in_margin(h) || strcmpi(h.Text.Editing,'off')
      % if not in editing or in editing but click in margin,
      % start a movement
      if strcmpi(h.Editing,'on')
        endedit(h);
      end
      h.MoveMode=1;
      point = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],...
                             get(fig,'Units'),'normalized',fig);
      point = point(3:4);
      set(h,'moveX0',point(1));
      set(h,'moveY0',point(2));
      scribecursors(fig,1);
    end
  end
  %    end
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
if isempty(pinax)        
  if ishandle(h.Pin)
    delete(h.Pin);
  end
else
  % get the pin point in the shape
  pos = hgconvertunits(fig,get(h,'Position'),...
                       get(h,'Units'),'normalized',fig);
  h.PinPosition = (point - pos(1:2))./pos(3:4);

  % can't pin to object if no object returned from hittest or if the
  % object returned is part of a scribe object (parent has shapetype
  % property).
  set(h.Rect,'hittest','off');
  set(h.Srect,'hittest','off');
  set(h.Text,'hittest','off');
  pixpt = hgconvertunits(fig,[0 0 point],'normalized','pixels',fig);
  obj=hittest(fig,pixpt(3:4));
  set(h.Rect,'hittest','on');
  set(h.Srect,'hittest','on');
  set(h.Text,'hittest','on');
  pinobj = [];
  if ~isempty(obj) && ~isprop(handle(get(obj,'parent')),'shapetype') && ...
        ~strcmpi(get(obj,'tag'),'DataTipMarker')
    type = get(obj,'type');
    if strcmpi(type,'surface')||strcmpi(type,'patch')||strcmpi(type,'line')
      pinobj = obj;
    end
  end

  if ~isempty(h.Pin) && ishandle(h.Pin)
    methods(h.Pin,'repin',point,pinax,pinobj);
  else
    h.Pin = scribe.scribepin('Parent',pinax,'Target',h,'PinnedObject',pinobj);
    pin = hg.line('XData', point(1), 'YData', point(2), 'LineWidth', 0.01, 'Color', 'k', ...
                  'Marker','square','Markersize',4,'MarkerFaceColor','k','MarkerEdgeColor','y','Visible','on',...
                  'parent',double(h));
    uic = uicontextmenu('Parent',fig,'HandleVisibility','off');
    uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
           {graph2dhelper('scribecallback'),'unpin_scribepin',h});
    set(pin,'uicontextmenu',uic);
    setappdata(double(pin),'ScribeGroup',h);
    set(double(pin),'ButtonDownFcn',{graph2dhelper('scribemethod'),double(pin),'pinbdown',1});
    h.Pinrect = pin;
  end
  if ~isempty(pinobj)
    figpt = hgconvertunits(fig,pixpt,'pixels',get(fig,'Units'),0);
    set(fig,'CurrentPoint',figpt(3:4));
    [vint,vert,indx] = vertexpicker(handle(pinobj),'-force');
    if ~isempty(vint)
      vert=vint;
    end
    set(h.Pin,'Units','data')
    set(h.Pin,'Position',vert);
  else
    ptpoint = hgconvertunits(fig,[0 0 point],'normalized','points',fig);
    axpos = hgconvertunits(fig,get(pinax,'Position'),...
                           get(pinax,'Units'),'points',get(pinax,'Parent'));
    set(h.Pin,'Units','points');
    set(h.Pin,'Position',[ptpoint(3:4)-axpos(1:2) 0]);
    set(h.Pin,'Units','data');
  end
  h.Pin.enable = 'on';
end  

%-------------------------------------------------------%
function pin_at_currentpoint(h)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
point = hgconvertunits(fig,[0 0 get(fig,'CurrentPoint')],...
                       get(fig,'Units'),'normalized',fig);
point = point(3:4);
pin_at_point(h,point);

%-------------------------------------------------------%
function pin_at_current_position(h)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
% calculate normalized position of pin
point = hgconvertunits(fig,get(h,'Position'),...
                       get(h,'Units'),get(fig,'Units'),fig);
point = point(1:2);
set(fig,'CurrentPoint',point);
point = hgconvertunits(fig,get(h,'Position'),...
                       get(h,'Units'),'normalized',fig);
point = point(1:2);
pin_at_point(h,point);

%-------------------------------------------------------%
function tbdown(h)

if strcmpi(h.Editable,'off')
    return;
end
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi('off',scribeax.InteractiveCreateMode)
    seltype=get(fig,'selectiontype');
    if ~strcmpi(scribeax.PinMode,'on') && strcmpi(seltype,'open') 
        beginedit(h);
    else
        bdown(h);
    end
end

%-------------------------------------------------------%
function srbdown(h,n)

if strcmpi(h.Editable,'off')
    return;
end
if strcmpi(h.Editing,'on')
    endedit(h);
end
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi('off',scribeax.InteractiveCreateMode)    
  scribeax.methods('setselectedshape',h);
  h.MoveMode=n+1;
  scribecursors(fig,n+1);
end

%-------------------------------------------------------%
function pinbdown(h,n)

if strcmpi(h.Editable,'off')
    return;
end
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi('off',scribeax.InteractiveCreateMode)
    scribeax.methods('setselectedshape',h);
    h.MoveMode=10;
    set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',10});
    scribecursors(fig,10);
end

%-------------------------------------------------------%
function over=mouseover(h,point)

over=0;
if strcmpi(h.Editable,'off')
    return;
end
[inrect,inaff] = parts_containing_point(h,point);
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi('off',scribeax.InteractiveCreateMode)
    if inaff>0
        over=inaff+1;
    elseif inrect>0
        % if not editing or editing but mouse is inside margin, show the
        % move cursor, otherwise cursor is pointer.
        if current_point_in_margin(h) || strcmpi(h.Text.Editing,'off')
            over = 1;
        else
            over = 0;
        end
    else
        over = -1;
    end
end

%-------------------------------------------------------%
function set_last_position(h)
%{
h.Xlast = h.X;
h.Ylast = h.Y;
%}

%-------------------------------------------------------%
function moved=has_moved(h)
%{
moved = ~isequal(h.Xlast,h.X) || ~isequal(h.Ylast,h.Y);
%}
moved = false; % for undo/redo - needs to just push move

%-------------------------------------------------------%
function undo_last_move(h)

%{
if ~isempty(h.Xlast) && ~isempty(h.Ylast)
    xl = h.X;
    yl = h.Y;
    h.X = h.Xlast;
    h.Y = h.Ylast;
    h.Xlast = xl;
    h.Ylast = yl;
end
%}

%-------------------------------------------------------%
function move(h,point)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

% calculate new X and Y positions for rectangle from
% moveX0 and moveY0 and current point

if isequal('on',getappdata(fig,'scribegui_snaptogrid')) && ...
      isappdata(fig,'scribegui_snapgridstruct')
  snapmove(h,point);
else
  pos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'normalized',fig);
  op=h.ObservePos;
  h.ObservePos = 'off';
  pos(1:2) = pos(1:2) + point - [h.MoveX0 h.MoveY0];
  pos = hgconvertunits(fig,pos,'normalized',get(h,'Units'),fig);
  set(h,'Position',pos);
  updateXYData(h);
  updateaffordances(h);
  updatePinnedPosition(h);
  h.ObservePos = op;
  h.MoveX0 = point(1);
  h.MoveY0 = point(2);
end

%-----------------------------------------------------------------------%
function snapmove(h,point)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

% Get grid structure values
gridstruct = getappdata(fig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

% Initialize pre-move pixel positions
hppos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'pixels',fig);
PX=hppos(1)+hppos(3)/2;
PY=hppos(2)+hppos(4)/2;

% Get pixel position of overlay ax
ppos = scribeax.methods('getpixelpos');

% Initial moved normal position
hpos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'normalized',fig);
X = hpos(1) + hpos(3)/2 + (point(1) - h.MoveX0);
Y = hpos(2) + hpos(4)/2 + (point(2) - h.MoveY0);
% Initial moved pixel position
IPX = X*ppos(3);
IPY = Y*ppos(4);

% Calculate the Snap-to positions.
switch snaptype
    case 'top'
        SX = IPX;
        SY = IPY + hppos(4)/2;
    case 'bottom'
        SX = IPX;
        SY = IPY - hppos(4)/2;
    case 'left'
        SX = IPX - hppos(3)/2;
        SY = IPY;
    case 'right'
        SX = IPX + hppos(3)/2;
        SY = IPY;
    case 'center'
        SX = IPX;
        SY = IPY;
    case 'topleft'
        SX = IPX - hppos(3)/2;
        SY = IPY + hppos(4)/2;
    case 'topright'
        SX = IPX + hppos(3)/2;
        SY = IPY + hppos(4)/2;
    case 'bottomleft'
        SX = IPX - hppos(3)/2;
        SY = IPY - hppos(4)/2;
    case 'bottomright'
        SX = IPX + hppos(3)/2;
        SY = IPY - hppos(4)/2;
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
            PX = (round(SX/xspace) * xspace) + hppos(3)/2;
        case {'right','topright','bottomright'}
            PX = (round(SX/xspace) * xspace) - hppos(3)/2;
    end
    if ~isequal(hppos(1)+hppos(3)/2,PX)
        % update the move point
        h.MoveX0 = point(1) + ((PX - IPX)/ppos(3));
        update=true;
    end
elseif ~isequal(IPX,hppos(1)+hppos(3)/2) % otherwise a normal move
    PX = IPX;
    h.MoveX0 = point(1);
    update=true;
end

% Calculate new center Y
if yoff < influ
    % switch again here for snaptype
    switch snaptype
        case {'top','topleft','topright'}
            PY = (round(SY/yspace) * yspace) - hppos(4)/2;
        case {'bottom','bottomleft','bottomright'}
            PY = (round(SY/yspace) * yspace) + hppos(4)/2;
        case {'left','right','center'}
            PY = (round(SY/yspace) * yspace);
    end
    if ~isequal(hppos(2)+hppos(4)/2,PY)
        % update the move point
        h.MoveY0 = point(2) + ((PY - IPY)/ppos(4));
        update=true;
    end
elseif ~isequal(IPY,hppos(2)+hppos(4)/2)
    PY = IPY;
    h.MoveY0 = point(2);
    update=true;
end

% Update the Object if needed
if update
    op = h.observePos;
    h.observePos = 'off';
    hppos(1:2) = [PX-hppos(3)/2 PY-hppos(4)/2];
    hppos = hgconvertunits(fig,hppos,'pixels',get(h,'Units'),fig);
    set(h,'Position',hppos);
    h.observePos = op;
    % make text fit - not during interactive creation
    if strcmpi('off',scribeax.InteractiveCreateMode)
      resizetext(h,false);
    end
    updateXYData(h);
    updateaffordances(h);
    updatePinnedPosition(h);
end

%-------------------------------------------------------%
function resize(h,point)
% resizing or whatever happens when an affordance is being moved.
% calc current left/right x and upper/lower y

ot=h.ObserveText;
op=h.ObservePos;
h.ObservePos = 'off';
h.ObserveText = 'off';

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

if ~isequal(h.MoveMode,10) && ...
      isequal('on',getappdata(fig,'scribegui_snaptogrid')) && ...
      isappdata(fig,'scribegui_snapgridstruct')
  snapresize(h,point);
else
  pos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'normalized',fig);
  XL = pos(1);
  XR = pos(1)+pos(3);
  YL = pos(2);
  YU = pos(2)+pos(4);
  if h.MoveMode > 1 && h.MoveMode < 10 
    % adjust move mode 
    h.MoveMode = scribeax.methods('find_rectangular_movemode',h,point);
    mode = h.MoveMode;
    if mode ~= 6 && mode ~= 8
      h.FitHeightToText = 'off';
    end
    switch mode
     case 2
      % e.g. moving the upper left affordance
      % changes the left x and upper y
      XL = point(1);
      YU = point(2);
     case 3
      XR = point(1);
      YU = point(2);
     case 4
      XR = point(1);
      YL = point(2);
     case 5
      XL = point(1);
      YL = point(2);
     case 6
      XL = point(1);
     case 7
      YU = point(2);
     case 8
      XR = point(1);
     case 9
      YL = point(2);
     otherwise
      return;
    end
    % calculate and set width height and x,y of resized rectangle
    pos = [min(XL,XR) min(YL,YU) max(eps,abs(XR-XL)) max(eps,abs(YU-YL))];
    set(h,'Position',pos);
    % make text fit - not during interactive creation
    if strcmpi('off',scribeax.InteractiveCreateMode)
      resizetext(h,false);
    end
    
  elseif isequal(h.moveMode,10)

    % moving the pin - changes PinX,PinY and DX, DY
    % calculate new PinX,PinY
    pnx = (point(1) - XL)/pos(3);
    pny = (point(2) - YL)/pos(4);
    % constrain PinX,PinY if out of bounds
    if pnx < 0
      pnx = 0;
    end
    if pnx > 1
      pnx = 1;
    end
    if pny < 0
      pny = 0;
    end
    if pny > 1
      pny = 1;
    end    
    h.PinPosition = [pnx pny];
    updatePinnedPosition(h);
  end
  updateXYData(h);
  updateaffordances(h);
end
% drawnow to force draw right away for snappy moving/resizing
h.ObservePos = op;
h.ObserveText = ot;
%drawnow expose

%-----------------------------------------------------------------------%
function snapresize(h,point)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
% adjust move mode
h.MoveMode = scribeax.methods('find_rectangular_movemode',h,point);

% Get grid structure values
gridstruct = getappdata(fig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

% Get pixel position of overlay ax
ppos = scribeax.methods('getpixelpos');

% Old positions
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'pixels',fig);
XL = pos(1);
XR = pos(1)+pos(3);
YL = pos(2);
YU = pos(2)+pos(4);

ysnap=false; xsnap=false;
switch h.MoveMode
    case 2
        % e.g. moving the upper left affordance
        % changes the left x and upper y
        XL = point(1)*ppos(3);
        YU = point(2)*ppos(4);
        xoff = mod(XL,xspace);
        yoff = mod(YU,yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XL = (round(XL/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YU = (round(YU/yspace) * yspace);
        end
    case 3
        XR = point(1)*ppos(3);
        YU = point(2)*ppos(4);
        xoff = mod(XR,xspace);
        yoff = mod(YU,yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XR = (round(XR/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YU = (round(YU/yspace) * yspace);
        end
    case 4
        XR = point(1)*ppos(3);
        YL = point(2)*ppos(4);
        xoff = mod(XR,xspace);
        yoff = mod(YL,yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XR = (round(XR/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YL = (round(YL/yspace) * yspace);
        end
    case 5
        XL = point(1)*ppos(3);
        YL = point(2)*ppos(4);
        xoff = mod(XL,xspace);
        yoff = mod(YL,yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XL = (round(XL/xspace) * xspace);
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YL = (round(YL/yspace) * yspace);
        end
    case 6
        XL = point(1)*ppos(3);
        xoff = mod(XL,xspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XL = (round(XL/xspace) * xspace);
        end
    case 7
        YU = point(2)*ppos(4);
        yoff = mod(YU,yspace);
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YU = (round(YU/yspace) * yspace);
        end
    case 8
        XR = point(1)*ppos(3);
        xoff = mod(XR,xspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            XR = (round(XR/xspace) * xspace);
        end
    case 9
        YL = point(2)*ppos(4);
        yoff = mod(YL,yspace);
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            YL = (round(YL/yspace) * yspace);
        end
    otherwise
        return;
end

% calculate and set width height and x,y of resized rectangle
pos = [XL YL abs(XR-XL) abs(YU-YL)];
pos = hgconvertunits(fig,pos,'pixels',get(h,'units'),fig);
set(h,'Position',pos);
% make text fit - not during interactive creation
if strcmpi('off',scribeax.InteractiveCreateMode)
    resizetext(h,false);
end
updatePinnedPosition(h);
updateXYData(h);
updateaffordances(h);

%-----------------------------------------------------------------------%
function figupdateposition(h)

if isempty(h.Pin) || ~ishandle(h.Pin)
  op=h.ObservePos;
  h.ObservePos = 'off';
  resizetext(h,true);
  h.ObservePos = op;
  updateaffordances(h);    
end
% drawnow to force draw right away for snappy moving/resizing
%drawnow expose

%-------------------------------------------------------%
function setselected(h,onoff)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if strcmpi(onoff,'off')
    if strcmpi(h.Editing,'on')
        endedit(h);
    end
    set(h,'selected','off');
    % after selected off it may have been deleted
    if ishandle(h) && isa(h,'scribe.textbox')
        % make affordances inisible

        if all(ishandle(h.Srect))
            set(h.Srect,'Visible','off');
        end

        % and the pin affordances
        if ~isempty(h.Pinrect) && ~isempty(h.Pin) &&...
                ishandle(h.Pinrect) && ishandle(h.Pin)
            afrects = h.Pinrect;
            set(h.Pinrect,'Visible','off');
        end
    end
elseif ~isequal(h.Selected,'on') && isequal(onoff,'on')
    set(h,'selected','on');
    % make affordances visible and set buttondown fcn (probably don't need to set fcn)
    if strcmpi(h.Editable,'off')
        return;
    end

    set(h.Srect,'Visible','on');

    % and the pin affordances
    if ~isempty(h.Pinrect) && ~isempty(h.Pin) && ishandle(h.Pin)
        set(h.Pinrect,'Visible','on');
    end
end

%-------------------------------------------------------%
function updateaffordances(h)

% normalized main rect upper left corner x and y
fig = ancestor(h,'figure');
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'normalized',fig);
ulx = pos(1);
rx = pos(3);
ry = pos(4);
uly = pos(2)+pos(4);
cx = pos(1)+pos(3)/2;
cy = pos(2)+pos(4)/2;
px = [ulx,ulx+rx,ulx+rx,ulx,ulx,cx,ulx+rx,cx];
py = [uly,uly,uly-ry,uly-ry,cy,uly,cy,uly-ry];

for k=1:8
    set(double(h.Srect(k)),'XData',px(k),'YData',py(k));
end

if ~isempty(h.Pin) && ishandle(h.Pin)
  pnx = pos(1)+h.PinPosition(1)*pos(3);
  pny = pos(2)+h.PinPosition(2)*pos(4);
  set(double(h.Pinrect(1)),'XData',pnx,'YData',pny);
end

%-------------------------------------------------------%
function on = ispointon(h,point)

on=false;
[inrect,inaff] = parts_containing_point(h,point);
% if selected need to consider affordances too
if inrect>0 || (isequal(h.Selected,'on') && inaff>0)
    on=true;
end

%-------------------------------------------------------%
function inaff = affordance_at_point(h,point)

[inrect,inaff] = parts_containing_point(h,point);

%-------------------------------------------------------%
function [inrect,inaff] = parts_containing_point(h,point)

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

% initial values
inrect=0;
inaff=0;

pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'pixels',fig);
XL = pos(1);
XR = pos(1)+pos(3);
YL = pos(2);
YU = pos(2)+pos(4);
XC = pos(1)+pos(3)/2;
YC = pos(2)+pos(4)/2;

% get pixel point position
ppos = scribeax.methods('getpixelpos');

px = point(1)*ppos(3);
py = point(2)*ppos(4);

a2 = h.Afsiz/2; % half pixel afsiz;

% test if mouse over rectangle
if XL <= px && px <= XR && ...
        YL <= py && py <= YU
    inrect = 1;
end
% test if mouse over affordances
% return when first one is found

% upper left
if XL - a2 <= px && px <= XL + a2 && ...
        YU - a2 <= py && py <= YU + a2
    inaff=1;
    return;
end
% upper right
if XR - a2 <= px && px <= XR + a2 && ...
        YU - a2 <= py && py <= YU + a2
    inaff=2;
    return;
end
% lower right
if XR - a2 <= px && px <= XR + a2 && ...
        YL - a2 <= py && py <= YL + a2
    inaff=3;
    return;
end
% lower left
if XL - a2 <= px && px <= XL + a2 && ...
        YL - a2 <= py && py <= YL + a2
    inaff=4;
    return;
end
% left
if XL - a2 <= px && px <= XL + a2 && ...
        YC - a2 <= py && py <= YC + a2
    inaff=5;
    return;
end
% top
if XC - a2 <= px && px <= XC + a2 && ...
        YU - a2 <= py && py <= YU + a2
    inaff=6;
    return;
end
% right
if XR - a2 <= px && px <= XR + a2 && ...
        YC - a2 <= py && py <= YC + a2
    inaff=7;
    return;
end
% bottom
if XC - a2 <= px && px <= XC + a2 && ...
        YL - a2 <= py && py <= YL + a2
    inaff=8;
    return;
end
% pin
if ~isempty(h.Pin) && ishandle(h.Pin)
    pnx = get(double(h.Pinrect(1)),'XData');
    pny = get(double(h.Pinrect(1)),'YData');
    if pnx(1) - a2 <= px && px <= pnx(1) + a2 && ...
            pny(1) - a2 <= py && py <= pny(1) + a2
        inaff = 9;
        return
    end
end


%-------------------------------------------------------%
function isin = current_point_in_margin(h)

isin = false;

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
point = scribeax.methods('get_current_pixel_point');

% rectangle center in pixel coords
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'pixels',fig);
XL = pos(1);
XR = pos(1)+pos(3);
YL = pos(2);
YU = pos(2)+pos(4);
XC = pos(1)+pos(3)/2;
YC = pos(2)+pos(4)/2;

if (point(1)>=XL && point(1)<=XL + h.Margin) && ...
   (point(2)>=YL && point(2)<=YU)
   isin=true;
elseif (point(1)<=XR && point(1)>=XR - h.Margin) && ...
   (point(2)>=YL && point(2)<=YU)
   isin=true;
elseif (point(2)<=YU && point(2)>=YU - h.Margin) && ...
   (point(1)>=XL && point(1)<=XR)
   isin=true;
elseif (point(2)>=YL && point(2)<=YL + h.Margin) && ...
   (point(1)>=XL && point(1)<=XR)
   isin=true;
end

%-------------------------------------------------------%
function updateXYData(h)
fig = ancestor(h,'figure');
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'normalized',fig);
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
XC = pos(1)+pos(3)/2;
YC = pos(2)+pos(4)/2;
[x,y,z]=meshgrid([x1,x2],[y1,y2],0);
set(double(h.Rect),'XData',x,'YData',y);
updatetextposition(h);

%-------------------------------------------------------%
% Move pin to the current PinPosition relative to Position
function updatePinnedPosition(h)

if ~isempty(h.Pin) && ishandle(h.Pin)
  fig = ancestor(h,'figure');
  pos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'normalized',fig);
  pt = pos(1:2) + get(h,'PinPosition').*pos(3:4);
  pin_at_point(h,pt);
end

%-------------------------------------------------------%
function update_position_from_pintext(h,pin)
if nargin == 1,
  pin = h.Pin;
end
if ~isempty(pin) && ishandle(pin)
  op = h.ObservePos;
  h.ObservePos='off';
  pt = double(pin);

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
  paxppos = hgconvertunits(fig,get(pinax,'Position'),...
                           get(pinax,'Units'),'points',get(pinax,'Parent'));
  % adding x and y pix positions of the pinned axes within scribe axes
  % to x and y pix positions of pin position in that axes
  pos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'), ...
                       'points',fig);
  pinpos = get(h,'PinPosition');
  pos(1:2) = pxpos(1:2) + paxppos(1:2) - get(h,'PinPosition').*pos(3:4);
  pos = hgconvertunits(fig,pos,'points',get(h,'Units'),fig);
  set(h,'Position',pos);
  resizetext(h,true);
  updateXYData(h);
  updateaffordances(h);
  h.ObservePos=op;
end

%-------------------------------------------------------%
function addPixelOffsets(h)

if ~isempty(h.PinnedAxes)
    h.PX = h.PX + h.DataXPixOffset;
    h.PY = h.PY + h.DataYPixOffset;
end

%-------------------------------------------------------%
function isin = pointinaxes(ax,p)
pos = get(ax,'Position');
isin=0;
if p(1)>=pos(1) & ...
        p(2)>=pos(2) & ...
        p(1)<=(pos(1)+pos(3)) & ...
        p(2)<=(pos(2)+pos(4)) ...
        isin=1;    
end
%-------------------------------------------------------%
function updatetextposition(h)

sw = h.Margin;
sh = h.Margin;
% pixels to adjust for text object visible position within their extent
% (i.e. they sit a little low in the box)
topadj = 2;

% calculate outer rect to text margin to be used when editing is on
dxy=0;
if strcmpi(h.Editing,'on')
    dxy = 0; % h.Afsiz/2;
end
fig = ancestor(h,'figure');
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'points',fig);
X = pos(1) + pos(3)/2 + dxy;
Y = pos(2) + pos(4)/2 + dxy;
W = pos(3) - 2*dxy;
H = pos(4) - 2*dxy;
set(double(h.Text),'units','points');

switch (h.VerticalAlignment)
    case 'top'
        switch (h.HorizontalAlignment)
            case 'left'
                set(double(h.Text),'Position',[X-W/2+sw,Y+H/2-sh+topadj,0]);
            case 'right'
                set(double(h.Text),'Position',[X+W/2-sw,Y+H/2-sh+topadj,0]);
            case 'center'
                set(double(h.Text),'Position',[X,Y+H/2-sh+topadj,0]);
        end
    case 'bot'
        switch (h.HorizontalAlignment)
            case 'left'
                set(double(h.Text),'Position',[X-W/2+sw,Y-H/2+sh+topadj,0]);
            case 'right'
                set(double(h.Text),'Position',[X+W/2-sw,Y-H/2+sh+topadj,0]);
            case 'center'
                set(double(h.Text),'Position',[X,Y-H/2+sh+topadj,0]);
        end
    case 'middle'
        switch (h.HorizontalAlignment)
            case 'left'
                set(double(h.Text),'Position',[X-W/2+sw,Y+topadj,0]);
            case 'right'
                set(double(h.Text),'Position',[X+W/2-sw,Y+topadj,0]);
            case 'center'
                set(double(h.Text),'Position',[X,Y,0]);
        end
end

%-------------------------------------------------------%
function resizetext(h,resizebox)

fig = ancestor(h,'figure');
if nargin>1 && ~resizebox
    doresize=false;
else
    doresize=true;
end
if doresize && strcmp(h.FitHeightToText,'off')
  doresize = false;
end
th=h.Text;
t=double(th);

str=cellstr(h.String);

if isempty(str)
    return;
end

% create cell array string to fit current box
sizes = strcellsizes(h,str);
ssize = strcellsizes(h,{' '});
% calc extra space in every width
onecharspace = double(strsize(h,{'A'}));
twocharspace = double(strsize(h,{'AA'}));
xspace = ((2*onecharspace(1)) - twocharspace(1))/2;
% initialize arrays and flags
dstr = cell(1,1);
ndlines = 0;
needxresize = false;
pos = hgconvertunits(fig,get(h,'Position'),get(h,'units'),...
                     'points',fig);
oldpos = pos;
NewPX = pos(1)+pos(3)/2;
NewPWidth = pos(3);
dims = size(sizes);

for i=1:dims(1); % looping through input lines (Cells)
    tystr = dstr;
    tystr{ndlines+1} = str{i,:};
    tysize = strsize(h,tystr);
    if sizes(i,1)<(pos(3) - 2*h.Margin + xspace)
        % if width of cell is less than width of box
        % just pass it along;
        ndlines = ndlines+1;
        dstr{ndlines} = str{i,:};
    else
        % else split it (the cell) up over multiple lines
        % get char counts and extents of words
        [nwords(i),words] = cellwords(str{i});
        w=1; %cell word count
        lw=1; %line word count
        llen=0; %line length
        lstr = ''; %line string
        newysize=false;
        while w<nwords(i)+1
            % get test string and its size (for x test)
            if lw==1
                tstr = [lstr,words{w}];
            else
                tstr = [lstr,' ',words{w}];
            end
            tsize = double(strsize(h,tstr));
            % y size test string
            if newysize
                tystr = dstr; 
                tystr{ndlines+1} = tstr;
                tysize = strsize(h,tystr);
                newysize=false;
            end
            if tsize(1) > pos(3) - 2*h.Margin
                % string size > width of textbox
                if llen==0 || strcmpi(h.FirstEdit,'on')
                    % if first word in line or if first time box is being
                    % edited (grow box width), need to calculate a resize
                    % for width.
                    needxresize = true;
                    NewPX = max(NewPX,pos(1) + tsize(1)/2 + h.Margin);
                    NewPWidth = max(NewPWidth,tsize(1) + 2*h.Margin);
                    % set line string to test string and increment cell
                    % word index;
                    lstr = tstr;
                    w = w+1;
                    if strcmpi(h.FirstEdit,'on')
                        % firstedit is on need to continue in line loop,
                        % so set line length to current string width and
                        % increment line words counter.
                        llen = tsize(1);
                        lw = lw+1;
                        if w>nwords(i)
                            % last word in line, finish up line.
                            ndlines = ndlines+1;
                            clstr={};
                            clstr = lstr;
                            dstr{ndlines} = clstr;
                            lstr = '';
                            llen=0;
                            lw=1;
                            newysize=true;
                        end
                    end
                end
                if strcmpi(h.FirstEdit,'off')
                    % if firstedit is off then finish up the
                    % line.
                    ndlines = ndlines+1;
                    clstr={};
                    clstr = lstr;
                    dstr{ndlines} = clstr;
                    lstr = '';
                    llen=0;
                    lw=1;
                    newysize=true;
                end
            else
                % string still fits in width so may continue line loop.
                % Set line length to current string width and line string
                % to test string.
                lstr = tstr;
                llen = tsize(1);
                if w==nwords(i)
                    % reached last word in cell, so finish up
                    ndlines = ndlines+1;
                    clstr={};
                    clstr = lstr;
                    dstr{ndlines} = clstr;
                    lstr = '';
                    llen=0;
                    lw=1;
                    newysize=true;
                else
                    lw = lw+1;
                end
                w = w+1;
            end
        end
    end
end

ysize = max(tysize(2),onecharspace(2)) + 2*h.Margin;
op=h.ObservePos;
ot=h.ObserveText;
% set new position with pos listener inactive
h.Observepos = 'off';
h.ObserveText = 'off';
if doresize
  pos(2) = pos(2)+pos(4)-ysize;
  pos(4) = ysize;
  % update x size if needed
  if needxresize
    pos(1) = NewPX-NewPWidth/2;
    pos(3) = NewPWidth;
  end
  pos = hgconvertunits(fig,pos,'points',get(h,'units'),fig);
  set(h,'Position',pos);
end
% update associated values
updateXYData(h);
updateaffordances(h);
set(t,'String',dstr);
h.ObserveText=ot;
h.ObservePos=op;

%-------------------------------------------------------%
function cstr=char2cell(h,str)

% creates cell array from char array
% reducing all white spaces to one char.

dims = size(str);
ncells = dims(1);
cstr = cell(ncells,1);
for i=1:ncells
    spaces = isspace(str(i,:));
    nrun=0;
    for j=1:length(spaces)
        if spaces(j)==1
            nrun = nrun+1;
            if nrun==1 || ...
                    (j>2 && strcmpi(str(i,j-2),'.') || ...
                    (j>2 && strcmpi(str(i,j-2),'''')) || ...
                    (j>2  && strcmpi(str(i,j-2),'?')) || ...
                    (j>2  && strcmpi(str(i,j-2),'!')))
                nrun = nrun + 1;
                spaces(j)=0;
            end
        else
            nrun=0;
        end
    end
    cstr{i} = str(i,~spaces(:));
end

%-------------------------------------------------------%
function size=strsize(h,str)
% gets extents of textbox with whole string

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
p = double(scribeax);
t = methods(scribeax,'get_temp_text');
set(t,...
    'FontAngle',h.FontAngle,...
    'FontName',h.FontName,...
    'FontWeight',h.FontWeight,...
    'Rotation',h.Rotation,...
    'String',str,...
    'Interpreter',h.Interpreter);
% be sure to set font units and size in correct order
set(t,'FontUnits',h.FontUnits)
set(t,'FontSize',h.FontSize)
set(t,'units','points');
normext = get(t,'extent');
size(1) = normext(3);
size(2) = normext(4); 

%-------------------------------------------------------%
function sizes=strcellsizes(h,str)
% gets x and y extents of strings in textbox
% string cell array.

if isempty(str)
    return;
end

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));

dims = size(str);
ncells = dims(1);

p = double(scribeax);
t = methods(scribeax,'get_temp_text');
set(t,...
    'FontAngle',h.FontAngle,...
    'FontName',h.FontName,...
    'FontWeight',h.FontWeight,...
    'Margin',1,...
    'Rotation',h.Rotation,...
    'Interpreter',h.Interpreter);
% be sure to set font units and size in correct order
set(t,'FontUnits',h.FontUnits)
set(t,'FontSize',h.FontSize)
p = get(t,'parent');
set(t,'units','points');
for i=1:ncells
    % create an invisible text box with string
    set(t,'String',str{i});
    normext = get(t,'extent');
    sizes(i,1) = normext(3);
    sizes(i,2) = normext(4); 
end


%-------------------------------------------------------%
function [w,sizes]=cellwordsandsizes(h,str)
% gets x and y extents and char lengths of 
% strings in textbox string cell.

fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
p = double(scribeax);
spaces = isspace(str(:));
nrun=0;
nw=0;
w=cell(1,1);
for j=1:length(spaces)
    if spaces(j)==0
        if nrun==0
            nw = nw+1;
        end
        nrun = nrun+1;
        w{nw}(nrun)=str(j);
    elseif  (j>1 && strcmpi(str(j-1),'.')) || ...
            (j>1 && strcmpi(str(j-1),'''')) || ...
            (j>1 && strcmpi(str(j-1),'?')) || ...
            (j>1 && strcmpi(str(j-1),'!'))
        nrun = nrun + 1;
        w{nw}(nrun)=str(j);
    else
        nrun=0;
    end
end

t = methods(scribeax,'get_temp_text');
set(t,...
    'FontAngle',h.FontAngle,...
    'FontName',h.FontName,...
    'FontWeight',h.FontWeight,...
    'Rotation',h.Rotation,...
    'Interpreter',h.Interpreter);
% be sure to set font units and size in correct order
set(t,'FontUnits',h.FontUnits)
set(t,'FontSize',h.FontSize)
%fig = ancestor(h,'figure');
%pp = hgconvertunits(fig,get(p,'Position'),get(p,'Units'),...
%                    'pixels',fig);
set(t,'units','points');
for i=1:nw
    % create an invisible text box with string
    set(t,'String',w{i});
    normext = get(t,'extent');
    sizes(i,1) = normext(3);
    sizes(i,2) = normext(4);
    sizes(i,3) = length(w{i});
end
%delete(t);

%-------------------------------------------------------%
function [nw,w]=cellwords(str)

spaces = isspace(str(:));
nrun=0;
nw=0;
w=cell(1,1);
for j=1:length(spaces)
    if spaces(j)==0
        if nrun==0
            nw = nw+1;
        end
        nrun = nrun+1;
        w{nw}(nrun)=str(j);
    elseif  (j>1 && strcmpi(str(j-1),'.')) || ...
            (j>1 && strcmpi(str(j-1),'''')) || ...
            (j>1 && strcmpi(str(j-1),'?')) || ...
            (j>1 && strcmpi(str(j-1),'!'))
        nrun = nrun + 1;
        w{nw}(nrun)=str(j);
    else
        nrun=0;
    end
end

%-------------------------------------------------------%
function beginedit(h)

if ~strcmpi(h.Editing,'on')
    fig = ancestor(h,'figure');
    scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
    h.Editing='on';
    updatetextposition(h);
end
h.Text.Editing = 'on';

%-------------------------------------------------------%
function endedit(h)

if strcmpi(h.Editing,'on')
    h.Editing = 'off';
    te = h.Text;
    % remove special characters
    str = deblank(get(te,'String'));    
    % handle case in which str is a char array
    if ~iscell(str)
        strc = {};
        strc{1} = str;
        str = strc;
    end
    h.String = str;
    resizetext(h,true);
    updatetextposition(h);
    h.FirstEdit='off';
end

%-------------------------------------------------------%
