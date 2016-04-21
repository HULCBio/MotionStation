function cameramenu(varargin)
%CAMERAMENU  Interactively manipulate camera.
%   CAMERAMENU creates a new menu that enables interactive
%   manipulation of a scene's camera and light by dragging the
%   mouse on the figure window; the camera properties of the
%   current axes (gca) are affected. Several camera properties
%   are set when the menu is initialized. 
%
%   CAMERAMENU('noreset') creates the menu without setting any
%   camera properties.
% 
%   CAMERAMENU('close') removes the menu.
%
%   Note: Either mouse button can be used to move the camera or
%   light. Clicking the right mouse button will stop camera or
%   light movements.
%
%   Note: Rendering performance is affected by presence of OpenGL 
%   hardware.
%
%   See also ROTATE3D, ZOOM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/15 04:29:01 $


persistent walk_flag
[hfig,haxes]=currenthandles;

Udata = getUdata;

if nargin==0
  if iscameraobj(haxes)
    axis(haxes,'vis3d')
    axis(haxes,axis(haxes))
	camproj(haxes,'perspective');
    renmode = get(hfig, 'renderermode');
  end
  try
    set(hfig, 'renderer', 'opengl');
  catch
    warning('OpenGL renderer not available.')
  end
  % Workaround for bug: if Opengl does not load, the renderermode 
  % is not reset to previous value.
  if ~strcmp(lower(get(hfig, 'renderer')), 'opengl')
    set(hfig, 'renderermode', renmode)
  end
  arg = 'init';
  scribeclearmode(hfig,'cameramenu', 'nomode');
else
  arg = lower(varargin{1});
  if ~strcmp(arg, 'init') & ~strcmp(arg, 'motion') & isempty(Udata)
    cameramenu('init')
    Udata = getUdata;
    if ~strcmp(arg, 'nomode')
      scribeclearmode(hfig,'cameramenu', 'nomode');
    end
  end
end

switch arg
case 'down'
   origUnits=get(hfig,'units');
   set(hfig,'units','pixels');
   pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
   set(hfig,'units',origUnits);
   Udata.figStartPoint = pt;
   Udata.figLastPoint  = pt;
   Udata.figLastLastPoint = pt;
   Udata.buttondown = 1;
   Udata.moving = 0;
   setUdata(Udata)

   if ~iscameraobj(haxes)
	   return;
   end
   if strcmp(Udata.movedraw, 'box') & isempty(Udata.savestate.ax)
     Udata.savestate.children = findobj(haxes, 'visible', 'on');
     Udata.savestate.fig = get(hfig);
     Udata.savestate.ax = get(haxes);
     if ~strcmp(get(hfig, 'renderer'), 'OpenGL')
       set(hfig, 'renderer', 'painters')
     end
     set(get(haxes,'children'), 'vis', 'off')
     set(haxes, 'color', 'none', 'visible', 'on');
     figColor = get(hfig, 'color');
     if sum(figColor .* [.3 .6 .1]) > .5
       contrastColor = 'k';
     else
       contrastColor = 'w';
     end
     if isequal(figColor, get(haxes, 'xcolor'))
       set(haxes, 'xcolor', contrastColor);
     end
     if isequal(figColor, get(haxes, 'ycolor'))
       set(haxes, 'ycolor', contrastColor);
     end
     if isequal(figColor, get(haxes, 'zcolor'))
       set(haxes, 'zcolor', contrastColor);
     end
     ticks(haxes,'off')
     box(haxes,'on')
   end

   setUdata(Udata)

   validateScenelight(haxes)
   updateScenelightOnOff(Udata.scenelightOn)
   
   
