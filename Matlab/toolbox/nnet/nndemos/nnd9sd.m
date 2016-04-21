function nnd9sd(cmd,data)
%NND9SD Steepest descent demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% BRING UP FIGURE IF IT EXISTS

me = 'nnd9sd';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS
max_update = 20;
xlim = [-2 2]; dx = 0.2;
ylim = [-2 2]; dy = 0.2;
zlim = [0 12];
xpts = xlim(1):dx:xlim(2);
ypts = ylim(1):dy:ylim(2);
[X,Y] = meshgrid(xpts,ypts);
xtick = [-2 0 2];
ytick = [-2 0 2];
ztick = [0 6 12];
circle_size = 8;

% CREATE FIGURE ========================================================

if fig == 0

  % CONSTANTS
  lr = 0.03;
  lr_min = 0;
  lr_max = 0.2;

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Steepest Descent','','Chapter 9');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,'windowbuttondownfcn',str);
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  nndicon(9,458,363,'shadow')
    
  % SLIDER
  y = 40;
  text(30,y,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_slider = uicontrol(...
    'units','points',...
    'position',[140 y-7 160 16],...
    'style','slider',...
    'min',lr_min,...
    'max',lr_max,...
    'callback',[me '(''lr'')'],...
    'value',lr);
  text(140,y-20,sprintf('%4.2f',lr_min),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(300,y-20,sprintf('%4.2f',lr_max),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right')
  lr_text = text(220,y-20,['(' num2str(lr) ')'],...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','center');

  % LEFT AXES
  left = nnsfo('a2','Function F','x(1)','x(2)');
  set(left, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);
  F = (Y-X).^4 + 8*X.*Y - X + Y + 3;
  F = min(max(F,zlim(1)),zlim(2));
  [dummy,func_cont] = contour(xpts,ypts,F,[1.01 2 3 4 6 8 10]);
  cont_color = [nnblack; nnred; nngreen];
  for i=1:length(func_cont)
    set(func_cont(i),'edgecolor',cont_color(rem(i,3)+1,:),'linewidth',1);
  end
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);
  
  % RIGHT AXES
  right = nnsfo('a3','Approximation Fa','x(1)','x(2)');
  set(right, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);

  % TEXT
  nnsettxt(desc_text, ...
    'STEEPEST DESCENT',...
    'Click anywhere on the graph to create an initial guess. Then the steepest descent',...
    'trajectory will be shown. You can reset the learning rate using the slider below, and',...
    'a new trajectory will be shown. Experiment with different initial guesses and',...
    'learning rates.')

  % CREATE BUTTONS
  set(nnsfo('b4','Contents'), ...
    'callback','nndtoc')
  nnsfo('b5','Close');
  
  % DATA POINTER: MARKER
  marker_ptr = nnsfo('data');
  set(marker_ptr,'userdata',[]);
  
  % DATA POINTER: CURRENT POINT
  point_ptr = nnsfo('data');
  set(point_ptr,'userdata',[]);
  
  % DATA POINTER: PATH
  path_ptr = nnsfo('data');
  set(path_ptr,'userdata',[]);

  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text left right marker_ptr point_ptr path_ptr ...
    lr_slider lr_text];
  set(fig,'userdata',H)
  
  % LOCK FIGURE AND RETURN
  set(fig,'nextplot','new','pointer','arrow','color',nnltgray)

  nnchkfs;

  return
end

% SERVICE COMMANDS =======================================================

% UNLOCK FIGURE AND GET HANDLES
set(fig,'nextplot','add','pointer','watch')
H = get(fig,'userdata');
desc_text = H(2);
left = H(3);
right = H(4);
marker_ptr = H(5);
point_ptr = H(6);
path_ptr = H(7);
lr_slider = H(8);
lr_text = H(9);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(left)
  pt = get(left,'currentpoint');
  x = pt(1);
  y = pt(3);
  if (x < xlim(1)) | (x > xlim(2)) | (y < ylim(1)) | (y > ylim(2))
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
  
  % FIND VALUE AT POINT
  Fo = (y-x).^4 + 8*x.*y - x + y + 3;
  if (Fo < zlim(1)) | (Fo > zlim(2))
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
   
  % SHOW POINT
  axes(left);
  delete(get(marker_ptr,'userdata'));
  o_mark1 = plot(x,y,'ok','markersize',circle_size);
  o_mark2 = plot(x,y,'ow','markersize',circle_size+2);
  o_mark3 = plot(x,y,'ok','markersize',circle_size+4);
  set(marker_ptr,'userdata',[o_mark1 o_mark2 o_mark3]);
  
  % REMOVE OLD PATH
  delete(get(right,'children'))
  path = get(path_ptr,'userdata');
  delete(path);
  set(path_ptr,'userdata',[]);

  % STORE POINT & DRAW
  set(point_ptr,'userdata',[x y Fo]);
  cmd = 'draw';
  
% COMMAND: LR

elseif strcmp(cmd,'lr')
  
  lr = get(lr_slider,'value');
  set(lr_text,'string',['(' sprintf('%4.2f',round(lr*100)*0.01) ')' ])
  cmd = 'draw';
end

% COMMAND: DRAW

if strcmp(cmd,'draw')

  % GET DATA
  lr = get(lr_slider,'value');
  point = get(point_ptr,'userdata');
  if length(point) == 0
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
  x = point(1);
  y = point(2);
  Fo = point(3);
  
  % FIND GRADIENT AT POINT
  gx = -4*(y-x)^3 + 8*y - 1;
  gy = 4*(y-x)^3 + 8*x + 1;
  grad = [gx; gy];

  % CREATE APPROXIMATION
  dX = X - x;
  dY = Y - y;
  Fa = grad(1)*dX + grad(2)*dY + Fo;

  % PLOT CONTOUR
  axes(right);
  delete(get(right,'children'))
  [dummy,func_cont] = contour(xpts,ypts,Fa,10);
  cont_color = [nnblack; nnred; nngreen];
  for i=1:length(func_cont)
    set(func_cont(i),'edgecolor',cont_color(rem(i,3)+1,:),'linewidth',1);
  end
  plot(x,y,'ok','markersize',circle_size);
  plot(x,y,'ow','markersize',circle_size+2);
  plot(x,y,'ok','markersize',circle_size+4);

  % OPTIMIZE
  xx = [x zeros(1,max_update)];
  yy = [y zeros(1,max_update)];
  for i=1:max_update
    gx = -4*(y-x)^3 + 8*y - 1;
    gy = 4*(y-x)^3 + 8*x + 1;
    nx = x-lr*gx;
    ny = y-lr*gy;
    xx(i+1) = nx;
    yy(i+1) = ny;
    x = nx;
    y = ny;
  end

  % REMOVE OLD PATH
  path = get(path_ptr,'userdata');
  delete(path);

  % PLOT PATH
  axes(right)
  plot(xx(1:2),yy(1:2),...
    'color',nnred);
  plot(xx(2),yy(2),'o',...
    'color',nndkblue');
  axes(left)
  path1 = plot(xx,yy,...
    'color',nnred);
  xx(1) = [];
  yy(1) = [];
  path2 = plot(xx,yy,'o',...
    'color',nndkblue');
  set(path_ptr,'userdata',[path1 path2])
  drawnow
end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
