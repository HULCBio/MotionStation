function nnd8qf(cmd,data)
%NND8QF Quadratic function demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

% BRING UP FIGURE IF IT EXISTS

me = 'nnd8qf';
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
  fig = nndemof2(me,'DESIGN','Quadratic Function','','Chapter 8');
  str = [me '(''down'',get(0,''pointerloc''))'];
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(8,458,363,'shadow')
  
  % INITIAL FUNCTION
  A = [1.5 -0.7; -0.7 1.0];
  d = [0.25; 0.25];
  c = 1;
  
  % FIND MINIMA OF APPROXIMATION
  minima = -pinv(A)*d;
  x0 = minima(1);
  y0 = minima(2);
  xx = xpts+x0;
  yy = ypts+y0;
  XX = X+x0;
  YY = Y+y0;
  F = (A(1,1)*XX.^2+(A(1,2)+A(2,1))*XX.*YY+A(2,2)*YY.^2)/2 +...
    d(1)*XX + d(2)*YY + c;
    
  % EIGENVECTORS
  [v,e] = eig(A);

  % FUNCTION
  text(200,140,'F(x) = 1/2*x''Ax + d''x + c',...
    'fontsize',22,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','center')

  % VARIABLES
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  text(55,65,'A=','fontsize',20,'fontweight','bold','color',nndkblue,'horiz','right')
  plot(bracket_x+60,bracket_y*7+30,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+160,bracket_y*7+30,'color',nndkblue,'linewidth',3);
  edit_a11 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[70 70 35 20],...
    'string',num2str(A(1,1)),...
    'callback',nncallbk(me,'edita'));
  edit_a12 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[115 70 35 20],...
    'string',num2str(A(1,2)),...
    'callback',nncallbk(me,'edita'));
  edit_a21 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[70 40 35 20],...
    'string',num2str(A(2,1)),...
    'callback',nncallbk(me,'edita'));
  edit_a22 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[115 40 35 20],...
    'string',num2str(A(2,2)),...
    'callback',nncallbk(me,'edita'));
  text(195,65,'d=','fontsize',20,'fontweight','bold','color',nndkblue,'horiz','right')
  plot(bracket_x+200,bracket_y*7+30,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+255,bracket_y*7+30,'color',nndkblue,'linewidth',3);
  edit_d1 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[210 70 35 20],...
    'string',num2str(d(1)),...
    'callback',nncallbk(me,'editd'));
  edit_d2 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[210 40 35 20],...
    'string',num2str(d(2)),...
    'callback',nncallbk(me,'editd'));
  text(295,65,'c=','fontsize',20,'fontweight','bold','color',nndkblue,'horiz','right')
  plot(bracket_x+300,bracket_y*4+45,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+355,bracket_y*4+45,'color',nndkblue,'linewidth',3);
  edit_c = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[310 55 35 20],...
    'string',num2str(c),...
    'callback',nncallbk(me,'editc'));

  % TOP LEFT AXES
  top_left = nnsfo('a4','Function F','x(1)','x(2)');
  set(top_left, ...
    'xlim',xlim+x0, ...
    'ylim',ylim+y0, ...
    'colororder',[nnblack; nnred; nngreen]);
  contour(xx,yy,F,10);
  nndrwvec([0 v(1,1)]+x0,[0 v(2,1)]+y0,2,0.2,nndkblue)
  nndrwvec([0 v(1,2)]+x0,[0 v(2,2)]+y0,2,0.2,nndkblue)
  plot(xlim+x0,[0 0]+y0,':','color',nndkblue)
  plot([0 0]+x0,ylim+y0,':','color',nndkblue)

  % BOTTOM LEFT AXES
  bottom_left = nnsfo('a5','Function F','x(1)','x(2)','F(x)');
  set(bottom_left, ...
    'xlim',xlim+x0, ...
    'ylim',ylim+y0);
  func_mesh = mesh(xx,yy,F);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  plot(xlim+x0,[0 0]+y0,':','color',nndkblue)
  plot([0 0]+x0,ylim+y0,':','color',nndkblue)
  view(3)
    
  % TEXT
  nnsettxt(desc_text, ...
    'Change the values of', ...
    'the Hessian matrix A,', ...
    'the vector d, and', ...
    'the constant c.  Then',...
    'click [Update] to see',...
    'the new function.',...
    '',...
    'Note that the Hessian',...
    'matrix A will always be',...
    'symmetric.')
    
  % CREATE BUTTONS
  drawnow % Let everything else appear before buttons 
  uicontrol(...
    'units','points',...
    'position',[410 146 60 20],...
    'string','Update',...
    'callback',[me '(''draw'')'])
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
    
  % DATA HANDLES
  a_ptr = nnsfo('data');
  set(a_ptr,'userdata',A);
  d_ptr = nnsfo('data');
  set(d_ptr,'userdata',d);
  c_ptr = nnsfo('data');
  set(c_ptr,'userdata',c);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text bottom_left top_left edit_a11 edit_a12,...
    edit_a21 edit_a22 edit_d1 edit_d2 edit_c a_ptr d_ptr c_ptr];
  set(fig,'userdata',H)
  
  % LOCK FIGURE AND RETURN
  set(fig,...
    'nextplot','new',...
    'pointer','arrow',...
    'color',nnltgray)

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
edit_a11 = H(5);
edit_a12 = H(6);
edit_a21 = H(7);
edit_a22 = H(8);
edit_d1 = H(9);
edit_d2 = H(10);
edit_c = H(11);
a_ptr = H(12);
d_ptr = H(13);
c_ptr = H(14);