case 'motion'
  if isstruct(Udata) & Udata.buttondown 
   	origUnits=get(hfig,'units');
	set(hfig,'units','pixels');
	pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
	set(hfig,'units',origUnits);
    deltaPix  = pt-Udata.figLastPoint;
    deltaPixStart  = pt-Udata.figStartPoint;
    Udata.figLastLastPoint = Udata.figLastPoint;
    Udata.figLastPoint = pt;
    
    Udata.time = clock;
    
    mode = lower(Udata.mode);
    hvmode = lower(Udata.mouseconstraint);
    if hvmode(1) == 'h'
      deltaPix(2) = 0;
      deltaPixStart(2) = 0;
    elseif hvmode(1) == 'v'
      deltaPix(1) = 0;
      deltaPixStart(1) = 0;
    end
    
    setUdata(Udata)
    if ~iscameraobj(haxes)
	   return;
    end
    switch mode
      case 'orbit'
	orbitPangca(haxes,deltaPix, 'o');
      case 'orbit scenelight'
	orbitLightgca(haxes,deltaPix);
      case 'pan'
	orbitPangca(haxes,deltaPix, 'p');
      case 'dolly horiz/vert'
	dollygca(haxes,deltaPix);
      case 'zoom'
	zoomgca(haxes,deltaPix);
      case 'dolly in/out'
	forwardBackgca(haxes,deltaPix, 'c');
      case 'roll'
	rollgca(haxes,deltaPix, pt);
      case 'walk'
	Udata.moving=1;
	setUdata(Udata)
	if isempty(walk_flag)
            walk_flag = 1;
            walkgca(haxes,deltaPixStart,[]);
	else
            walkgca(haxes,deltaPixStart,1);
	end
    end
  end
case 'up'
  Udata.buttondown = 0;
  Udata.moving   = 0;
  origUnits=get(hfig,'units');
  set(hfig,'units','pixels');
  pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
  set(hfig,'units',origUnits);
  deltaPix  = pt-Udata.figLastLastPoint;
  deltaPixStart  = pt-Udata.figStartPoint;
  Udata.figLastPoint = pt;
  % Checking the sensitivity of the camera throw mode w.r.t mouse events
  % Speed at the end being proportional to the dist travelled at the end...
  speed_sense = sqrt((deltaPix(1)^2)+(deltaPix(2)^2));
  % Total distance travelled from start to finish:
  dist_sense = sqrt((deltaPixStart(1)^2)+(deltaPixStart(2)^2));
  % Scaling down the speed of motion in the throw mode
  mode = lower(Udata.mode);
  clear walk_flag;
  
  hvmode = lower(Udata.mouseconstraint);
  if hvmode(1) == 'h'
    deltaPix(2) = 0;
    deltaPixStart(2) = 0;
  elseif hvmode(1) == 'v'
    deltaPix(1) = 0;
    deltaPixStart(1) = 0;
  end
  
  setUdata(Udata)
  if ~iscameraobj(haxes)
	 return;
  end
  % Scale down the deltas to get a reasonable speed.
  scaled_deltaPix = deltaPix/10;
  scaled_deltaPixStart = deltaPixStart/10;
  if etime(clock, Udata.time)<.1 & (speed_sense>=7) & (dist_sense>30) ...
	& any(deltaPix) & ~strcmp('alt', get(hfig, 'selectiontype'))
    Udata.moving = 1;
    setUdata(Udata)
    switch mode
      case 'orbit'
	orbitPangca(haxes,scaled_deltaPix, 'o');
      case 'orbit scenelight'
	orbitLightgca(haxes,scaled_deltaPix);
      case 'pan'
	orbitPangca(haxes,scaled_deltaPix, 'p');
      %case 'roll'
	%rollgca(haxes,deltaPix);
	  case 'walk'
	walkgca(haxes,scaled_deltaPixStart,1);

    end
  end
     
  if strcmp(Udata.movedraw, 'box') & ~isempty(Udata.savestate.ax)
    set(Udata.savestate.children, 'vis', 'on')
    set(hfig, 'Renderer',     Udata.savestate.fig.Renderer    );
    set(hfig, 'RendererMode', Udata.savestate.fig.RendererMode);
    set(haxes, 'Color',     Udata.savestate.ax.Color    )
    set(haxes, 'Visible',   Udata.savestate.ax.Visible  )
    set(haxes, 'XColor',    Udata.savestate.ax.XColor   )
    set(haxes, 'YColor',    Udata.savestate.ax.YColor   )
    set(haxes, 'ZColor',    Udata.savestate.ax.ZColor   )
    set(haxes, 'Xtick',     Udata.savestate.ax.XTick    )
    set(haxes, 'XtickMode', Udata.savestate.ax.XTickMode)
    set(haxes, 'Ytick',     Udata.savestate.ax.YTick    )
    set(haxes, 'YtickMode', Udata.savestate.ax.YTickMode)
    set(haxes, 'Ztick',     Udata.savestate.ax.ZTick    )
    set(haxes, 'ZtickMode', Udata.savestate.ax.ZTickMode)
    set(haxes, 'Box',       Udata.savestate.ax.Box      )
    Udata.savestate.ax = [];
    setUdata(Udata)
   end
   
case 'stopmoving'
  Udata.moving = 0;
  setUdata(Udata)
