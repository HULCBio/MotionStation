function val = methods(this,fcn,varargin)
% METHODS - methods for scribe axes class

%   Copyright 1984-2004 The MathWorks, Inc. 

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

%--------------------------------------------------------------------%
% get scribeaxes Position in pixels
function pos=getpixelpos(scribeax)
pos = hgconvertunits(ancestor(scribeax,'figure'),...
                     get(scribeax,'Position'),get(scribeax,'Units'),...
                     'pixels',get(scribeax,'Parent'));

%--------------------------------------------------------------------%
% get scribeaxes Position in points
function pos=getpointpos(scribeax)
pos = hgconvertunits(ancestor(scribeax,'figure'),...
                     get(scribeax,'Position'),get(scribeax,'Units'),...
                     'points',get(scribeax,'Parent'));

%--------------------------------------------------------------------%
function wbmotion(scribeax)

fig = ancestor(scribeax,'figure');
if ~isappdata(fig,'scribeActive')
    scribecursors(fig,0);
    return;
end
cshape = scribeax.CurrentShape;
if ~ishandle(cshape), cshape = []; end

point = get_current_normalized_point(scribeax);

if isempty(cshape)
    MoveType = 0;
    scribeobj = false;
elseif isappdata(double(cshape),'scribeobject')
    MoveType = cshape.moveMode;
    scribeobj = true;
else
    scribeobj = false;
    if isappdata(double(cshape),'scribemove_movetype');
        MoveType = getappdata(double(cshape),'scribemove_movetype');
    else
        MoveType = 0;
        setappdata(double(cshape),'scribemove_movetype',0);
    end
end
eventhandled = false;
if ~isempty(hggetbehavior(cshape,'Plotedit','-peek'))
  b = hggetbehavior(cshape,'Plotedit');
  cb = b.MouseMotionFcn;
  if iscell(cb)
    eventhandled = feval(cb{:},point);
  elseif ~isempty(cb)
    eventhandled = feval(cb,cshape,point);
  end
end
if eventhandled, return; end

% all scribe shapes must implement mouseover and move methods.
do_fix_selectobjs=false;
switch MoveType
 case 0 % mouseovers
  shapes = scribeax.Shapes;
  k = 1; 
  cursor = 0; % 0 means haven't found the hittest object yet
  while k<=length(shapes) && isequal(cursor,0)
    % only mouseover selected shapes 
    if strcmpi(shapes(k).selected,'on')
      cursor = methods(shapes(k),'mouseover',point);
    end
    k=k+1;
  end
  if isequal(cursor,0)
    ch = handle(get(fig,'Children'));
    k=1;
    while k<=length(ch) && isequal(cursor,0)
      if ~ishandle(ch(k))
        do_fix_selectobjs=true;
      elseif ~isempty(hggetbehavior(ch(k),'Plotedit','-peek'))
        b = hggetbehavior(ch(k),'Plotedit');
        cb = b.MouseOverFcn;
        if iscell(cb)
          cursor = feval(cb{:},point);
        elseif ~isempty(cb)
          cursor = feval(cb,ch(k),point);
        end
      end
      k=k+1;
    end
  end
  if isequal(cursor,0)
    objs = scribeax.SelectedObjects;
    if ~isempty(objs)
      k=1;
      while k<=length(objs) && isequal(cursor,0)
        if ~ishandle(objs(k))
          do_fix_selectobjs=true;
        elseif ~isprop(objs(k),'ShapeType')
          cursor = mouseover_nonscribeobject(scribeax,objs(k),point);
        end
        k=k+1;
      end
    end
  end

  % don't change the cursor if a long task is going on and
  % the user happens to move the mouse
  if ~strcmp(get(fig,'Pointer'),'watch')
    scribecursors(fig,cursor);
  end
  
 case 1 % clicking inside object and dragging
        % determine if ok to move
  if strcmpi(scribeax.MoveOK,'off')
    ppoint = get_current_pixel_point(scribeax);
    ppoint0 = scribeax.ClickPoint;
    if ~isempty(ppoint0) && (sum(abs(ppoint - ppoint0)) > ...
                             scribeax.MoveSensitivity)
      scribeax.MoveOK = 'on';
      % set up for undo move
      scribeax.MovedObjects = [];
      % scribe objects
      fixselectobjs(scribeax);
      shapes = scribeax.Shapes;
      for k=1:length(shapes)
        if strcmpi(shapes(k).selected,'on')
          scribeax.MovedObjects(end+1) = shapes(k);
          methods(handle(shapes(k)),'set_last_position');
        end
      end
      % non scribe objects
      objs = scribeax.SelectedObjects;
      for k=1:length(objs)
        h=double(objs(k))';
        if ~strcmpi(get(h,'type'),'figure') && ...
              isprop(h,'units') && ~isprop(h, 'ShapeType')
          scribeax.MovedObjects(end+1) = handle(objs(k));
          setappdata(h,'scribemove_lastpos',get(h,'position'));
        end
      end
    else
      return;
    end
  end
  % scribe objects
  shapes = scribeax.Shapes;
  for k=1:length(shapes)
    if strcmpi(shapes(k).selected,'on');
      shapes(k).methods('move',point);
    end
  end
  % nonscribe objects
  objs = scribeax.SelectedObjects;
  for k=1:length(objs)
    if ~ishandle(objs(k))
      do_fix_selectobjs=true;
    elseif isprop(objs(k),'units') && ~isprop(objs(k),'ShapeType')
      if ~isappdata(objs(k),'scribemove_oldunits')
        setappdata(objs(k),'scribemove_oldunits',get(objs(k),'units'));
        set(objs(k),'units','normalized');
      end
      move_nonscribeobject(objs(k),point,scribeax);
    end
  end   
 case {2,3,4,5,6,7,8,9,10} % clicking on an affordance and dragging
  if scribeobj
    cshape.methods('resize',point);
  elseif isprop(cshape,'units') && ~isprop(cshape,'ShapeType')
    resize_nonscribeobject(cshape,MoveType,point,scribeax);        
  end 
end
if do_fix_selectobjs
  fixselectobjs(scribeax);
end

%--------------------------------------------------------------------%
function wbup(scribeax,action)

fig = ancestor(scribeax,'figure');
shape = scribeax.CurrentShape;
point = get_current_normalized_point(scribeax);
ppoint = get_current_pixel_point(scribeax);
if ~isempty(shape)
    if isappdata(double(shape),'scribeobject')
        shape.moveMode = 0;
    else
        setappdata(double(shape),'scribemove_movetype',0);
    end
end
% allow custom button up
buphandled = false;
if ~isempty(shape) && ~isempty(hggetbehavior(shape,'Plotedit','-peek'))
  b = hggetbehavior(shape,'Plotedit');
  cb = b.ButtonUpFcn;
  if iscell(cb)
    buphandled = feval(cb{:},point);
  elseif ~isempty(cb)
    buphandled = feval(cb,shape,point);
  end
