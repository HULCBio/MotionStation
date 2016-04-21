function nnd9sdq(cmd,data)
%NND9SDQ Steepest descent for quadratic function demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% BRING UP FIGURE IF IT EXISTS

me = 'nnd9sdq';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS

xlim = [-4 4]; dx = 0.2;
ylim = [-2 2]; dy = 4/31;
zlim = [0 80];
xpts = xlim(1):dx:xlim(2);
ypts = ylim(1):dy:ylim(2);
[X,Y] = meshgrid(xpts,ypts);
xtick = [-4 -2 0 2 4];
ytick = [-2 0 2];
ztick = [0 6 12];
aratio=[NaN NaN];
circle_size = 8;
conts=[1  4  8   16 ]*3;

% DEFINE THE PROBLEM

a=[2 0;0 50];
b=[0 0];
c=0;
max_epoch=50;

% CREATE FIGURE ========================================================

if fig == 0

  % CONSTANTS
  lr = 0.03;
  lr_min = 0;
  lr_max = 0.06;
  F = (a(1,1)*X.^2 + (a(1,2)+a(2,1))*X.*Y + a(2,2)*Y.^2)/2 ...
         + b(1)*X + b(2)*Y +c;

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Steepest Descent for Quadratic','','Chapter 9');
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
  text(30,40,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_slider = uicontrol(...
    'units','points',...
    'position',[140 33 160 16],...
    'style','slider',...
    'min',lr_min,...
    'max',lr_max,...
    'callback',[me '(''lr'')'],...
    'value',lr);
  text(140,20,sprintf('%4.2f',lr_min),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(300,20,sprintf('%4.2f',lr_max),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right')
  lr_text = text(220,20,['(' num2str(lr) ')'],...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','center');

  %  AXES
  graph = nnsfo('a1','Function F','x(1)','x(2)');
  set(graph, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick)      %, ...
    %'aspectratio',aratio);

  F = min(max(F,zlim(1)),zlim(2));
  [dummy,func_cont] = contour(xpts,ypts,F,conts);
  cont_color = [nnblack; nnred; nngreen];
  for i=1:length(func_cont)
    set(func_cont(i),'edgecolor',cont_color(rem(i,3)+1,:),'linewidth',1);
  end
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);
  
  % TEXT
  nnsettxt(desc_text, ...
    'STEEPEST DESCENT',...
    'Click anywhere on the graph to create an initial guess. Then the steepest descent',...
    'trajectory will be shown. You can reset the learning rate using the slider below,', ...
    'and a new trajectory will be shown. Experiment with different initial guesses and',...
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
  H = [fig_axis desc_text graph marker_ptr point_ptr path_ptr ...
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
graph = H(3);
marker_ptr = H(4);
point_ptr = H(5);
path_ptr = H(6);
lr_slider = H(7);
lr_text = H(8);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(graph)
  pt = get(graph,'currentpoint');
  x = pt(1);
  y = pt(3);
  if (x < xlim(1)) | (x > xlim(2)) | (y < ylim(1)) | (y > ylim(2))
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
   
  % SHOW POINT
  axes(graph);
  delete(get(marker_ptr,'userdata'));
  o_mark1 = plot(x,y,'ok','markersize',circle_size);
  o_mark2 = plot(x,y,'ow','markersize',circle_size+2);
  o_mark3 = plot(x,y,'ok','markersize',circle_size+4);
  set(marker_ptr,'userdata',[o_mark1 o_mark2 o_mark3]);
  
  % STORE POINT & DRAW
  set(point_ptr,'userdata',[x y]);
  cmd = 'draw';
  

% COMMAND: LR

elseif strcmp(cmd,'lr')
  
  lr = get(lr_slider,'value');
  set(lr_text,'string',['(' sprintf('%4.3f',round(lr*1000)*0.001) ')' ])
  cmd = 'draw';
end

% COMMAND: DRAW

if strcmp(cmd,'draw')

  % GET DATA
  lr = get(lr_slider,'value');
  % GET POINT
  point = get(point_ptr,'userdata');
  if length(point) == 0
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
  x = point(1);
  y = point(2);

  % REMOVE OLD PATH
  path = get(path_ptr,'userdata');
  delete(path);
  set(path_ptr,'userdata',[]);

  % PERFORM THE ITERATIONS OF STEEPEST DESCENT
  for i=1:max_epoch,
    % SAVE OLD VALUES
    Lx=x;
    Ly=y;

    % FIND GRADIENT AT POINT
    grad=a*[x;y]+b';
    gx = grad(1);
    gy = grad(2);
  
    % FIND LOWER ERROR POINT
    x = x - lr*gx;
    y = y - lr*gy;

    % PLOT THE STEP
    path = get(path_ptr,'userdata');
    path = [path plot(x,y,'o','color',nndkblue,'markersize',circle_size*.75) ...
               plot([Lx x],[Ly y],'color',nnred,'linewidth',1)];
    set(path_ptr,'userdata',path);

  end
  

  % PLOT PATH
  drawnow

end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