case 'updatemenu'
  updateMenu(hfig,haxes);
case 'changemode'
  if strcmp(Udata.mode, get(gcbo, 'Label'))
    cameramenu('nomode')
    Udata = getUdata;
  else
    Udata.mode = get(gcbo, 'Label');
    scribeclearmode(hfig,'cameramenu', 'nomode');
  end
  if iscameraobj(haxes)
	  if strcmp(Udata.mode, 'Walk')
		  camproj(haxes,'perspective');
	  end
  end
  setUdata(Udata)
  updateMenu(hfig,haxes);
case 'changecoordsys'
  Udata.coordsys = get(gcbo, 'Label');
  setUdata(Udata)

  if iscameraobj(haxes)
	  if length(Udata.coordsys)==1
		  coordsysval =  lower(Udata.coordsys) - 'x' + 1;
		  
		  d = [0 0 0];
		  d(coordsysval) = 1;
		  
		  up = camup(haxes);
		  if up(coordsysval) < 0
			  d = -d;
		  end
		  
		  % Check if the camera up vector is parallel with the view direction;
		  % if not, set the up vector
		  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
			  camup(haxes,d)
			  updateScenelightPosition;
		  end  
	  end
  end
  updateMenu(hfig,haxes);
case 'changescenelight'
  val = toggleOnOff(gcbo);
  if ~val & strcmp(Udata.mode, 'Orbit Scenelight')
    Udata.mode = 'Orbit';
    setUdata(Udata)
  end
  validateScenelight(haxes)
  updateScenelightOnOff(val)
  updateScenelightPosition
case 'changeaxesvisible'
  toggleOnOff(gcbo)
  axis(haxes,get(gcbo, 'checked'))
case 'changeaxesbox'
  if toggleOnOff(gcbo)
    axis(haxes,'on')
  end
  box(haxes,get(gcbo, 'checked'))
case 'changeaxesgrid'
  if iscameraobj(haxes)
	  if toggleOnOff(gcbo)
		  axis(haxes,'on')
		  ticks(haxes,'on')
	  end
	  grid(haxes,get(gcbo, 'checked'))
  end
case 'changeaxesticks'
  if iscameraobj(haxes)
	  if toggleOnOff(gcbo)
		  axis(haxes,'on')
	  else
		  grid(haxes,'off')
	  end
	  ticks(haxes,get(gcbo, 'checked'))
  end
case 'changeaxesprojection'
  if iscameraobj(haxes)
	  camproj(haxes,get(gcbo, 'Label'));
  end
case 'changeaxescolor'
  str = get(gcbo, 'Label');
  str = str(1:end-3);
  if str(1)=='W'
    str = 'color';
  else
    str(2) = [];
  end
  set(haxes, str, uisetcolor(get(haxes, str)))
case 'changerenderer'
  set(hfig, 'renderer', get(gcbo, 'label'))
case 'changerenderermode'
  if toggleOnOff(gcbo)
    set(hfig, 'renderermode', 'auto')
  else
    set(hfig, 'renderermode', 'manual')
  end
case 'changemovedraw'
  if toggleOnOff(gcbo)
    Udata.movedraw = 'box';
  else
    Udata.movedraw = 'same';
  end
  setUdata(Udata)
case 'changefigcolor'
  set(hfig, 'color', uisetcolor(get(hfig, 'color')))
case 'changedoublebuffer'
  toggleOnOff(gcbo)
  set(hfig, 'doublebuffer', get(gcbo, 'checked'))
case 'changenosort'
  if toggleOnOff(gcbo)
    set(haxes, 'drawmode', 'fast')
  else
    set(haxes, 'drawmode', 'normal')
  end
case 'resetscenelight'
  if iscameraobj(haxes)
	  Udata.scenelightAz = 0;
	  Udata.scenelightEl = 0;
	  setUdata(Udata)
	  validateScenelight(haxes)
	  updateScenelightPosition
  end
case 'resetall'
  if ishandle(Udata.scenelight)     delete(Udata.scenelight);     end
  initUdata;
  updateMenu(hfig,haxes)
  cameramenu('resetcamera');
case 'resetcamera'
  if iscameraobj(haxes)
	  resetCameraProps(haxes)
	  cameramenu('resetscenelight');
  end
case 'changemouseconstraint'
  Udata.mouseconstraint = get(gcbo, 'Label');
  setUdata(Udata)
  updateMenu(hfig,haxes)