end
if buphandled, return; end
switch action
 case 0 % after move
  objs = scribeax.SelectedObjects;
  for k=1:length(objs)
    h=double(objs(k))';
    if ~strcmpi(get(h,'type'),'figure')
      % restore old units
      u = getappdata(h,'scribemove_oldunits');
      if ~isempty(u)
        set(h,'units',u)
        rmappdata(h,'scribemove_oldunits');
      end
    end
  end
  % resize textbox after move
  if ~isempty(shape) && ...
        isappdata(double(shape),'scribeobject') && ...
        strcmpi(shape.ShapeType,'textbox')
    shape.methods('bup');
  end
  if ~isequal(ppoint,scribeax.ClickPoint) && methods(scribeax,'has_moved')
    % if there has been a move, register unmove
    % Create command structure
    undocmd.Function = graph2dhelper('scribemethod');
    undocmd.Varargin = {double(scribeax),'undo_last_move'};
    undocmd.Name = 'Move';
    undocmd.InverseFunction = graph2dhelper('scribemethod');
    undocmd.InverseVarargin = {double(scribeax),'undo_last_move'};
    % Register with undo
    uiundo(fig,'function',undocmd);
  end
 case {1,2} % after making rectangle or ellipse
  h = shape;
  hpos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'pixels',fig);
  % if point hasn't moved, set to good dflt pixel 
  if sum(abs(ppoint - scribeax.ClickPoint)) <= 1
    hpos(3:4) = [50 50];
  else
    % even if there has been a move, if size is too small, set to minimum pixel size
    hpos(3:4) = max(hpos(3:4),[20 20]);
  end
  hpos = hgconvertunits(fig,hpos,'pixels',get(h,'Units'),fig);
  set(h,'Position',hpos);
  h.ObservePos = 'on';
  set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',0});
 case 3 % after making textbox
  h = shape;
  hpos = hgconvertunits(fig,get(h,'Position'),get(h,'Units'),'pixels',fig);
  % if point hasn't moved, set to good dflt pixel 
  useAutoFit = 'off';
  if sum(abs(ppoint - scribeax.ClickPoint)) <= 1
    hpos(3:4) = [90 30];
    useAutoFit = 'on';
  elseif any(hpos(3:4) < [30 25])
    % even if there has been a move, if size is too small, set to minimum pixel size
    hpos(3:4) = max(hpos(3:4),[30 25]);
    useAutoFit = 'on';
  end
  hpos = hgconvertunits(fig,hpos,'pixels',get(h,'Units'),fig);
  set(h,'Position',hpos);
  h.ObservePos = 'on';
  set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',0});
  % resize to one line
  h.methods('resizetext',true);
  set(h,'FitHeightToText',useAutoFit)
  h.methods('beginedit'); 
 case {4,5,6,7} %after making doublearrow,arrow,textarrow,line
  h = shape;
  % if point hasn't moved, set good dflt size
  if sum(abs(ppoint - scribeax.ClickPoint)) <= 5
    PX = [ppoint(1) - 30,ppoint(1) + 30];
    PY = [ppoint(2),ppoint(2)];
    p1 = hgconvertunits(fig,[0 0 PX(1) PY(1)],'pixels','normalized',fig);
    p2 = hgconvertunits(fig,[0 0 PX(2) PY(2)],'pixels','normalized',fig);
    h.X = [p1(3) p2(3)];
    h.Y = [p1(4) p2(4)];
  else
    % if size is too small, set to minimum pixel size
    R1 = hgconvertunits(fig,[0 0 h.X(1) h.Y(1)],'normalized','pixel',fig);
    R2 = hgconvertunits(fig,[0 0 h.X(2) h.Y(2)],'normalized','pixel',fig);
    PX = [R1(3) R2(3)];
    PY = [R1(4) R2(4)];
    if abs(PX(1) - PX(2)) + abs(PY(1) - PY(2)) < 30;
      PX(2) = PX(1) + 20;
      PY(2) = PY(1) + 20;
      p1 = hgconvertunits(fig,[0 0 PX(1) PY(1)],'pixels','normalized',fig);
      p2 = hgconvertunits(fig,[0 0 PX(2) PY(2)],'pixels','normalized',fig);
      h.X = [p1(3) p2(3)];
      h.Y = [p1(4) p2(4)];
    end
  end
  if action==6 % for textarrow
    set(h.Text,'Editing','on');
  end
  set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',0});       
 case 10
  methods(shape,'pin_at_currentpoint');
  set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',0});       
end
% restore keypress fcn
set(fig,'KeyPressFcn',{graph2dhelper('scribemethod'),fig,'kpress'});
set(fig,'WindowButtonMotionFcn',{graph2dhelper('scribemethod'),fig,'wbmotion'});
% turn create mode off
scribeax.InteractiveCreateMode = 'off';

if (action > 0) && (action < 8) && ishandle(shape)
  replace_selected_objects(scribeax,shape);
end

wbmotion(scribeax); % set pointer

seltype = get(fig,'selectiontype');

% open property editor if double clicking except for text,
% textarrow, and textbox
if strcmp(seltype,'open')
  cls = classhandle(shape);
  if ~strncmp(get(cls,'Name'),'text',4)
    propedit(shape);
  end
end

%--------------------------------------------------------------------%
function wbdown(scribeax,action)

shape = scribeax.CurrentShape;
fig = ancestor(scribeax,'figure');
set(fig,'KeyPressFcn','');

stackScribeLayersWithChild(scribeax,double(scribeax),true);

point = get_current_normalized_point(scribeax);
ppoint = get_current_pixel_point(scribeax);
scribeax.ClickPoint = ppoint;
scribeax.NClickPoint = point;

if action(1)>0 && ~isappdata(fig,'scribeActive')
  plotedit(fig,'on');
end

if action(1)==0
  clickedwindow(scribeax)
else
  % set window bdf to select mode
  set(fig,'WindowButtonDownFcn',{graph2dhelper('scribemethod'),fig,'wbdown',0});
  % get toggle and create object
  switch action(1)
   case 1
    fpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),'point',0);
    point(2) = point(2) - 10/fpos(4);
    h=scribe.scriberect(fig,'Position',[point(1) point(2) 0.001 0.001]);
    h.methods('setmovemode',4);
    togg = uigettoolbar(fig,'Annotation.InsertRectangle');
   case 2
    fpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),'point',0);
    point(2) = point(2) - 10/fpos(4);
    h=scribe.scribeellipse(fig,'Position',[point(1) point(2) 0.001 0.001]);
    h.methods('setmovemode',4);
    togg = uigettoolbar(fig,'Annotation.InsertEllipse');
   case 3
    fpos = hgconvertunits(fig,get(fig,'Position'),get(fig,'Units'),'point',0);
    point(2) = point(2) - 10/fpos(4);
    h=scribe.textbox(fig,'Position',[point(1) point(2) 0.001 0.001]);
    h.methods('setmovemode',4);
    togg = uigettoolbar(fig,'Annotation.InsertTextbox');
   case 4
    X(1) = point(1); X(2) = X(1) + .005;
    Y(1) = point(2); Y(2) = Y(1) + .005;
    h=scribe.doublearrow(fig,'X',X,'Y',Y,'headStyle','vback2',...
                         'head1Style','vback2','head2Style','vback2');
    h.methods('setmovemode',3);
    togg = uigettoolbar(fig,'Annotation.InsertDoubleArrow');
   case 5
    X(1) = point(1); X(2) = X(1) + .005;
    Y(1) = point(2); Y(2) = Y(1) + .005;
    h=scribe.arrow(fig,'X',X,'Y',Y,'HeadStyle','vback2');
    h.methods('setmovemode',3);
    togg = uigettoolbar(fig,'Annotation.InsertArrow');
   case 6
    X(1) = point(1); X(2) = X(1) + .005;
    Y(1) = point(2); Y(2) = Y(1) + .005;
    h=scribe.textarrow(fig,'X',X,'Y',Y,'HeadStyle','vback2');
    h.methods('setmovemode',3);
    togg = uigettoolbar(fig,'Annotation.InsertTextArrow');
   case 7
    X(1) = point(1); X(2) = X(1) + .005;
    Y(1) = point(2); Y(2) = Y(1) + .005;
    h=scribe.line(fig,'X',X,'Y',Y);
    h.methods('setmovemode',3);
    togg = uigettoolbar(fig,'Annotation.InsertLine');
  end
  if ~isempty(togg)
    set(togg,'state','off');
  end
  set(fig,'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',action(1)});
  set(fig,'WindowButtonMotionFcn',{graph2dhelper('scribemethod'),fig,'wbmotion'});
end

%--------------------------------------------------------------------%
function kpress(scribeax)

fig = ancestor(scribeax,'figure');
key = double(get(fig,'CurrentCharacter'));

if isempty(key)
  return
end

switch key
 case {8 127} % Backspace and Delete
  plotedit(fig,'Clear');
 case 27 % escape
  plotedit(fig,'off');
  plotedit(fig,'on');
 otherwise
  curmod = get(fig,'CurrentModifier');
  if isempty(curmod) || any(strcmp(curmod,'shift'))
    graph2dhelper('sendtocmdwin',char(key));
  end
end

%--------------------------------------------------------------------%
function addshape(scribeax,shape)

shapes = scribeax.Shapes;
shapes = shapes(ishandle(shapes));
if isempty(shapes)
    shapes = shape;
else
    shapes(end+1) = shape;
end
scribeax.Shapes = shapes;

%--------------------------------------------------------------------%
% add given shape to selection list or replace selection
function setselectedshape(scribeax,shape)

fig = ancestor(scribeax,'figure');
% early exit if scribe is off
if ~isappdata(fig,'scribeActive')
    scribecursors(fig,0);
    return;
end
seltype = get(fig,'selectiontype');
if strcmpi(seltype,'extend') 
  if strcmpi(shape.selected,'on')
    selectobject(scribeax,shape,'off');
  else
    selectobject(scribeax,shape,'on');
  end
  scribecursors(fig,0);
else
  if strcmpi(shape.selected,'off')
    replace_selected_objects(scribeax,shape);
  end
  set(scribeax,'currentShape',shape);
  if ~strcmp(seltype,'open')
    init_move_all(scribeax);
  end
end

%--------------------------------------------------------------------%
function clickedwindow(scribeax)

