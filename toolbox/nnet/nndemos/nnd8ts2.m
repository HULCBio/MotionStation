function nnd8ts2(cmd,data)
%NND8TS2 Taylor series demonstration #2.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $
% First Version, 8-31-95.

%==================================================================

% BRING UP FIGURE IF IT EXISTS

me = 'nnd8ts2';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS

xlim = [-2 2]; dx = 0.2;
ylim = [-2 2]; dy = 0.2;
zlim = [0 12];
xpts = xlim(1):dx:xlim(2);
ypts = ylim(1):dy:ylim(2);
[X,Y] = meshgrid(xpts,ypts);
xtick = [-2 0 2];
ytick = [-2 0 2];
ztick = [0 6 12];
circle_size = 10;

% CREATE FIGURE ========================================================

if fig == 0

  % STANDARD DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Taylor Series #2','','Chapter 8');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,'windowbuttondownfcn',str);
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(8,458,363,'shadow')
  
  % BOTTOM LEFT AXES
  bottom_left = nnsfo('a6','Function','x(1)','x(2)','');
  set(bottom_left, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick,...
    'zlim',zlim,'ztick',ztick);
  F = (Y-X).^4 + 8*X.*Y - X + Y + 3;
  F = min(max(F,zlim(1)),zlim(2));
  func_mesh = mesh(xpts,ypts,F);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  view(3)
  
  % TOP LEFT AXES
  top_left = nnsfo('a4','Function','x(1)','x(2)');
  set(top_left, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);
  [dummy,func_cont] = contour(xpts,ypts,F,[1.01 2 3 4 6 8 10]);
  cont_color = [nnblack; nnred; nngreen];
  for i=1:length(func_cont)
    set(func_cont(i),'edgecolor',cont_color(rem(i,3)+1,:),'linewidth',1);
  end
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);
  
  % BOTTOM RIGHT AXES
  bottom_right = nnsfo('a7','Approximation','x(1)','x(2)','');
  set(bottom_right, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick,...
    'zlim',zlim,'ztick',ztick);
  view(3)

  % TOP RIGHT AXES
  top_right = nnsfo('a5','Approximation','x(1)','x(2)');
  set(top_right, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);

  % TEXT
  nnsettxt(desc_text, ...
    'Click in the contours', ...
    'of the top-left graph', ...
    'to create a Taylor', ...
    'series approximation.',...
    '',...
    'Select the order of',...
    'the approximation',...
    'with the buttons',...
    'below.')

  % CREATE BUTTONS
  drawnow % Let everything else appear before buttons 
  
  callbk = [me '(''order'',0)'];
  order_0 = uicontrol(...
    'units','points',...
    'position',[410 195 60 20],...
    'style','radio',...
    'string','Order 0',...
    'backg',nnltgray,...
    'callback',callbk);
  callbk = [me '(''order'',1)'];
  order_1 = uicontrol(...
    'units','points',...
    'position',[410 170 60 20],...
    'style','radio',...
    'string','Order 1',...
    'backg',nnltgray,...
    'callback',callbk);
  callbk = [me '(''order'',2)'];
  order_2 = uicontrol(...
    'units','points',...
    'position',[410 145 60 20],...
    'style','radio',...
    'string','Order 2',...
    'callback',callbk,...
    'backg',nnltgray,...
    'value',1);

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 110 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 110-36 60 20],...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA POINTER: MARKER
  marker_ptr = nnsfo('data');
  set(marker_ptr,'userdata',[]);
  
  % DATA POINTER: ORDER
  order_ptr = nnsfo('data');
  set(order_ptr,'userdata',2);
  
  % DATA POINTER: APPROXIMATION POINT
  point_ptr = nnsfo('data');
  set(point_ptr,'userdata',[]);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text bottom_left top_left bottom_right top_right,...
       marker_ptr order_0 order_1 order_2 order_ptr point_ptr];
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
bottom_left = H(3);
top_left = H(4);
bottom_right = H(5);
top_right = H(6);
marker_ptr = H(7);
order_0 = H(8);
order_1 = H(9);
order_2 = H(10);
order_ptr = H(11);
point_ptr = H(12);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(top_left)
  pt = get(top_left,'currentpoint');
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
  axes(top_left);
  delete(get(marker_ptr,'userdata'));
  o_mark1 = plot(x,y,'ok','markersize',circle_size);
  o_mark2 = plot(x,y,'ow','markersize',circle_size+2);
  o_mark3 = plot(x,y,'ok','markersize',circle_size+4);
  set(marker_ptr,'userdata',[o_mark1 o_mark2 o_mark3]);
  drawnow
  
  % STORE POINT & DRAW
  set(point_ptr,'userdata',[x y Fo]);
  cmd = 'draw';
    
% COMMAND: ORDER

elseif strcmp(cmd,'order')
  if data == 0
    set(order_0,'value',1);
    set(order_1,'value',0);
    set(order_2,'value',0);
  elseif data == 1
    set(order_0,'value',0);
    set(order_1,'value',1);
    set(order_2,'value',0);
  else
    set(order_0,'value',0);
    set(order_1,'value',0);
    set(order_2,'value',1);
    data = 2;
  end
  
  % STORE ORDER AND DRAW
  set(order_ptr,'userdata',data);
  cmd = 'draw';
end

% COMMAND: DRAW

if strcmp(cmd,'draw')
  
  % GET POINT
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
  grd = [gx; gy];

  % CREATE HESSIAN
  temp = 12*(y-x)^2;
  hes = [temp 8-temp;8-temp temp];
  
  % CREATE APPROXIMATION
  dX = X - x;
  dY = Y - y;
  
  order = get(order_ptr,'userdata');
  if order == 0
    Fa = zeros(size(X)) + Fo;
  elseif order == 1
    Fa = grd(1)*dX + grd(2)*dY + Fo;
  else
    Fa = (hes(1,1)*dX.^2 + (hes(1,2)+hes(2,1))*dX.*dY + hes(2,2)*dY.^2)/2 +...
      grd(1)*dX + grd(2)*dY + Fo;
  end
  Fa = min(max(Fa,zlim(1)),zlim(2));
  
  % PLOT CONTOUR
  axes(top_right);
  delete(get(top_right,'children'))
  [dummy,func_cont] = contour(xpts,ypts,Fa,[1 2 3 4 6 8 10]);
  cont_color = [nnblack; nnred; nngreen];
  for i=1:length(func_cont)
    set(func_cont(i),'edgecolor',cont_color(rem(i,3)+1,:),'linewidth',1);
  end
  plot(x,y,'ok','markersize',circle_size);
  plot(x,y,'ow','markersize',circle_size+2);
  plot(x,y,'ok','markersize',circle_size+4);
  drawnow
  
  % PLOT APPROXIMATION
  axes(bottom_right)
  delete(get(bottom_right,'children'))
  func_mesh = mesh(xpts,ypts,Fa);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  view(3)
  drawnow
end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