case 'checkcdata'
  objs=[findobj(haxes, 'type', 'patch'); findobj(haxes, 'type', 'surface')];
  for j = 1:length(objs)
    obj = objs(j);
    if strcmp(get(obj, 'visible'), 'on') & isempty(get(obj, 'cdata'))
      warndlg('Not all visible surfaces and patches have cdata', '')
      return
    end
  end
  eval(varargin{2});
case 'noreset'
  cameramenu('init');
case 'nomode'
  Udata.mode = '';
  restoreWindowCallbacks(hfig,Udata.wcb);
  setUdata(Udata)
  updateMenu(hfig,haxes)
  restoreWindowCursor(hfig,Udata.cursor);
case 'init'
  emptyUdata = isempty(Udata);
  wcb = getWindowCallbacks(hfig);
  cursor = getWindowCursor(hfig);
  initWindowCallbacks(hfig)
  menus = findobj(hfig, 'type', 'uimenu');
  cammenu = findobj(menus, 'tag', 'cm598');
  if isempty(cammenu)
    createMenu(hfig,haxes);
  end
  if ~emptyUdata&ishandle(Udata.scenelight)    
    delete(Udata.scenelight);      
  end
  initUdata
  Udata = getUdata;
  if emptyUdata
    Udata.wcb = wcb;
    Udata.cursor = cursor;
  end
  setUdata(Udata)
  updateMenu(hfig,haxes)
case 'close'
  restoreWindowCallbacks(hfig,Udata.wcb);
  restoreWindowCursor(hfig,Udata.cursor);
  cameramenu('stopmoving')
  if ishandle(Udata.scenelight)     delete(Udata.scenelight);     end
  if ishandle(Udata.mainMenuHandle) delete(Udata.mainMenuHandle); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDrawnow

Udata = getUdata;

if Udata.moving == 1
  drawnow
else
  drawnow expose
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitPangca(haxes,xy, mode)
Udata = getUdata;

%mode = 'o';  orbit
%mode = 'p';  pan


coordsys = lower(Udata.coordsys);
if coordsys(1)=='u'
  coordsysval = 0;
else
  coordsysval = coordsys(1) - 'x' + 1;
end

xy = -xy;

if mode=='p' % pan
  panxy = xy*camva(haxes)/500;
end
  
if coordsysval>0
  d = [0 0 0];
  d(coordsysval) = 1;
  
  up = camup(haxes);
  upsidedown = (up(coordsysval) < 0);
  if upsidedown 
    xy(1) = -xy(1);
    d = -d;
  end

  % Check if the camera up vector is parallel with the view direction;
  % if not, set the up vector
  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
    camup(haxes,d)
  end  
end

flag = 1;

while sum(abs(xy))> 0 & isstruct(Udata) & (flag | Udata.moving==1)
  flag = 0;
  
  if mode=='o' %orbit
    if coordsysval==0 %unconstrained
      camorbit(haxes,xy(1), xy(2), coordsys)
    else
      camorbit(haxes,xy(1), xy(2), 'data', coordsys)
    end
  else %pan
    if coordsysval==0 %unconstrained
      campan(haxes,panxy(1), panxy(2), coordsys)
    else
      campan(haxes,panxy(1), panxy(2), 'data', coordsys)
    end
  end
  
  updateScenelightPosition;
  localDrawnow;
  Udata = getUdata;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitLightgca(haxes,xy)
Udata = getUdata;

if sum(abs(xy))> 0 & ~Udata.scenelightOn
  updateScenelightOnOff(1)
  Udata = getUdata;
end

% Check if the light is on the other side of the object
az = mod(abs(Udata.scenelightAz),360);
if az > 90 & az < 270
  xy(2) = -xy(2);
end

flag = 1;

while sum(abs(xy))> 0 & isstruct(Udata) & (flag | Udata.moving==1)
  flag = 0;
  
  Udata.scenelightAz = mod(Udata.scenelightAz + xy(1), 360);
  Udata.scenelightEl = mod(Udata.scenelightEl + xy(2), 360);
  
  if abs(Udata.scenelightEl) > 90
    Udata.scenelightEl = 180 - Udata.scenelightEl;
    Udata.scenelightAz = 180 + Udata.scenelightAz;
    xy(2) = -xy(2);
  end

  setUdata(Udata)
  updateScenelightPosition
  
  localDrawnow;
  Udata = getUdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function walkgca(haxes,xy1,walk_flag)
persistent xy v up d cva q
xy = xy1;
Udata = getUdata;