% this is the windowbuttondownfcn for action 0 (not creating anything) and
% possibly selecting something - or not.
fig = ancestor(scribeax,'figure');
if ~isappdata(fig,'scribeActive')
    return;
end
seltype = get(fig,'selectiontype');
curmod = get(fig,'currentmodifier');

selectobj = scribe_hittest(scribeax,fig);

sh = handle(selectobj);
shparent = handle(sh.Parent);

% if pinning is on, and the object is not a pinnable scribe object turn
if strcmpi(scribeax.PinMode,'on')
    pinnableshapes = {'rectangle','ellipse','arrow','textbox','doublearrow','textarrow','line'};
    pinnable = 0;
    if isprop(sh,'ShapeType')
        pinnable = any(strcmpi(pinnableshapes,sh.ShapeType));
    elseif isprop(shparent,'ShapeType')
        pinnable = any(strcmpi(pinnableshapes,shparent.ShapeType));
    end
    if ~pinnable
        startscribepinning(fig,'off');
    end
end

% early exit if object doesn't allow selection
if ~isempty(selectobj) && ~isempty(hggetbehavior(selectobj,'Plotedit','-peek'))
  if ~get(hggetbehavior(selectobj,'Plotedit'),'EnableSelect')
    return;
  end
end

% if there is no current object, deselect everything and leave
if isempty(selectobj) || ~ishandle(selectobj) || ...
        strcmpi(get(selectobj,'tag'),'DataTipMarker')
    deselectall(scribeax);
    return;
end

% if the selection type is not extend and the click is not on an
% already selected object (in which case we leave it selected)
% then deselect all scribe and nonscribe objects. 
must_replace = false;
if ~strcmp(seltype,'extend') && ...
      ~findin_selected_objects(scribeax,selectobj)
  must_replace = true;
end

% get current point,normalized
point = get_current_normalized_point(scribeax);
parent = get(selectobj,'parent');

% allow custom button down to handle the event
eventhandled = false;
if ~isempty(sh) && ~isempty(hggetbehavior(sh,'Plotedit','-peek'))
  b = hggetbehavior(sh,'Plotedit');
  bd = b.ButtonDownFcn;
  if iscell(bd)
    eventhandled = feval(bd{:},point);
  elseif ~isempty(bd)
    eventhandled = feval(bd,sh,point);
  end
end
% only nonscribe objects beyond this point
if ~eventhandled && ~isprop(handle(parent),'ShapeType') && ...
      ~isprop(handle(selectobj),'ShapeType')
  % if it is a child of group get toplevel group and let that be the
  % object.
  gh = ancestor(selectobj,{'hggroup','hgtransform'},'toplevel');
  if ~isempty(gh)
    selectobj = gh;
  end
  % if the object is selected already and the selectiontype is alt then
  % (ctrl key down) then deselect it.
  if strcmpi(seltype,'extend') && ...
        strcmpi(get(selectobj,'selected'),'on')
    % unselect it
    selectobject(scribeax,selectobj,'off');
    scribecursors(fig,0);
  else
    % select it
    if must_replace
      replace_selected_objects(scribeax,selectobj);
    else
      selectobject(scribeax,selectobj,'on');
    end
    % determine and set the movetype of the nonscribe object 
    % scribe objects have their own buttondown functions
    % that set movetype properties.  Nonscribe objects keep movetype in
    % appdata.  hgtext objects only have one kind of move (no resize).
    
    % find out what part was clicked (main body and/or affordance)
    [inrect,inaff,inedge] = parts_containing_point(scribeax,fig,double(selectobj),point);
    % handle a double click (selectiontype='open')
    if strcmpi(seltype,'open')
      if strcmpi(get(selectobj,'type'),'text')
        % for text objects, double clicking inside starts editing
        set(selectobj,'editing','on');
      end
    else % single clicks
      scribecursors(fig,get_scribecursor(fig,double(selectobj),inrect,inaff,inedge));
      % don't set movetype or move X0,YO data if selectobj is a
      % figure or not moving axes
      if strcmp(get(double(selectobj),'type'),'figure')
        return;
      elseif strcmp(get(double(selectobj),'type'),'axes')
        allowInterior = false;
        if ~isempty(hggetbehavior(selectobj,'Plotedit','-peek'))
          allowInterior = get(hggetbehavior(selectobj,'Plotedit'),'AllowInteriorMove');
        end
        if allowInterior && inedge ~= 1 && inrect ~= 1
          return;
        elseif ~allowInterior && inedge ~= 1
          return;
        end
      end
      % if point is in an affordance and object is not a text
      % object, set movetype based on affordance number.
      % Otherwise set to 1
      if inaff>0 && ~strcmpi(get(double(selectobj),'type'),'text')
        setappdata(double(selectobj),'scribemove_movetype',inaff+1);
      else
        setappdata(double(selectobj),'scribemove_movetype',1);
      end
      % setting initial move point - also in appdata
      setappdata(double(selectobj),'scribemove_X0',point(1));
      setappdata(double(selectobj),'scribemove_Y0',point(2));
    end
    % prepare to move all selected items.
    init_move_all(scribeax);
  end
end

%--------------------------------------------------------------------%
% Performs hittesting with careful attention to hittest on top
% of a selection handle since it should always win.
function selectgobj=scribe_hittest(scribeax,fig);

% default is standard hittest
hitobj = hittest(fig);
% find scribe object or group parent if any
sparent = get(hitobj,'parent');
if strncmp('scribe.',class(handle(sparent)),7)
    % scribe object parent is selected object
    selectgobj = sparent;
else
    % if selectobj has a group ancestor, that is the selected object
    selectgobj = ancestor(hitobj,{'hggroup','hgtransform'},'toplevel');
    if isempty(selectgobj)
        selectgobj = hitobj;
    end
end