% GET DATA

A = get(a_ptr,'userdata');
d = get(d_ptr,'userdata');
c = get(c_ptr,'userdata');

% COMMAND: EDIT A

cmd = lower(cmd);
if strcmp(cmd,'edita')
  
  % GET DATA
  a11 = str2num(get(edit_a11,'string'));
  if length(a11) == 0, a11 = A(1,1); set(edit_a11,'string',num2str(a11)); end
  a12 = str2num(get(edit_a12,'string'));
  if length(a12) == 0, a12 = A(1,2); set(edit_a12,'string',num2str(a12)); end
  a21 = str2num(get(edit_a21,'string'));
  if length(a21) == 0, a21 = A(2,1); set(edit_a21,'string',num2str(a21)); end
  a22 = str2num(get(edit_a22,'string'));
  if length(a22) == 0, a22 = A(2,2); set(edit_a22,'string',num2str(a22)); end
  if a12 ~= A(1,2)
    a21 = a12; set(edit_a21,'string',num2str(a21));
  elseif a21 ~= A(2,1)
    a12 = a21; set(edit_a12,'string',num2str(a12));
  end
  newA = [a11 a12; a21 a22];
  
  % SAVE DATA
  if any(any(newA ~= A))
    A = newA;
    set(a_ptr,'userdata',A);
  end

% COMMAND: EDIT D

elseif strcmp(cmd,'editd')
  
  % GET DATA
  d1 = str2num(get(edit_d1,'string'));
  if length(d1) == 0, d1 = d(1); set(edit_d1,'string',num2str(d1)); end
  d2 = str2num(get(edit_d2,'string'));
  if length(d2) == 0, d2 = d(2); set(edit_d2,'string',num2str(d2)); end
  newd = [d1; d2];
  
  % SAVE DATA
  if any(newd ~= d)
    d = newd;
    set(d_ptr,'userdata',d);
  end

% COMMAND: EDIT C

elseif strcmp(cmd,'editc')
  
  % GET DATA
  newc = str2num(get(edit_c,'string'));
  if length(newc) == 0, newc = c; set(edit_c,'string',num2str(c)); end
  
  % SAVE DATA
  if (newc ~= c)
    c = newc;
    set(c_ptr,'userdata',c);
  end

% COMMAND: DRAW

elseif strcmp(cmd,'draw')

  % FIND MINIMA OF APPROXIMATION
  minima = -pinv(A)*d;
  x0 = minima(1);
  y0 = minima(2);
  xx = xpts+x0;
  yy = ypts+y0;
  XX = X+x0;
  YY = Y+y0;
  F = (A(1,1)*XX.^2+(A(1,2)+A(2,1))*XX.*YY+A(2,2)*YY.^2)/2 +...
    d(1)*XX + d(2)*YY + c;

  % EIGENVECTORS
  [v,e] = eig(A);
  %v = v*(e/max(max(e)))*1.5;

  % TOP LEFT AXES
  axes(top_left)
  delete(get(top_left,'children'))
  set(top_left, ...
    'xlim',xlim+x0, ...
    'ylim',ylim+y0);
  contour(xx,yy,F,10);
  nndrwvec([0 v(1,1)]+x0,[0 v(2,1)]+y0,2,0.2,nndkblue)
  nndrwvec([0 v(1,2)]+x0,[0 v(2,2)]+y0,2,0.2,nndkblue)
  plot(xlim+x0,[0 0]+y0,':','color',nndkblue)
  plot([0 0]+x0,ylim+y0,':','color',nndkblue)
  
  % BOTTOM LEFT AXES
  axes(bottom_left)
  delete(get(bottom_left,'children'))
  set(bottom_left, ...
    'xlim',xlim+x0, ...
    'ylim',ylim+y0);
  func_mesh = mesh(xx,yy,F);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  view(3)
end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
