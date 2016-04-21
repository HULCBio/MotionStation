function nnd18hn(cmd,data)
%NND18HN Hopfield network demonstration.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================
% GLOBALS
global lambda;
global W;
global b;

% BRING UP FIGURE IF IT EXISTS

me = 'nnd18hn';
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
  fig = nndemof2(me,'DESIGN','Hopfield Network','','Chapter 18');
  str = [me '(''down'',get(0,''pointerloc''))'];
  
  % UNLOCK AND GET HANDLES
  
  set(fig,...
    'nextplot','add','pointer','watch',...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(18,458,363,'shadow')
  
  % INITIAL FUNCTION
  W = [0 1; 1 0];
  b = [0; 0];
  lambda = 1.4;
  
  % VARIABLES
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  y = 80;
  x = 85;
  text(x-5,y+35,'W=','fontsize',20,'fontweight','bold','color',nndkblue,'horiz','right')
  plot(bracket_x+x,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+x+100,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  edit_w11 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+40 35 20],...
    'string',num2str(W(1,1)),...
    'callback',nncallbk(me,'w'));
  edit_w12 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+55 y+40 35 20],...
    'string',num2str(W(1,2)),...
    'callback',nncallbk(me,'w'));
  edit_w21 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+10 35 20],...
    'string',num2str(W(2,1)),...
    'callback',nncallbk(me,'w'));
  edit_w22 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+55 y+10 35 20],...
    'string',num2str(W(2,2)),...
    'callback',nncallbk(me,'w'));
  
  x = 270;
  text(x-5,y+35,'b=','fontsize',20,'fontweight','bold','color',nndkblue,'horiz','right')
  plot(bracket_x+x,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+x+55,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  edit_b1 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+40 35 20],...
    'string',num2str(b(1)),...
    'callback',nncallbk(me,'b'));
  edit_b2 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+10 35 20],...
    'string',num2str(b(2)),...
    'callback',nncallbk(me,'b'));

  % GAIN BUTTONS
  fin_bar = uicontrol(...
    'units','points',...
    'position',[30 45 90 20],...
    'style','radio',...
    'string','Finite Gain:',...
    'backg',nnltgray,...
    'callback',[me '(''finite'')'],...
    'value',1);
  inf_bar = uicontrol(...
    'units','points',...
    'position',[30 20 90 20],...
    'style','radio',...
    'string','Infinite Gain:',...
    'backg',nnltgray,...
    'callback',[me '(''infinite'')']);

  % GAIN BAR
  x = 150;
  y = 60;
  len = 200;
  text(x,y,'Finite Gain Value:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lam_text = text(x+len,y,sprintf('%3.1f',lambda),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'2.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  lam_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lambda'')'],...
    'min',0,...
    'max',2,...
  'value',lambda);

  % TOP LEFT AXES
  if nnstuded
    xx = -1:0.08:1.0;
  else
    xx = -1.0:0.05:1.0;
  end
  yy = xx;
  [XX,YY] = meshgrid(xx,yy);
  F = zeros(length(xx),length(yy));
  for i=1:length(xx)
    for j=1:length(yy)
    a = [XX(i,j);YY(i,j)];
      F(i,j) = -0.5*a'*W*a - b'*a;
    for k=1:2
        temp1 = cos(pi/2*a(k));
        if (temp1 == 0)
          temp2 = -inf;
        else
          temp2 = log(temp1);
        end
      F(i,j) = F(i,j) - 4/(lambda*pi^2)*temp2;
      end
  end
  end

  top_left = nnsfo('a4','Lyapunov Function','a1','a2');
  set(top_left, ...
    'xlim',[-1 1], ...
    'ylim',[-1 1], ...
    'colororder',[nnblack; nnred; nngreen]);
  [dummy,func_cont] = contour(xx,yy,F,...
    [-5 -2 -1 -0.5 -0.041 -0.023 -0.003 0.017 0.16 0.45 1 2 4 8 16]);
  plot([-1 1],[0 0],':','color',nndkblue)
  plot([0 0],[-1 1],':','color',nndkblue)

  % BOTTOM LEFT AXES
  indxx = 3:2:(length(xx)-2);
  indyy = 3:2:(length(yy)-2);
  xx = xx(indxx);
  yy = yy(indyy);
  F = F(indxx,:);
  F = F(:,indyy);

  bottom_left = nnsfo('a5','Lyapunov Function','a1','a2','V(a)');
  set(bottom_left, ...
    'xlim',[-1 1], ...
    'ylim',[-1 1]);
  func_mesh = mesh(xx,yy,F);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  view(3)
    
  % TEXT
  nnsettxt(desc_text, ...
    'Click in the left',...
  'graph to simulate',...
  'the Hopfield network.',...
  '',...
  'Change the weights,',...
  'biases, and gain',...
  'then click [Update]',...
  'to change the',...
  'network.')

  % ROTATE BUTTONS
  left_button = uicontrol(...
    'units','points',...
    'pos',[230 170 20 20],...
    'string','<<',...
    'callback',[me '(''left'')']);
  right_button = uicontrol(...
    'units','points',...
    'pos',[320 170 20 20],...
    'string','>>',...
    'callback',[me '(''left'')']);
    
  % CREATE BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 146 60 20],...
    'string','Update',...
    'callback',[me '(''update'')'])
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
  W_ptr = uicontrol('visible','off','userdata',W);
  b_ptr = uicontrol('visible','off','userdata',b);
  lambda_ptr = uicontrol('visible','off','userdata',lambda);
  path_ptr = uicontrol('visible','off','userdata',[]);
  func_mesh_ptr = uicontrol('visible','off','userdata',func_mesh);
  func_cont_ptr = uicontrol('visible','off','userdata',func_cont);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text bottom_left top_left edit_w11 edit_w12,...
    edit_w21 edit_w22 edit_b1 edit_b2 fin_bar inf_bar lam_text lam_bar,...
  W_ptr b_ptr lambda_ptr path_ptr func_mesh_ptr func_cont_ptr];
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
edit_w11 = H(5);
edit_w12 = H(6);
edit_w21 = H(7);
edit_w22 = H(8);
edit_b1 = H(9);
edit_b2 = H(10);
fin_bar = H(11);
inf_bar = H(12);
lam_text = H(13);
lam_bar = H(14);
W_ptr = H(15);
b_ptr = H(16);
lambda_ptr = H(17);
path_ptr = H(18);
func_mesh_ptr = H(19);
func_cont_ptr = H(20);