coordsys = lower(Udata.coordsys);
if coordsys(1)=='u'
  coordsysval = 0;
else
  coordsysval = coordsys(1) - 'x' + 1;
end

if coordsysval>0
  d = [0 0 0];
  d(coordsysval) = 1;

  up = camup(haxes);
  if up(coordsysval) < 0
    d = -d;
  end
end

q = max(-.9, min(.9, xy(2)/700));
cva = camva(haxes);

recursionflag = 1;

while sum(abs(xy))> 0 & isstruct(Udata) & recursionflag & Udata.moving==1
  
  if coordsysval==0 %unconstrained
    campan(haxes,xy(1)*cva/700, 0, 'camera')
    v = q*(camtarget(haxes)-campos(haxes));
  else
    campan(haxes,xy(1)*cva/700, 0, 'data', d)
	
	% Check if the camera up vector is parallel with the view direction;
	% if not, set the up vector
	if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
		camup(haxes,d);
	end
	
    v = q*(camtarget(haxes)-campos(haxes));
    v(coordsysval) = 0;
  end
  camdolly(haxes,v(1), v(2), v(3), 'movetarget', 'data')
  updateScenelightPosition;
  if isempty(walk_flag)
	  localDrawnow;
  else
	  drawnow expose
	  recursionflag = 0;
  end
  Udata = getUdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dollygca(haxes,xy)
camdolly(haxes,-xy(1), -xy(2), 0, 'movetarget', 'pixels')
updateScenelightPosition;
localDrawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% not used
%
function flipgca(xy)
Udata = getUdata;

xy = -xy;

flag = 1;

while isstruct(Udata) & (flag | Udata.moving==1)
  flag = 0;

  camorbit(haxes,xy(1), xy(2), 'camera')
  
  updateScenelightPosition;
  
  drawnow
  Udata = getUdata;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zoomgca(haxes,xy)
q = max(-.9, min(.9, sum(xy)/70));
camzoom(haxes,1+q);
localDrawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forwardBackgca(haxes,xy, mode)

q = max(-.9, min(.9, sum(xy)/70));

if mode=='b'
  camdolly(haxes,0,0,q);
else
  camdolly(haxes,0,0,q, 'f');
end

updateScenelightPosition;
localDrawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rollgca(haxes,dxy, pt)
Udata = getUdata;

% find the pixel center of the axes
units = get(haxes, 'units');
set(haxes, 'units', 'pix');
pos = get(haxes, 'pos');
center = pos(1:2)+pos(3:4)/2;
set(haxes, 'units', units);

startpt = pt - dxy;

v1 = pt-center;
v2 = startpt-center;

v1 = v1/norm(v1);
v2 = v2/norm(v2);
theta = acos(sum(v2.*v1)) * 180/pi;
cross =  crossSimple([v1 0],[v2 0]);
if cross(3) >0
  theta = -theta;
end

flag = 1;

while isstruct(Udata) & (flag | Udata.moving==1)
  flag = 0;
  
  camroll(haxes,theta);
  
  updateScenelightPosition;

  localDrawnow;
  Udata = getUdata;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createMenu(hfig,haxes)

Udata.mainMenuHandle = uimenu('Label','&Camera', ...
    'callback', 'cameramenu(''updatemenu'')');

%Udata.mainMenuHandle=uicontextmenu( ...
%    'callback', 'cameramenu(''updatemenu'')');
%set(hfig, 'uicontextmenu', Udata.mainMenuHandle)


%%
%% Mode
%%
Udata.modeMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Mouse Mode');
uimenu(Udata.modeMenuHandle, ...
    'Label','Orbit', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Orbit Scenelight', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Pan', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Dolly Horiz/Vert', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Dolly In/Out', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Zoom', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Roll', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Walk', ...
    'callback', 'cameramenu(''changemode'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','X', 'tag', 'coordsys', 'separator', 'on', ...
    'callback', 'cameramenu(''changecoordsys'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Y', 'tag', 'coordsys',...
    'callback', 'cameramenu(''changecoordsys'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Z', 'tag', 'coordsys',...
    'callback', 'cameramenu(''changecoordsys'')');
uimenu(Udata.modeMenuHandle, ...
    'Label','Unconstrained', 'tag', 'coordsys',...
    'callback', 'cameramenu(''changecoordsys'')');