if (isempty(selectgobj) || ~isprop(selectgobj,'Selected') || ...
    ~isequal(get(selectgobj,'Selected'),'on')) 
  % if default select object is not currently selected search selected
  % objects
  found = false;
  fixselectobjs(scribeax); % remove deleted handles from list
  sobj = scribeax.SelectedObjects;
  nsobj = sobj;
  % search selected scribe objects
  if ~isempty(sobj)
    for k = 1:length(sobj)
      if isprop(sobj(k),'ShapeType')
        npoint = get_current_normalized_point(scribeax);
        % affordance at point returns 0 if point not over an affordance
        found = methods(handle(sobj(k)),'affordance_at_point', ...
                        npoint);
      else
        % only check objects that can move
        type = get(nsobj(k),'Type');
        if any(strcmp(type,'axes'))
          ppoint = get_current_pixel_point(scribeax);
          pxpos = get_object_position(scribeax,nsobj(k),'pixels');
          % possible x and y values for affordances
          afx = [pxpos(1),pxpos(1)+pxpos(3)/2,pxpos(1)+pxpos(3)];
          afy = [pxpos(2),pxpos(2)+pxpos(4)/2,pxpos(2)+pxpos(4)];
          % affordance points starting with upper left, clockwise
          afpt = [afx(1),afy(3);afx(2),afy(3);afx(3),afy(3);afx(3),afy(2);...
                  afx(3),afy(1);afx(2),afy(1);afx(1),afy(1);afx(1),afy(2)];
          m = 1;
          afsize = 4;
          while ~found && m<=8
            % if current point is within affordance size in x and y
            % then point is on affordance, object is the select
            % object.
            if all(abs(ppoint(:)'-afpt(m,:))<afsize)
              found = m;
              selectgobj = nsobj(k);
            end
            m=m+1;
          end
        end
      end
      if found
        selectgobj = sobj(k);
        return;  % return now that we've found the selection hit
      end
    end
  end
end

%--------------------------------------------------------------------%
function list = filter_out_figure(list)

list(strcmp(get(list,'Type'),'figure')) = [];

%--------------------------------------------------------------------%
function update_selected_scribe_objects(scribeax)

shapes = scribeax.Shapes;
selectedObjects = scribeax.SelectedObjects;
objOK = false(length(selectedObjects),1);
for k=1:length(selectedObjects)
    if ishandle(selectedObjects(k)) && ~isprop(selectedObjects(k), 'ShapeType')
      objOK(k) = true;
    end
end
selectedObjects = selectedObjects(objOK);
for k=1:length(shapes)
    if strcmpi(shapes(k).selected,'on');
        selectedObjects(end+1) = shapes(k);
    end
end
if length(selectedObjects) > 1
  selectedObjects = filter_out_figure(selectedObjects);
end
scribeax.SelectedObjects = selectedObjects;
add_selected_delete_listener(scribeax);

%--------------------------------------------------------------------%
function selectobject(scribeax,h,onoff)

if isprop(h,'shapeType')
    h=handle(h);
    % then it is a scribe object
    % call its setselected method
    h.methods('setselected',onoff);
    % set scribeax current shape
    if strcmpi(onoff,'on')
        scribeax.CurrentShape=h;
    elseif isequal(scribeax.CurrentShape,h)
        scribeax.CurrentShape=[];
        plotedit({'scribe_contextmenu',h,'off'});
    end
    update_selected_scribe_objects(scribeax);
else
    fixselectobjs(scribeax);
    selectobjs = scribeax.SelectedObjects;  %list of selected objects 
    if strcmpi(onoff,'on')
        % add to selectobjs if not already in list
        if ~any(selectobjs==double(h))
            selectobjs(end+1) = handle(h);
            if length(selectobjs) > 1
              selectobjs = filter_out_figure(selectobjs);
            end
            scribeax.SelectedObjects = selectobjs;
        end 
        % turn selected on and make it the current shape
        set(h,'selected','on');
        fig = ancestor(h,'figure');
        if strcmpi(get(h,'type'),'axes') && ~isappdata(double(h),'NonDataObject')
            set(fig,'currentaxes',double(h));
        end
        set(fig,'currentobject',double(h));
        scribeax.CurrentShape = handle(h);
        
        % update its context menu 
        plotedit({'nonscribe_contextmenu',h,'on'});
    elseif ~isempty(selectobjs)
        % create a new selectobjs list without h
        newselectobjs=[];
        for k=1:length(selectobjs)
            if ~isequal(selectobjs(k),handle(h))
                newselectobjs(end+1) = selectobjs(k);
            end
        end
        % set scribeax selectobjs property to new list
        scribeax.SelectedObjects = newselectobjs;
        % make sure it isn't still current scribe shape
        if isequal(scribeax.CurrentShape,handle(h))
          scribeax.CurrentShape=[];
        end
        % turn hg selection off
        set(h,'selected','off');  
        % update its context menu
        plotedit({'nonscribe_contextmenu',h,'off'});
    end
end
add_selected_delete_listener(scribeax);
update_ccp_menuitems(scribeax);

%--------------------------------------------------------------------%
function update_ccp_menuitems(scribeax);

fig = get(scribeax,'Parent');
plotedit({'update_edit_menu',fig});

%--------------------------------------------------------------------%
function fixselectobjs(h)

% remove invalid handles from slectobjs list
h.SelectedObjects(~ishandle(h.SelectedObjects)) = [];

%--------------------------------------------------------------------%
function remove_selected_obj_cb(hSrc,evdata,h)

h.SelectedObjects(h.SelectedObjects == double(hSrc)) = [];

%--------------------------------------------------------------------%
function add_selected_delete_listener(h)

if ~isprop(h,'ScribeAxesSelectDestroyedListeners')
  dl = schema.prop(h,'ScribeAxesSelectDestroyedListeners','MATLAB array');
  dl.AccessFlags.Serialize = 'off'; 
  dl.Visible = 'off';
end
cls = classhandle(h);
dlis = handle.listener(h.SelectedObjects,'ObjectBeingDestroyed', {@remove_selected_obj_cb,h});
set(h,'ScribeAxesSelectDestroyedListeners',dlis);


%--------------------------------------------------------------------%
function replace_selected_objects(scribeax,objs)

fig = ancestor(scribeax,'figure');

% deselect all selected scribe objects that aren't members of "objs"
fixselectobjs(scribeax);

prevSelected = [];
if ~isempty(scribeax.SelectedObjects)
    prevSelected = double (scribeax.SelectedObjects);
end
toLeaveAlone = intersect (prevSelected, double(objs));
toDeselect = prevSelected (~ismember (prevSelected, toLeaveAlone));
toSelect = objs (~ismember (double(objs), toLeaveAlone));
if ~isempty (toDeselect)
    deselect_these (toDeselect);
    set(scribeax,'currentShape',[]);  % jtidwell: is this necessary?
end
% now select the objs
[sshapes, nsobjs] = select_these (toSelect, scribeax, fig);
scribeax.SelectedObjects = [handle(sshapes) handle(nsobjs) handle(toLeaveAlone)];
add_selected_delete_listener(scribeax);

% update cutcopypaste figure menus
update_ccp_menuitems(scribeax); 

%--------------------------------------------------------------------%
function deselect_these (shapes)
% jtidwell:  how much of this can be parallelized?
    for k=1:length(shapes)
        if ishandle(shapes(k))
          if isprop(shapes(k),'ShapeType')
            plotedit({'scribe_contextmenu',handle(shapes(k)),'off'});
            handle(shapes(k)).methods('setselected','off');
          else
            set(shapes(k),'selected','off');
            plotedit({'nonscribe_contextmenu',shapes(k),'off'});
          end
        end
    end
    
%--------------------------------------------------------------------%
function [sshapes, nsobjs] = select_these (objs, scribeax, fig)
sshapes = [];
nsobjs = [];
for k=1:length(objs)
    h = handle(objs(k));
    if  isprop(h,'ShapeType')
        % add scribe object
        sshapes(end+1) = h;
        h.methods('setselected','on');
        set(scribeax,'currentShape',h);
    else
      % add nonscribe object
        nsobjs(end+1) = h;
        set(double(h),'Selected','on');        
        if strcmpi(get(h,'type'),'axes')
            set(fig,'currentaxes',double(h));
        end
        set(fig,'currentobject',double(h));
        scribeax.CurrentShape = handle(h);
        % update its context menu 
        plotedit({'nonscribe_contextmenu',h,'on'});
    end
end    


%--------------------------------------------------------------------%
function deselectall(scribeax)

if ~isempty(scribeax.SelectedObjects)
    shapes = scribeax.SelectedObjects;
    for k=1:length(shapes)
        if ishandle(shapes(k))
          if isprop(shapes(k),'ShapeType')
            plotedit({'scribe_contextmenu',shapes(k),'off'});
            shapes(k).methods('setselected','off');
          else
            set(double(shapes(k)),'selected','off');
            plotedit({'nonscribe_contextmenu',double(shapes(k)),'off'});
          end
        end
    end
    set(scribeax,'currentShape',[]);
    update_selected_scribe_objects(scribeax);
end

%--------------------------------------------------------------------%
function init_move_all(scribeax)

fig = ancestor(scribeax,'figure');
point = get_current_normalized_point(scribeax);
ppoint = get_current_pixel_point(scribeax);
scribeax.ClickPoint = ppoint;
scribeax.MoveOK = 'off';
canmove = true;
fixselectobjs(scribeax);
objs = scribeax.SelectedObjects;
for k=1:length(objs)
  if ~isempty(hggetbehavior(objs(k),'Plotedit','-peek'))
    if ~get(hggetbehavior(objs(k),'Plotedit'),'EnableMove')
      canmove = false;
    end
  end
end
if ~canmove
  for k=1:length(objs)
    if isprop(objs(k),'ShapeType')
      objs(k).moveMode=0;
    else
      % turns off movement for a non-scribe object
      setappdata(double(objs(k)),'scribemove_movetype',0); 

    end
  end
else
  % set move state
  for k=1:length(objs)
    if isprop(objs(k),'ShapeType')
      set(objs(k),'MoveX0',point(1));
      set(objs(k),'MoveY0',point(2));
    else
      h=double(objs(k));
      if ~strcmpi(get(h,'type'),'figure') && isprop(h,'units')
        setappdata(h,'scribemove_X0',point(1));
        setappdata(h,'scribemove_Y0',point(2));
      end
    end
  end
end

%--------------------------------------------------------------------%
function undo_last_move(scribeax)

if ~isempty(scribeax.MovedObjects) && any(ishandle(scribeax.MovedObjects))
    for k=1:length(scribeax.MovedObjects)
        if ishandle(scribeax.MovedObjects(k))
            hobj = handle(scribeax.MovedObjects(k));
            if isprop(hobj,'ShapeType')
                methods(handle(scribeax.MovedObjects(k)),'undo_last_move');
            else
                lastpos = getappdata(scribeax.MovedObjects(k),'scribemove_lastpos');
                if ~isempty(lastpos)
                    setappdata(scribeax.MovedObjects(k),'scribemove_lastpos',...
                        get(scribeax.MovedObjects(k),'Position'));
                    set(scribeax.MovedObjects(k),'Position',lastpos);
                end
            end
        end
    end
end

%--------------------------------------------------------------------%
function moved=has_moved(scribeax)

moved = false;
if ~isempty(scribeax.MovedObjects) && any(ishandle(scribeax.MovedObjects))
    k=1;
    while k<=length(scribeax.MovedObjects) && ~moved
        if ishandle(scribeax.MovedObjects(k)) 
            hobj = handle(scribeax.MovedObjects(k));
            if isprop(hobj,'ShapeType')
                moved = methods(hobj,'has_moved');
            else
                lastpos = getappdata(scribeax.MovedObjects(k),'scribemove_lastpos');
                moved = ~isempty(lastpos) && ~isequal(lastpos,get(scribeax.MovedObjects(k),'Position'));
            end
        end
        k=k+1;
    end
end

%--------------------------------------------------------------------%
function anypinned = any_selected_pinned(scribeax)
% return true if any of the selected scribe objects are pinned
% otherwise return false
anypinned=false;
shapes = scribeax.Shapes;
k=1;
while k<=length(shapes) && ~anypinned
    if strcmpi(shapes(k).selected,'on')
        stype = shapes(k).shapeType;
        if strcmpi(stype,'rectangle') || strcmpi(stype,'textbox') || strcmpi(stype,'ellipse')
            if ~isempty(shapes(k).pinnedAxes)
                anypinned=true;
            end
        elseif any(strcmpi(stype,{'arrow','doublearrow','line','textarrow'}))
            if ~isempty(shapes(k).pinnedAxes1) || ~isempty(shapes(k).pinnedAxes2)
                anypinned=true;
            end
        end
    end
    k=k+1;
end

%--------------------------------------------------------------------%
function n = nselected(scribeax)

fixselectobjs(scribeax);
n = length(scribeax.SelectedObjects);

%--------------------------------------------------------------------%
function on=findin_selected_objects(scribeax,selectobj)
% returns true if selectobj is a currently selected object
obj=handle(selectobj);
% get the scribe group, if there is one
sg=getappdata(obj,'ScribeGroup');
if ~isempty(sg)
    obj=sg;
end
on=false;
fixselectobjs(scribeax);
if ~isempty(scribeax.SelectedObjects)
    objs = scribeax.SelectedObjects;
    k=1;
    while k<=length(objs) && ~on
        if isequal(obj,objs(k))
            on=true;
        end
        k=k+1;
    end
end

%--------------------------------------------------------------------%
function delete_selected_objs(scribeax)
objs = scribeax.SelectedObjects;
for k=1:length(objs)
  if ishandle(objs(k))
    if isprop(objs(k),'ShapeType')
      inds = isequal(scribeax.Shapes,objs(k));
      scribeax.Shapes(inds) = [];
      delete(objs(k));
    elseif ~strcmpi(get(objs(k),'Type'),'figure')
      delete(objs(k));
    end
  end
end
scribeax.CurrentShape = [];
scribeax.SelectedObjects = [];
update_ccp_menuitems(scribeax);

%--------------------------------------------------------------------%
function delete_obj(scribeax,obj)

if ishandle(obj) 
  selectind = find(double(obj) == double(scribeax.SelectedObjects));
  if ~isempty(selectind)
    scribeax.SelectedObjects(selectind) = [];
  end
  if isprop(obj,'ShapeType')
    if isequal(double(scribeax.CurrentShape),double(obj))
      scribeax.CurrentShape = [];
    end
    shapeind = find(double(obj) == double(scribeax.Shapes));
    scribeax.Shapes(shapeind) = [];
    delete(obj);
  else
    delete(obj);
    fixselectobjs(scribeax);
  end  
  update_ccp_menuitems(scribeax);
end

%--------------------------------------------------------------------%
function copy_selected_objs(scribeax,append)

if ~append
  setappdata(0,'ScribeCopyBuffer',[]);
end
objs = scribeax.SelectedObjects;
for k=1:length(objs)
  if ishandle(objs(k))
    copy_obj(scribeax,objs(k),true);
  end
end
update_ccp_menuitems(scribeax);

%--------------------------------------------------------------------%
function copy_obj(scribeax,obj,append)

copybuffer = {};
if append
    copybuffer = getappdata(0,'ScribeCopyBuffer');
end
if isempty(copybuffer)
    copybuffer = {};
end
data = handle2struct(obj);
data.parenttype = get(get(obj,'Parent'),'Type');
copybuffer{end+1} = data;
setappdata(0,'ScribeCopyBuffer',copybuffer);
update_ccp_menuitems(scribeax);

%--------------------------------------------------------------------%
function paste_copybuffer(scribeax,fig)

copybuffer = getappdata(0,'ScribeCopyBuffer');
if isempty(copybuffer)
    return;
end
for k=1:length(copybuffer)
  s = copybuffer{k};
  switch(s.type) 
   case {'uipushtool' 'uitoggletool'}
    parent = gctb;
   otherwise
    if isfield(s.properties,'ShapeType')
      % handle scribe objects
      cp_scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
      if isempty(cp_scribeax);
        cp_scribeax = scribe.scribeaxes(fig);
      end
      parent = double(cp_scribeax);
    else
      if strcmp(s.parenttype,'figure')
        if isempty(fig)
          parent = gcf;
        else
          parent = fig;
        end
      else
        parent = get(fig,'CurrentAxes');
        if isempty(parent), parent=gca;  end
      end
    end
  end

  setappdata(0,'BusyDeserializing','on');
  h = handle(struct2handle(s, parent ));
  rmappdata(0,'BusyDeserializing');
  
  % process annotation objects similar to postdeserialize after loading
  % figure
  cb = getappdata(h,'PostDeserializeFcn');
  if ~isempty(cb)
    feval(cb,h,'paste'); % for legend,colorbar
  elseif isprop(h,'ShapeType')
    h.methods('postdeserialize');
  end
end

%--------------------------------------------------------------------%
function scribe_contextmenu(scribeax,varargin)

plotedit({'scribe_contextmenu',varargin{:}});

%-------------------------------------------------------------------%
function fonts=goodfonts(scribeax)

fonts=listfonts;
lfonts = lower(fonts);
goodfonts = logical(ones(1,length(fonts))); 
for k=1:length(fonts)
    if ~isempty(findstr('dings',lfonts{k})) || ...
            ~isempty(findstr('zapf',lfonts{k})) || ...
            ~isempty(findstr('mt extra',lfonts{k})) || ...
            ~isempty(findstr('symbol',lfonts{k}))
        goodfonts(k) = false;
    end
end
fonts = fonts(goodfonts);

%-------------------------------------------------------------------%
function move_nonscribeobject(obj,point,scribeax)

if ~isprop(obj,'Units') && ~isprop(obj,'ShapeType')
    return;
end

fig = ancestor(scribeax,'figure');
% don't proceed if current point hasn't changed
ppoint=get_current_pixel_point(scribeax);
if isequal(ppoint,scribeax.CurrentPoint)
    return;
end

% calculate new X and Y positions for arrow from
% moveX0 and moveY0 and current point
h=double(obj);
% don't move a figure
if strcmpi(get(h,'type'),'figure')
    return;
end
% can't move object with no units property
if ~isprop(h,'units')
    return;
end
if ~isappdata(h,'scribemove_X0') ||...
        ~isappdata(h,'scribemove_Y0')
    return;
end
if strcmpi('on',getappdata(fig,'scribegui_snaptogrid')) && ...
        isappdata(fig,'scribegui_snapgridstruct')
    snapmove(scribeax,h,point);
else
    istext = strcmpi(get(h,'type'),'text');
    pos=get(h,'position');
    X0=getappdata(h,'scribemove_X0');
    Y0=getappdata(h,'scribemove_Y0');
    if istext
        ax = ancestor(h,'axes');
        apos=get_object_position(scribeax,ax,'normalized');
        % get figure normal position for text object
        pos(1) = apos(1) + pos(1)*apos(3);
        pos(2) = apos(2) + pos(2)*apos(4);
        X = pos(1) + (point(1) - X0);
        Y = pos(2) + (point(2) - Y0);
        if ~isequal(X,pos(1)) || ~isequal(Y,pos(2))
            % get axes normal position to set it
            pos(1) = (X - apos(1))/apos(3);
            pos(2) = (Y - apos(2))/apos(4);
            set(h,'position',pos);
            % set MoveX0 and MoveY0 to current point
            setappdata(h,'scribemove_X0',point(1));
            setappdata(h,'scribemove_Y0',point(2));
        end
    else
        X = pos(1) + (point(1) - X0);
        Y = pos(2) + (point(2) - Y0);
        if ~isequal(X,pos(1)) || ~isequal(Y,pos(2))
            pos(1) = X;
            pos(2) = Y;
            set(h,'position',pos);
            % set MoveX0 and MoveY0 to current point
            setappdata(h,'scribemove_X0',point(1));
            setappdata(h,'scribemove_Y0',point(2));
        end
    end
end

%--------------------------------------------------------------------%
function snapmove(scribeax,h,point)

fig = ancestor(scribeax,'figure');

% Get grid structure values
gridstruct = getappdata(fig,'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;
% Initialize pixel center position (same as h.PX for scriberect)
u=get(h,'units');
if ~strcmpi(u,'pixels')
    set(h,'units','pixels');
end
hppos = get(h,'position');
istext = strcmpi(get(h,'type'),'text');
if istext
    ax = ancestor(h,'axes');
    appos=get_object_position(scribeax,ax,'normalized');
    % get figure normal position for text object
    hppos(1) = appos(1) + hppos(1);
    hppos(2) = appos(2) + hppos(2);
    ext = get(h,'extent');
    tpos3 = hppos(3); % saving the z text position
    % for calculations, set hppos(3) and (4) from extent
    hppos(3) = ext(3); hppos(4) = ext(4);
end
HPX=hppos(1) + hppos(3)/2; HPY=hppos(2) + hppos(4)/2;
PX = HPX; PY = HPY;
set(h,'units','normalized');
npos = get(h,'position');
X0=getappdata(h,'scribemove_X0');
Y0=getappdata(h,'scribemove_Y0');
if istext    
    ax = ancestor(h,'axes');
    apos=get_object_position(scribeax,ax,'normalized');
    % get figure normal position for text object
    npos(1) = apos(1) + npos(1)*apos(3);
    npos(2) = apos(2) + npos(2)*apos(4);
end
X = npos(1) + (point(1) - X0);
Y = npos(2) + (point(2) - Y0);
% Get pixel position of overlay ax
ppos=getpixelpos(scribeax);
% Initial pixel position - of center
IPX = (X*ppos(3)) + hppos(3)/2;
IPY = (Y*ppos(4)) + hppos(4)/2;
% Set initial move point to current point
% These may be reset if there has been a move
X0 = point(1);
Y0 = point(2);
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
    if ~isequal(HPX,PX)
        % update the move point
        X0 = point(1) + ((PX - IPX)/ppos(3));
        update=true;
    end
elseif ~isequal(IPX,HPX) % otherwise a normal move
    PX = IPX;
    X0 = point(1);
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
    if ~isequal(HPY,PY)
        % update the move point
        Y0 = point(2) + ((PY - IPY)/ppos(4));
        update=true;
    end
elseif ~isequal(IPY,HPY)
    PY = IPY;
    Y0 = point(2);
    update=true;
end
% Update the Object if needed
if update
    set(h,'units','pixels');
    if istext
        hppos(1) = PX - hppos(3)/2 - appos(1);
        hppos(2) = PY - hppos(4)/2 - appos(2);        
        set(h,'position',[hppos(1) hppos(2) tpos3]);
    else
        hppos(1) = PX - hppos(3)/2;
        hppos(2) = PY - hppos(4)/2;
        set(h,'position',hppos);
    end
    setappdata(h,'scribemove_X0',X0 );
    setappdata(h,'scribemove_Y0',Y0 );
end
set(h,'units',u);

%--------------------------------------------------------------------%
function resize_nonscribeobject(h,MoveType,point,scribeax)
% resizing or whatever happens when an affordance is being moved.

if ~isprop(h,'units') && ~isprop(h,'ShapeType')
    return;
end
ppoint = get_current_pixel_point(scribeax);

% don't proceed if current point hasn't changed
if isequal(ppoint,scribeax.CurrentPoint)
    return;
end

if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid')) && ...
        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
    snapresize(h,MoveType,point,scribeax);
else
    u = get(h,'units');
    if ~strcmpi(u,'normalized')
        set(h,'units','normalized');
    end
    npos = get(h,'position');
    % old positions (normalized)
    XL = npos(1);
    XR = npos(1) + npos(3);
    YU = npos(2) + npos(4);
    YL = npos(2);
    % move the appropriate x/y values
    switch MoveType
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
    npos(1) = XL;
    npos(2) = YL;
    npos(3) = XR - XL;
    npos(4) = YU - YL;
    npos(3) = max(npos(3),.001);
    npos(4) = max(npos(4),.001);
    set(h,'position',npos);
    if ~strcmpi(u,'normalized')
        set(h,'units',u);
    end
end

%-----------------------------------------------------------------------%
function snapresize(h,MoveType,point,scribeax)

% Get grid structure values
gridstruct = getappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct');
snaptype = gridstruct.snapType;
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;
% Get pixel position of overlay ax
ppos=getpixelpos(handle(scribeax));
% Old positions (in pixels)
u = get(h,'units');
if ~strcmpi(u,'pixels')
    set(h,'units','pixels');
end
phpos = get(h,'position');
XL = phpos(1);
XR = phpos(1) + phpos(3);
YU = phpos(2) + phpos(4);
YL = phpos(2);
ysnap=false; xsnap=false;
switch MoveType
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

% calculate and set width height and x,y of resized object
phpos(1) = XL;
phpos(2) = YL;
phpos(3) = XR - XL;
phpos(4) = YU - YL;
set(h,'position',phpos);
set(h,'units',u);

%--------------------------------------------------------------------%
function over=mouseover_nonscribeobject(scribeax,obj,point)

over = 0;
fig = ancestor(scribeax,'figure');
ppoint = get_current_pixel_point(scribeax);
[inrect,inaff,inedge] = parts_containing_point(scribeax,fig,obj,point);
over = get_scribecursor(fig,obj,inrect,inaff,inedge);
scribeax.CurrentPoint = ppoint;

%--------------------------------------------------------------------%
function curs = get_scribecursor(fig,obj,inrect,inaff,inedge)

% return appropriate figure cursor for mouseover or click on object obj
% depending on whether mouse is over the center of the object (inrect) and
% which, if any, affordance mouse is over (inaff).
curs = 0;
if ~isempty(hggetbehavior(obj,'Plotedit','-peek'))
  if ~get(hggetbehavior(obj,'Plotedit'),'EnableMove')
    return;
  end
end
if inaff>0
  if strcmpi(get(obj,'type'),'text')
    % text objects can't be moved or resized from affordances
    curs = -1; % use regular pointer
  elseif strcmpi(get(obj,'type'),'axes')
    curs = inaff+1;
  end
elseif (inedge > 0 && any(strcmp(get(obj,'type'),'axes'))) || ...
      (inrect > 0 && any(strcmp(get(obj,'type'),'text')))
  % axes can be moved if on the edge, text if in body
  curs = 1;
else
  allowInterior = false;
  if ~isempty(hggetbehavior(obj,'Plotedit','-peek'))
    allowInterior = get(hggetbehavior(obj,'Plotedit'),'AllowInteriorMove');
  end
  if (inrect > 0 && allowInterior)
    % check if the object wants to allow interior dragging
    curs = 1;
  else
    curs = -1; % use regular pointer
  end
end

%--------------------------------------------------------------------%
function [inrect,inaff,inedge] = parts_containing_point(scribeax,fig,h,point)
% initial values
inrect=0;
inaff=0;
inedge=0;
if ~isprop(h,'units') && ~isprop(h,'ShapeType')
    return;
end

% get pixel pos of figure
ppos = get_object_position(scribeax,fig,'pixels');

if strcmpi(get(h,'type'),'axes')
    % don't use pixel bounds for axes.  The extra space for the ticks
    % offsets the pixelbounds from the affordances
    pos = get_object_position(scribeax,h,'pixels');
    % pos = get_axes_smallbounds(scribeax,h);
else
    % for all else use pixel bounds
    % get pixel bounds of object
    bounds = get(h,'pixelbounds');
    % calculate pixel position of object in figure
    % pixel bounds = [left, top(from fig top), right, bottom (from fig top)
    pos = [bounds(1),ppos(4)-bounds(4),bounds(3)-bounds(1),bounds(4)-bounds(2)];
end

% rectangle center in pixel coords
XC = pos(1) + pos(3)/2;
YC = pos(2) + pos(4)/2;

% calc x and y limits of rectangle in pixel coords
XL = pos(1);
XR = pos(1) + pos(3);
YU = pos(2) + pos(4);
YL = pos(2);

% get point in pixels
px = point(1)*ppos(3);
py = point(2)*ppos(4);

a2 = 4; % half pixel afsiz;
% test if mouse over main rect area
if XL <= px && px <= XR && ...
        YL <= py && py <= YU
  inrect = 1;
end
% test if mouse over the boundary of the position rect
if (any(abs([XL XR]-px) <= a2) && YL <= py && py <= YU) || ...
      (any(abs([YL YU]-py) <= a2) && XL <= px && px <= XR)
  inedge = 1;
end
% test if mouse over affordances
% return when first one is found
% upper left
if XL - a2 <= px & px <= XL + a2 & ...
        YU - a2 <= py & py <= YU + a2
    inaff=1;
    return;
end
% upper right
if XR - a2 <= px & px <= XR + a2 & ...
        YU - a2 <= py & py <= YU + a2
    inaff=2;
    return;
end
% lower right
if XR - a2 <= px & px <= XR + a2 & ...
        YL - a2 <= py & py <= YL + a2
    inaff=3;
    return;
end
% lower left
if XL - a2 <= px & px <= XL + a2 & ...
        YL - a2 <= py & py <= YL + a2
    inaff=4;
    return;
end
% left
if XL - a2 <= px & px <= XL + a2 & ...
        YC - a2 <= py & py <= YC + a2
    inaff=5;
    return;
end
% top
if XC - a2 <= px & px <= XC + a2 & ...
        YU - a2 <= py & py <= YU + a2
    inaff=6;
    return;
end
% right
if XR - a2 <= px & px <= XR + a2 & ...
        YC - a2 <= py & py <= YC + a2
    inaff=7;
    return;
end
% bottom
if XC - a2 <= px & px <= XC + a2 & ...
        YL - a2 <= py & py <= YL + a2
    inaff=8;
    return;
end

%--------------------------------------------------------------------%
function stackScribeLayers(h,evdata)

stackScribeLayersWithChild(h,double(get(evdata,'Child')),false);

%--------------------------------------------------------------------%
function stackScribeLayersWithChild(h,child,force)

fig = ancestor(h,'figure');

% send underlay to bottom (last child) 
% and overlay to top (first child)
% handle when one or both don't exist

if strcmp(get(child,'Tag'),'scribeUnderlay')
  su = child;
else
  su=getappdata(fig,'Scribe_ScribeUnderlay');
end

if strcmp(get(child,'Tag'),'scribeOverlay')
  so = child;
else
  so=getappdata(fig,'Scribe_ScribeOverlay');
end
ch = allchild(fig);
types = get(ch,'Type');
ch2 = ch(strcmp('axes',types) | strcmp('uipanel',types) | strcmp('uicontainers',types));

didChange = false;
if ~isempty(so) && ishandle(so) && ...
      (~isempty(get(so,'Children')) || force)
  soind = find(ch2 == so);
  if ~isempty(soind) && soind ~= 1
    soind = find(ch == so);
    ch(soind) = [];
    ch = [so;ch];
    didChange = true;
  end
end

if ~isempty(su) && ishandle(su) && ...
      (~isempty(get(su,'Children')) || force)
  suind = find(ch2 == su);
  if ~isempty(suind) && suind ~= length(ch)
    suind = find(ch == su);
    ch(suind) = [];
    ch = [ch;su];
    didChange = true;
  end
end

if didChange
  set(fig,'children',ch);
end

%--------------------------------------------------------------------%
function point=get_current_normalized_point(scribeax)

fig = ancestor(scribeax,'figure');
y = hgconvertunits(fig,[get(fig,'CurrentPoint') 1 1],get(fig,'Units'),...
                            'normalized',fig);
point = y(1:2);

%--------------------------------------------------------------------%
function point=get_current_pixel_point(scribeax)

fig = ancestor(scribeax,'figure');
y = hgconvertunits(fig,[get(fig,'CurrentPoint') 1 1],get(fig,'Units'),...
                            'pixels',fig);
point = y(1:2);

%--------------------------------------------------------------------%
function pos=get_object_position(scribeax,obj,units)

% gets position of object in units specified
pos = [];
if strcmp(get(obj,'type'),'text') 
  % hgconvertunits can't handle text objs so do it by hand
  oldunits = get(obj,'units');
  set(obj,'units',units);
  pos = get(obj,'Position');
  set(obj,'units',oldunits);
elseif isprop(obj,'position') && isprop(obj,'units')
  pos = hgconvertunits(ancestor(obj,'figure'),...
                       get(obj,'Position'),get(obj,'Units'),...
                       units,get(obj,'Parent'));
end

%--------------------------------------------------------------------%
function pos=get_axes_smallbounds(scribeax,ax)

pos=[];
%     lims=get(ax,{'XLim','YLim'});
%     t = hg.text(...
%         'Units','data',...
%         'Parent',ax,...
%         'Visible','on',...
%         'String','MEASURING TEXT',...
%         'Fontsize',32,...
%         'HandleVisibility','off',...
%         'Position',[lims{1}(1) lims{2}(1)]);
%     prepos=get(t,'position')
%     set(t,'Units','pixels');
%     set(t,'Parent',scribeax);
%     lowerleft = get(t,'Position')
%     e = get(t,'extent')
%     set(t,{'Parent','Units','Position'},{ax,'data',[lims{1}(2) lims{2}(2)]});
%     set(t,'Units','pixels');
%     size = get(t,'Position');
%     delete(t);
%     pos = [lowerleft(1:2),size(1:2)];
    
%--------------------------------------------------------------------%
function set_current_object_color(scribeax,color,colortype)
shape = scribeax.CurrentShape;
switch colortype
    case 'face'
        if isprop(shape,'facecolor')
            set(shape,'faceColor',color);
        elseif isprop(shape,'backgroundcolor')
            set(shape,'backgroundcolor',color);
        elseif graph2dhelper('typecheck',shape,'hg.axes')
            set(shape,'color',color);
        elseif graph2dhelper('typecheck',shape,'hg.figure')
            set(shape,'color',color);
        elseif graph2dhelper('typecheck',shape,'scribe.arrow') ||...
                graph2dhelper('typecheck',shape,'scribe.textarrow') ||...
                graph2dhelper('typecheck',shape,'scribe.doublearrow')
            set(shape,'headfacecolor',color);
        end
    case 'line'
        if graph2dhelper('typecheck',shape,'hg.line') || ...
            graph2dhelper('typecheck',shape,'scribe.line')
            set(shape,'color',color);
        elseif graph2dhelper('typecheck',shape,'scribe.arrow') ||...
                graph2dhelper('typecheck',shape,'scribe.textarrow') ||...
                graph2dhelper('typecheck',shape,'scribe.doublearrow')
            set(shape,'tailcolor',color);
        end
    case 'edge'
        if graph2dhelper('typecheck',shape,'hg.line') || ...
                graph2dhelper('typecheck',shape,'scribe.line')
            set(shape,'color',color);
        elseif graph2dhelper('typecheck',shape,'scribe.arrow') ||...
                graph2dhelper('typecheck',shape,'scribe.textarrow') ||...
                graph2dhelper('typecheck',shape,'scribe.doublearrow')
            set(shape,'tailcolor',color);
        elseif graph2dhelper('typecheck',shape,'hg.surface') || ...
                graph2dhelper('typecheck',shape,'hg.patch') || ...
                isprop(shape,'edgecolor')
            set(shape,'edgecolor',color);
        end
    case 'text'
        if graph2dhelper('typecheck',shape,'scribe.textbox') || ...
                graph2dhelper('typecheck',shape,'hg.text')
                    set(shape,'color',color);
        end
end

%--------------------------------------------------------------------%
function set_current_object_font(scribeax,font)

fig = ancestor(scribeax,'figure');
shape = scribeax.CurrentShape;
if graph2dhelper('typecheck',shape,'hg.text') || ...
      graph2dhelper('typecheck',shape,'scribe.textbox')
  set(shape,'fontname',font.FontName, ...
            'fontunits',font.FontUnits, ...
            'fontsize',font.FontSize, ...
            'fontweight',font.FontWeight, ...
            'fontangle',font.FontAngle);
  if strcmpi(font.FontWeight,'bold')
    plotedit({'plotedittoolbar',fig,'bold','state','on'});
  else
    plotedit({'plotedittoolbar',fig,'bold','state','off'});
  end
  if strcmpi(font.FontAngle,'italic')
    plotedit({'plotedittoolbar',fig,'italic','state','on'});
  else
    plotedit({'plotedittoolbar',fig,'italic','state','off'});
  end
end

%--------------------------------------------------------------------%
function set_current_object_fontweight(scribeax,fw)

shape = scribeax.CurrentShape;
if graph2dhelper('typecheck',shape,'hg.text') || ...
        graph2dhelper('typecheck',shape,'scribe.textbox')
    set(shape,'fontweight',fw);
end

%--------------------------------------------------------------------%
function set_current_object_fontangle(scribeax,fa)

shape = scribeax.CurrentShape;
if graph2dhelper('typecheck',shape,'hg.text') || ...
        graph2dhelper('typecheck',shape,'scribe.textbox')
    set(shape,'fontangle',fa);
end
%--------------------------------------------------------------------%
function set_current_object_text_horizontal_alignment(scribeax,al)

fig = ancestor(scribeax,'figure');
shape = scribeax.CurrentShape;
if graph2dhelper('typecheck',shape,'hg.text') || ...
        graph2dhelper('typecheck',shape,'scribe.textbox')
    set(shape,'horizontalalignment',al);
    switch al
        case 'right'
            plotedit({'plotedittoolbar',fig,'rightalign','state','on'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','off'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','off'});
        case 'center'
            plotedit({'plotedittoolbar',fig,'rightalign','state','off'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','on'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','off'});
        case 'left'
            plotedit({'plotedittoolbar',fig,'rightalign','state','off'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','off'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','on'});
    end
end
%--------------------------------------------------------------------%
function update_current_shape_toolbar(scribeax)

fig = ancestor(scribeax,'figure');
tbar = findall(fig,'tag','PlotEditToolBar');
if isempty(tbar)
    return;
end

shape = scribeax.CurrentShape;
if isempty(shape)
    plotedit({'plotedittoolbar',fig,'all','state','off'});
    plotedit({'plotedittoolbar',fig,'all','enable','off'});
    return;
end
   
if isprop(shape,'backgroundcolor')
    color = get(shape,'backgroundcolor');
    if ischar(color)
        color = 'none';
    end
    plotedit({'plotedittoolbar',fig,'facecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'facecolor',color});
    plotedit({'plotedittoolbar',fig,'facecolor','Background Color'});
elseif isprop(shape,'facecolor')
    color = get(shape,'facecolor');
    if ischar(color)
        color = 'none';
    end
    plotedit({'plotedittoolbar',fig,'facecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'facecolor',color});
    plotedit({'plotedittoolbar',fig,'facecolor','Face Color'});
elseif graph2dhelper('typecheck',shape,'hg.axes') || ...
        graph2dhelper('typecheck',shape,'hg.figure')
    plotedit({'plotedittoolbar',fig,'facecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'facecolor',get(shape,'color')});
    plotedit({'plotedittoolbar',fig,'facecolor','Color'});
elseif graph2dhelper('typecheck',shape,'scribe.arrow') ||...
        graph2dhelper('typecheck',shape,'scribe.textarrow') || ...
        graph2dhelper('typecheck',shape,'scribe.doublearrow')
    plotedit({'plotedittoolbar',fig,'facecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'facecolor',get(shape,'headfacecolor')});
    plotedit({'plotedittoolbar',fig,'facecolor','Color'});
else
    plotedit({'plotedittoolbar',fig,'facecolor','enable','off'});
    plotedit({'plotedittoolbar',fig,'facecolor','state','off'});
end

% edge color
if graph2dhelper('typecheck',shape,'hg.line') || ...
    graph2dhelper('typecheck',shape,'scribe.line')
    plotedit({'plotedittoolbar',fig,'edgecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'edgecolor',get(shape,'color')});
    plotedit({'plotedittoolbar',fig,'edgecolor','Color'});
elseif graph2dhelper('typecheck',shape,'scribe.arrow')||...
        graph2dhelper('typecheck',shape,'scribe.doublearrow')||...
        graph2dhelper('typecheck',shape,'scribe.textarrow')
    plotedit({'plotedittoolbar',fig,'edgecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'edgecolor',get(shape,'tailcolor')});
    plotedit({'plotedittoolbar',fig,'edgecolor','Tail Color'});
elseif isprop(shape,'edgecolor')
    plotedit({'plotedittoolbar',fig,'edgecolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'edgecolor',get(shape,'edgecolor')});
    plotedit({'plotedittoolbar',fig,'edgecolor','Edge Color'});
else
    plotedit({'plotedittoolbar',fig,'edgecolor','enable','off'});
    plotedit({'plotedittoolbar',fig,'edgecolor','state','off'});
end

% text props
if graph2dhelper('typecheck',shape,'scribe.textbox') || ...
        graph2dhelper('typecheck',shape,'hg.text')
    plotedit({'plotedittoolbar',fig,'textcolor','enable','on'});
    plotedit({'plotedittoolbar',fig,'font','enable','on'});
    plotedit({'plotedittoolbar',fig,'bold','enable','on'});
    plotedit({'plotedittoolbar',fig,'italic','enable','on'});
    plotedit({'plotedittoolbar',fig,'leftalign','enable','on'});
    plotedit({'plotedittoolbar',fig,'centeralign','enable','on'});
    plotedit({'plotedittoolbar',fig,'rightalign','enable','on'});
    plotedit({'plotedittoolbar',fig,'textcolor',get(shape,'color')});
    fw = get(shape,'fontweight');
    if strcmpi(fw,'bold')
        plotedit({'plotedittoolbar',fig,'bold','state','on'});
    else
        plotedit({'plotedittoolbar',fig,'bold','state','off'});
    end
    fa = get(shape,'fontangle');
    if strcmpi(fa,'italic');
        plotedit({'plotedittoolbar',fig,'italic','state','on'});
    else
        plotedit({'plotedittoolbar',fig,'italic','state','off'});
    end
    al = get(shape,'horizontalalignment');
    switch al
        case 'right'
            plotedit({'plotedittoolbar',fig,'rightalign','state','on'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','off'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','off'});
        case 'center'
            plotedit({'plotedittoolbar',fig,'rightalign','state','off'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','on'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','off'});
        case 'left'
            plotedit({'plotedittoolbar',fig,'rightalign','state','off'});
            plotedit({'plotedittoolbar',fig,'centeralign','state','off'});
            plotedit({'plotedittoolbar',fig,'leftalign','state','on'});
    end
else 
    plotedit({'plotedittoolbar',fig,'textcolor','enable','off'});
    plotedit({'plotedittoolbar',fig,'textcolor','state','off'});
    plotedit({'plotedittoolbar',fig,'font','enable','off'});
    plotedit({'plotedittoolbar',fig,'font','state','off'});
    plotedit({'plotedittoolbar',fig,'bold','enable','off'});
    plotedit({'plotedittoolbar',fig,'bold','state','off'});
    plotedit({'plotedittoolbar',fig,'italic','enable','off'});
    plotedit({'plotedittoolbar',fig,'italic','state','off'});
    plotedit({'plotedittoolbar',fig,'leftalign','enable','off'});
    plotedit({'plotedittoolbar',fig,'leftalign','state','off'});
    plotedit({'plotedittoolbar',fig,'rightalign','enable','off'});
    plotedit({'plotedittoolbar',fig,'rightalign','state','off'});
    plotedit({'plotedittoolbar',fig,'centeralign','enable','off'});
    plotedit({'plotedittoolbar',fig,'centeralign','state','off'});
end

%--------------------------------------------------------------------%
function m=find_rectangular_movemode(h,rh,point)
% returns correct move mode for a rectangular scribe object (rectangle,
% ellipse, textbox that is being resized. Move mode must be changed during
% resize when the affordance being dragged is dragged beyond one or more
% affordances on the opposite edge or edges.
% rh is handle to rectangular scribe object
% pt is current normalized point
pos = get(rh,'Position');
XL = pos(1);
XR = pos(1)+pos(3);
YU = pos(2)+pos(4);
YL = pos(2);

% move modes (affordance indices + 1)
% 2 7 3
% 6   8
% 5 9 4

m=rh.MoveMode;
switch m
 case 2 
  if point(1)>XR
    if point(2)<YL m=4;
    else m=3; end
  elseif point(2)<YL m=5; end
 case 3
  if point(1)<XL
    if point(2)<YL m=5;
    else m=2; end
  elseif point(2)<YL m=4; end
 case 4
  if point(1)<XL
    if point(2)>YU m=2;
    else m=5; end
  elseif point(2)>YU m=3; end
 case 5
  if point(1)>XR
    if point(2)>YU m=3;
    else m=4; end
  elseif point(2)>YU m=2; end
 case 6
  if point(1)>XR m=8; end
 case 7
  if point(2)<YL m=9; end
 case 8
  if point(1)<XL m=6; end
 case 9
  if point(2)>YU m=6; end
 otherwise
  return;
end

%--------------------------------------------------------------------%
function t=get_temp_text(h)

t = getappdata(double(h),'ScribeTestText');
if isempty(t) || ~ishandle(t)
  t=text('Units','points',...
         'Visible','off',...
         'HandleVisibility','off',...
         'Editing','off',...
         'Position',[0,0,0],...
         'Margin',1,...
         'Parent',double(h));
end