% GET DATA

W = get(W_ptr,'userdata');
b = get(b_ptr,'userdata');
lambda = get(lambda_ptr,'userdata');

% COMMAND: EDIT W

cmd = lower(cmd);
if strcmp(cmd,'w')
  
  % GET DATA
  w11 = str2num(get(edit_w11,'string'));
  if length(w11) == 0, w11 = W(1,1); set(edit_w11,'string',num2str(w11)); end
  w12 = str2num(get(edit_w12,'string'));
  if length(w12) == 0, w12 = W(1,2); set(edit_w12,'string',num2str(w12)); end
  w21 = str2num(get(edit_w21,'string'));
  if length(w21) == 0, w21 = W(2,1); set(edit_w21,'string',num2str(w21)); end
  w22 = str2num(get(edit_w22,'string'));
  if length(w22) == 0, w22 = W(2,2); set(edit_w22,'string',num2str(w22)); end
  newW = [w11 w12; w21 w22];
  
  % SAVE DATA
  if any(any(newW ~= W))
    W = newW;
    set(W_ptr,'userdata',W);
  end

% COMMAND: EDIT B

elseif strcmp(cmd,'b')
  
  % GET DATA
  b1 = str2num(get(edit_b1,'string'));
  if length(b1) == 0, b1 = b(1); set(edit_b1,'string',num2str(b1)); end
  b2 = str2num(get(edit_b2,'string'));
  if length(b2) == 0, b2 = b(2); set(edit_b2,'string',num2str(b2)); end
  newd = [b1; b2];
  
  % SAVE DATA
  if any(newd ~= b)
    b = newd;
    set(b_ptr,'userdata',b);
  end

% COMMAND: FIN

elseif strcmp(cmd,'finite')
  
  % GET DATA
  set(fin_bar,'value',1);
  set(inf_bar,'value',0);
  new_lambda = get(lam_bar,'value');
  
  % SAVE DATA
  if (new_lambda ~= lambda)
    lambda = new_lambda;
    set(lambda_ptr,'userdata',lambda);
  end