%%
%% Mouse constraint
%%
Udata.mouseConstraintMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Mouse Constraint');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label','Horizontal', ...
    'callback', 'cameramenu(''changemouseconstraint'')');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label','Vertical', ...
    'callback', 'cameramenu(''changemouseconstraint'')');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label','Unconstrained', ...
    'callback', 'cameramenu(''changemouseconstraint'')');

%%
%% Stop moving
%%
Udata.stopmovingMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Stop Moving', ...
    'callback', 'cameramenu(''stopmoving'')');

%%
%% Scenelight
%%
Udata.scenelightMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Scenelight', ...
    'callback', 'cameramenu(''changescenelight'')');

%%
%% Reset
%%
Udata.resetMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Reset');
uimenu(Udata.resetMenuHandle, ...
    'Label','Reset Modes/Camera Properties', ...
    'callback', 'cameramenu(''resetall'')');
uimenu(Udata.resetMenuHandle, ...
    'Label','Reset Camera Properties', ...
    'callback', 'cameramenu(''resetcamera'')');
uimenu(Udata.resetMenuHandle, ...
    'Label','Reset Target Point', ...
    'callback', 'camtarget(gca(gcbf),''auto''); camtarget(gca(gcbf),camtarget(gca(gcbf))); cameramenu(''resetscenelight'');');
uimenu(Udata.resetMenuHandle, ...
    'Label','Reset Scenelight', ...
    'callback', 'cameramenu(''resetscenelight'')');


