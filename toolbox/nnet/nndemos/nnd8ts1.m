function nnd8ts1(cmd,data)
%NND8TS Taylor series demonstration #1.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $
% First Version, 8-31-95.

%==================================================================

% BRING UP FIGURE IF IT EXISTS

me = 'nnd8ts1';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CONSTANTS

xlim = [-6 6]; dx = 0.03;
ylim = [-2 2];
xpts = xlim(1):dx:xlim(2);
xtick = [-6 -3 0 3 6];
ytick = [-2 -1 0 1 2];
circle_size = 10;

% CREATE FIGURE ========================================================

if fig == 0

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Taylor Series #1','','Chapter 8');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,'windowbuttondownfcn',str);
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(8,458,363,'shadow')
  
  % LEFT AXES
  left = nnsfo('a2','cos(x)','x','');
  set(left, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);
  f = cos(xpts);
  func_plot = plot(xpts,f,'k','linewidth',2);
  text(0,1.7,'< CLICK ON ME >',...
    'horiz','center', ...
    'fontweight','bold',...
    'color',nndkblue);
  
  % RIGHT AXES
  right = nnsfo('a3','Approximation','x','');
  set(right, ...
    'xlim',xlim,'xtick',xtick, ...
    'ylim',ylim,'ytick',ytick);

  % TEXT
  nnsettxt(desc_text, ...
    'TAYLOR SERIES APPROXIMATION',...
    '',...
    'Click in the left graph to create a Taylor series approximation',...
    'of the cosine function.',...
    '',...
    'Click on the check-box buttons at the right of the window to turn',...
    'various orders of approximation on and off.')

  % CREATE BUTTONS
  drawnow % Let everything else appear before buttons 
  
  callbk = [me '(''order'')'];
  order_n = uicontrol(...
    'units','points',...
    'position',[430 290 60 20],...
    'style','check',...
    'string','Function',...
    'backg',nnltgray,...
    'callback',callbk,...
    'value',1);
  order_0 = uicontrol(...
    'units','points',...
    'position',[430 265 60 20],...
    'style','check',...
    'string','Order 0',...
    'backg',nnltgray,...
    'callback',callbk);
  order_1 = uicontrol(...
    'units','points',...
    'position',[430 240 60 20],...
    'style','check',...
    'string','Order 1',...
    'backg',nnltgray,...
    'callback',callbk,...
    'value',1);
  order_2 = uicontrol(...
    'units','points',...
    'position',[430 215 60 20],...
    'style','check',...
    'string','Order 2',...
    'callback',callbk,...
    'backg',nnltgray);
  order_3 = uicontrol(...
    'units','points',...
    'position',[430 190 60 20],...
    'style','check',...
    'string','Order 3',...
    'callback',callbk,...
    'backg',nnltgray);
  order_4 = uicontrol(...
    'units','points',...
    'position',[430 165 60 20],...
    'style','check',...
    'string','Order 4',...
    'callback',callbk,...
    'backg',nnltgray);

  % BUTTONS
  set(nnsfo('b5'),...
    'string','Contents',...
    'callback','nndtoc')
  set(nnsfo('b6'),...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA POINTER: MARKER
  marker_ptr = nnsfo('data');
  set(marker_ptr,'userdata',[]);
  
  % DATA POINTER: APPROXIMATION POINT
  point_ptr = nnsfo('data');
  set(point_ptr,'userdata',[]);

  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text left right marker_ptr,...
    order_n order_0 order_1 order_2 order_3 order_4 point_ptr];
  set(fig,'userdata',H)
  
  % LOCK FIGURE AND DRAW
  set(fig,'nextplot','new')
  set(fig,'pointer','arrow')
  
  % LOCK WINDOW AND RETURN
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
order_n = H(6);
order_0 = H(7);
order_1 = H(8);
order_2 = H(9);
order_3 = H(10);
order_4 = H(11);
point_ptr = H(12);

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
  fo = cos(x);
  if (fo < ylim(1)) | (fo > ylim(2))
     set(fig,'nextplot','new','pointer','arrow')
     return
  end
   
  % SHOW POINT
  axes(left);
  delete(get(marker_ptr,'userdata'));
  o_mark1 = plot(x,fo,'ok','markersize',circle_size);
  o_mark2 = plot(x,fo,'ow','markersize',circle_size+2);
  o_mark3 = plot(x,fo,'ok','markersize',circle_size+4);
  set(marker_ptr,'userdata',[o_mark1 o_mark2 o_mark3]);
  drawnow
  
  % STORE POINT & DRAW
  set(point_ptr,'userdata',[x fo]);
  cmd = 'draw';
    
% COMMAND: ORDER

elseif strcmp(cmd,'order')
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
  fo = point(2);
  
  fn = cos(xpts);
  f0 = fo + zeros(size(xpts));
  f1 = f0 - sin(x)*(xpts-x);
  f2 = f1 - cos(x)*((xpts-x).^2)/2;
  f3 = f2 + sin(x)*((xpts-x).^3)/6;
  f4 = f3 + cos(x)*((xpts-x).^4)/24;
  
  % PLOT APPROXIMATION
  axes(right);
  delete(get(right,'children'))
  if get(order_n,'value')
    plot(xpts,fn,'k','linewidth',2);
  end
  if get(order_0,'value')
    plot(xpts,f0,'r');
  end
  if get(order_1,'value')
    plot(xpts,f1,'r');
  end
  if get(order_2,'value')
    plot(xpts,f2,'color',nngreen);
  end
  if get(order_3,'value')
    plot(xpts,f3,'b');
  end
  if get(order_4,'value')
    plot(xpts,f4,'m');
  end
  plot(x,fo,'ok','markersize',circle_size);
  plot(x,fo,'ow','markersize',circle_size+2);
  plot(x,fo,'ok','markersize',circle_size+4);
  drawnow
end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