% COMMAND: INF

elseif strcmp(cmd,'infinite')
  
  % GET DATA
  set(fin_bar,'value',0);
  set(inf_bar,'value',1);
  new_lambda = inf;
  
  % SAVE DATA
  if (new_lambda ~= lambda)
    lambda = new_lambda;
    set(lambda_ptr,'userdata',lambda);
  end

% COMMAND: LAMBDA

elseif strcmp(cmd,'lambda')
  
  % GET DATA
  new_lambda = get(lam_bar,'value');
  set(lam_text,'string',sprintf('%3.2f',new_lambda));
  
  if get(fin_bar,'value') & (new_lambda ~= lambda)
    lambda = new_lambda;
    set(lambda_ptr,'userdata',lambda);
  end

% COMMAND: CLICK DOWN ON AXIS

elseif strcmp(cmd,'down')

  axes(top_left)
  [in,x,y] = nnaxclik(top_left);
  if (in)
    path = get(path_ptr,'userdata');
    delete(path);
    if finite(lambda)
      n0 = [2*tan(pi*x/2)/lambda/pi; 2*tan(pi*y/2)/lambda/pi];
      [T,N] = ode45('nndhop',[0 10],n0);
      a = 2*atan(lambda*pi*N/2)/pi;
    else
      n0 = [x;y];
      [T,N] = ode45('nndhopi',[0 10],n0);
      a = N.*(N<1)+(N>=1);
    a = a.*(a>-1)-(a<=-1);
    end
    path = [plot(a(1,1),a(1,2),'b.','markersize',18);
            plot(a(:,1),a(:,2),'b','linewidth',1);
            plot(a(length(T),1),a(length(T),2),'bo','markersize',6)];
    set(path_ptr,'userdata',path);
  end

% COMMAND: UPDATE

elseif strcmp(cmd,'update')

  path = get(path_ptr,'userdata');
  delete(path);
  set(path_ptr,'userdata',[]);
  
  func_mesh = get(func_mesh_ptr,'userdata');
  func_cont = get(func_cont_ptr,'userdata');
  delete(func_mesh)
  delete(func_cont)

  % TOP LEFT
  axes(top_left)
  if nnstuded
    xx = -1:0.08:1.0;
  else
    xx = -1.0:0.05:1.0;
  end
  yy = xx;
  [XX,YY] = meshgrid(xx,yy);
  F = zeros(length(xx),length(yy));
  for i=1:length(xx)
    for j=1:length(yy)
    a = [XX(i,j);YY(i,j)];
      F(i,j) = -0.5*a'*W*a - b'*a;
    for k=1:2
        temp1 = cos(pi/2*a(k));
        if (temp1 == 0)
          temp2 = -inf;
        else
          temp2 = log(temp1);
        end
      F(i,j) = F(i,j) - 4/(lambda*pi^2)*temp2;
      end
  end
  end
  [dummy,func_cont] = contour(xx,yy,F,...
     [-5 -2 -1 -0.5 -0.041 -0.023 -0.003 0.017 0.16 0.45 1 2 4 8 16]);
  
  % TOP RIGHT
  axes(bottom_left)
  indxx = 3:2:(length(xx)-2);
  indyy = 3:2:(length(yy)-2);
  xx = xx(indxx);
  yy = yy(indyy);
  F = F(indxx,:);
  F = F(:,indyy);
  func_mesh = mesh(xx,yy,F);
  set(func_mesh,...
    'edgecolor',nnblack, ...
    'facecolor',nnwhite)
  view(3)
  
  set(func_mesh_ptr,'userdata',func_mesh);
  set(func_cont_ptr,'userdata',func_cont);

% COMMAND: LEFT

elseif strcmp(cmd,'left')

  v = get(bottom_left,'view');
  set(bottom_left,'view',[v(1)+45 v(2)]);

% COMMAND: RIGHT

elseif strcmp(cmd,'left')

  v = get(bottom_left,'view')
  set(bottom_left,'view',[v(1)-45 v(2)]);

end

% LOCK FIGURE
set(fig,'nextplot','new','pointer','arrow')