%%
%% Scene
%%
Udata.sceneMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Scene');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Fit All', ...
    'callback','camlookat(gca(gcbf))');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Lighting None',  'separator', 'on',...
    'callback', 'lighting(gca(gcbf),''none'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Lighting Flat', ...
    'callback', 'lighting(gca(gcbf),''flat'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Lighting Gouraud', ...
    'callback', 'lighting(gca(gcbf),''gouraud'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Lighting Phong', ...
    'callback', 'lighting(gca(gcbf),''phong'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Shading Faceted', 'separator', 'on',...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''faceted'''')'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Shading Flat',...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''flat'''')'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Shading Interp',...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''interp'''')'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Clipping On', 'separator', 'on',...
    'callback', 'set(findobj(gca(gcbf)), ''clipping'', ''on'')');
uimenu(Udata.sceneMenuHandle, ...
    'Label','Clipping Off',...
    'callback', 'set(findobj(gca(gcbf)), ''clipping'', ''off'')');

%%
%% Axes
%%
Udata.axesMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Axes');
uimenu(Udata.axesMenuHandle, ...
    'Label','Visible', ...
    'callback', 'cameramenu(''changeaxesvisible'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Box', ...
    'callback', 'cameramenu(''changeaxesbox'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Ticks', ...
    'callback', 'cameramenu(''changeaxesticks'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Grid', ...
    'callback', 'cameramenu(''changeaxesgrid'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Walls Color...','separator', 'on',...
    'callback', 'cameramenu(''changeaxescolor'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','X Color...',...
    'callback', 'cameramenu(''changeaxescolor'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Y Color...',...
    'callback', 'cameramenu(''changeaxescolor'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Z Color...',...
    'callback', 'cameramenu(''changeaxescolor'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Orthographic','separator', 'on',  ...
    'callback', 'cameramenu(''changeaxesprojection'')');
uimenu(Udata.axesMenuHandle, ...
    'Label','Perspective',...
    'callback', 'cameramenu(''changeaxesprojection'')');

%%
%% Renderer
%%
Udata.rendererMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Renderer Options');
uimenu(Udata.rendererMenuHandle, ...
    'Label','Painters', ...
    'callback', 'cameramenu(''changerenderer'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','  Double Buffer', ...
    'callback', 'cameramenu(''changedoublebuffer'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','  No Sort', ...
    'callback', 'cameramenu(''changenosort'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','Zbuffer', ...
    'callback', 'cameramenu(''changerenderer'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','OpenGL', ...
    'callback', 'cameramenu(''changerenderer'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','Auto', ...
    'callback', 'cameramenu(''changerenderermode'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','Move As Box','separator', 'on',  ...
    'callback', 'cameramenu(''changemovedraw'')');
uimenu(Udata.rendererMenuHandle, ...
    'Label','Background Color...','separator', 'on', ...
    'callback', 'cameramenu(''changefigcolor'')');

%%
%% Remove menu
%%
Udata.removeMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label','Remove Menu', ...
    'callback', 'cameramenu(''close'')');


set(Udata.mainMenuHandle, 'tag', 'cm598');
setUdata(Udata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateMenu(hfig,haxes)
Udata = getUdata;

menu = Udata.mainMenuHandle;
if isempty(Udata.mode)
  str = '&Camera';
elseif strmatch(Udata.mode, {'Orbit' 'Pan' 'Walk'}) 
  str = ['&Camera (' Udata.mode ', '  Udata.coordsys ')' ];
else	
  str = ['&Camera (' Udata.mode ')' ];
end

set(menu, 'label', str)

children = get(Udata.mainMenuHandle, 'children');
set(children, 'checked', 'off');

%%
%% Mode
%%
children = get(Udata.modeMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Label', Udata.mode);
set(menu, 'checked', 'on')
menu = findobj(children, 'Label', Udata.coordsys);
set(menu, 'checked', 'on')
children = get(Udata.modeMenuHandle, 'children');
menus = findobj(children, 'tag', 'coordsys');
if ~isempty(Udata.mode)
  set(menus, 'enable', bool2OnOff(strmatch(Udata.mode, {'Orbit' 'Pan' 'Walk'})))
else
  set(menus, 'enable', 'off')
end

%%
%% Stop Moving
%%
set(Udata.stopmovingMenuHandle, 'enable', bool2OnOff(Udata.moving))

%%
%% Scenelight
%%
if ~ishandle(Udata.scenelight)
   Udata.scenelightOn = 0;
end
set(Udata.scenelightMenuHandle, 'checked', bool2OnOff(Udata.scenelightOn));

%%
%% Mouse motion constraint
%%
children = get(Udata.mouseConstraintMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Label', Udata.mouseconstraint);
set(menu, 'checked', 'on')

%%
%% Axes
%%
children = get(Udata.axesMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Label', 'Visible');
set(menu, 'checked', get(haxes, 'visible'))
menu = findobj(children, 'Label', 'Box');
set(menu, 'checked', get(haxes, 'box'))
menu = findobj(children, 'Label', 'Grid');
set(menu, 'checked', get(haxes, 'xgrid'))
menu = findobj(children, 'Label', 'Ticks');
set(menu, 'checked', bool2OnOff(~isempty(get(haxes, 'xtick'))))
menu = findobj(children, 'Label', capitalize(camproj(haxes)));
set(menu, 'checked', 'on')

%%
%% Renderer
%%
children = get(Udata.rendererMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Label', capitalize(get(hfig, 'renderer')));
set(menu, 'checked', 'on')
menu = findobj(children, 'Label', 'Auto');
set(menu, 'checked', bool2OnOff(strcmp(get(hfig, 'renderermode'), 'auto')))

enable = bool2OnOff(strcmp(get(hfig, 'renderer'), 'painters'));
menu = findobj(children, 'Label', '  Double Buffer');
set(menu, 'checked', get(hfig, 'doublebuffer'), ...
    'enable', enable)
menu = findobj(children, 'Label', '  No Sort');
set(menu, 'checked', bool2OnOff(strcmp(get(haxes, 'drawmode'), 'fast')), ...
    'enable', enable)
menu = findobj(children, 'Label', 'Move As Box');
set(menu, 'checked', bool2OnOff(strcmp(Udata.movedraw, 'box')))


if ~isempty(Udata.mode)
  cdata = [
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan 1   nan nan nan nan nan nan nan nan 1   nan nan nan 
    nan nan 1   1   nan nan nan nan nan nan nan nan 1   1   nan nan 
    nan 1   2   1   1   1   1   1   1   1   1   1   1   2   1   nan 
    1   2   2   2   2   2   2   2   2   2   2   2   2   2   2   1   
    1   2   2   2   2   2   2   2   2   2   2   2   2   2   2   1   
    nan 1   2   1   1   1   1   1   1   1   1   1   1   2   1   nan 
    nan nan 1   1   nan nan nan nan nan nan nan nan 1   1   nan nan 
    nan nan nan 1   nan nan nan nan nan nan nan nan 1   nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    ];
  
  hvmode = lower(Udata.mouseconstraint);
  if hvmode(1) == 'h'
    cdata = cdata;
  elseif hvmode(1) == 'v'
    cdata =cdata';
  else  % make cross
    cdata([5 6 11 12],4 ) = nan;
    cdata([5 6 11 12],13) = nan;
    a = cdata;
    b = cdata';
    newcdata = nan*zeros(16);
    newcdata(a==1 | b==1) = 1;
    newcdata(a==2 | b==2) = 2;
    cdata = newcdata;
  end
  
  set(hfig, 'pointer', 'custom', 'pointershapecdata', cdata, ...
      'pointershapehotspot', [8 8]);
  initWindowCallbacks(hfig)
  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Udata = getUdata

[hfig,haxes]=currenthandles;

%h = hfig;
h = findobj(get(hfig,'children'), 'type', 'uimenu', 'tag', 'cm598');
if ~isempty(h)
  Udata = get(h(1), 'userdata');
else
  Udata = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setUdata(Udata)

[hfig,haxes]=currenthandles;

%h = hfig;
h = findobj(get(hfig,'children'), 'type', 'uimenu', 'tag', 'cm598');
if ~isempty(h)
  set(h(1), 'userdata', Udata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initUdata
Udata = getUdata;

Udata.mode = 'Orbit';
Udata.coordsys = 'Z';
Udata.mouseconstraint = 'Unconstrained';
Udata.movedraw = 'same';
Udata.savestate.ax = [];

Udata.buttondown = 0;
Udata.moving = 0;
Udata.time = clock;
Udata.scenelightOn=0;
Udata.scenelight=-1;
Udata.scenelightAz = 0;
Udata.scenelightEl = 0;

setUdata(Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightPosition
Udata = getUdata;
if Udata.scenelightOn
  camlight(Udata.scenelight, Udata.scenelightAz, Udata.scenelightEl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightOnOff(val)
Udata = getUdata;
Udata.scenelightOn = val;
set(Udata.scenelight, 'vis', bool2OnOff(val))
setUdata(Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function validateScenelight(haxes)
Udata = getUdata;
if ~ishandle(Udata.scenelight)
  Udata.scenelight = camlight(light('parent',haxes));
  set(Udata.scenelight, 'vis', 'off')
  setUdata(Udata)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initWindowCallbacks(hfig)
set(hfig, 'windowbuttondownfcn',   'cameramenu(''down''  )')
set(hfig, 'windowbuttonmotionfcn', 'cameramenu(''motion'')')
set(hfig, 'windowbuttonupfcn',     'cameramenu(''up''    )')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCallbacks(hfig)
ret{1} = get(hfig, 'windowbuttondownfcn'   );
ret{2} = get(hfig, 'windowbuttonmotionfcn' );
ret{3} = get(hfig, 'windowbuttonupfcn'     );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = restoreWindowCallbacks(hfig,cb)
set(hfig, 'windowbuttondownfcn',   cb{1});
set(hfig, 'windowbuttonmotionfcn', cb{2});
set(hfig, 'windowbuttonupfcn',     cb{3});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCursor(hfig)
ret{1} = get(hfig, 'pointer'  );
ret{2} = get(hfig, 'pointershapecdata' );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = restoreWindowCursor(hfig,cursor)
set(hfig, 'pointer'  ,         cursor{1});
set(hfig, 'pointershapecdata', cursor{2});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=bool2OnOff(val)
if val
  ret = 'on';
else
  ret = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=toggleOnOff(h)
newval = strcmp(get(h, 'checked'), 'off');
set(h, 'checked', bool2OnOff(newval));
if nargout>0
  ret = newval;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=capitalize(str)
ret = [upper(str(1)) str(2:end)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ticks(haxes,arg)

switch arg
  case 'off' 
    set(haxes, 'xtick', [], 'ztick', [], 'ytick', [])
  case 'on'
    set(haxes, 'xtickmode', 'a', 'ztickmode','a', 'ytickmode', 'a')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple cross product
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetCameraProps(haxes)
camva(haxes,'auto'); campos(haxes,'auto'); camtarget(haxes,'auto'); daspect(haxes,'auto'); camup(haxes,'auto'); 
view(haxes,3);
daspect(haxes,daspect(haxes)); camva(haxes,camva(haxes)); 
axis(haxes,'tight');
camproj(haxes,'perspective');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=iscameraobj(haxes)
% Checking if the selected axes is for a valid object to perform camera functions on.

if ~isa(handle(haxes),'graph2d.legend') & ~isa(handle(haxes),'graph3d.colorbar')
	val = logical(1);
else
	val = logical(0);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig,haxes]=currenthandles
% Obtaining the correct handle to the current figure and axes in all cases:
% handlevisibility ON-gcbf; OFF-gcbf/gcf.

if ~isempty(gcbf)
	hfig=gcbf;
	haxes=get(gcbf,'CurrentAxes');
else
	hfig=gcf;
	haxes=gca;
end
