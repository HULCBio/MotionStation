function nnd8dd(cmd,data)
%NND8DD Directional derivatives demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

% BRING UP FIGURE IF IT EXISTS

me = 'nnd8dd';

fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end


% CONSTANTS
x1_lim = [-4 4];
x2_lim = [-2 2];
a=[1 0; 0 2];
b=zeros(2,1);
c=0;
mx=100;
marker_size = 10;

% CREATE FIGURE ========================================================

if fig == 0

  % STANDARD DEMO FIGURE
  fig = nndemof(me,'DESIGN','Directional Derivatives','','Chapter 8');
  str = [me '(''down'',get(0,''pointerloc''))'];
  set(fig,'WindowButtonDownFcn',str);
  
  % UNLOCK AND GET HANDLES
  
  set(fig,'nextplot','add','pointer','watch')
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);
  
  % ICON
  
  nndicon(8,458,363,'shadow');
  
  % BIG AXES
  big = nnsfo('a1','Function F','x(1)','x(2)');
  set(big,...
    'position',[38 153 320 160])
  x1 = x1_lim(1):(x1_lim(2)-x1_lim(1))/30:x1_lim(2);
  x2 = x2_lim(1):(x2_lim(2)-x2_lim(1))/30:x2_lim(2);
  [X1,X2] = meshgrid(x1,x2);
  F = (a(1,1)*X1.^2 + (a(1,2)+a(2,1))*X1.*X2 + a(2,2)*X2.^2)/2 ...
    + b(1)*X1 + b(2)*X2 +c;

  contour(x1,x2,F,[0.01 1:12]);

  little = nnsfo('a1','','','Directional Derivative');
  set(little,...
    'position',[38+377-20 153 20 160],...
    'xlim',[-0.2 1.2],...
    'xtick',[],...
    'ylim',[-6.5 6.5],...
    'ytick',[-6 -3 0 3 6])

  % CREATE BUTTONS
  set(nnsfo('b5'),...
    'string','Contents',...
    'callback','nndtoc')
  set(nnsfo('b6'),...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA HANDLES
  marker_ptr = nnsfo('data');
  set(marker_ptr,'userdata',[]);
  position_ptr = nnsfo('data');
  set(position_ptr,'userdata',[]);
  line_ptr = nnsfo('data');
  set(line_ptr,'userdata',[]);
  derivative_ptr = nnsfo('data');
  set(derivative_ptr,'userdata',[]);
  
  % SAVE HANDLES, LOCK FIGURE
  H = [fig_axis desc_text big little marker_ptr position_ptr line_ptr derivative_ptr];
  set(fig,'userdata',H)

  % TEXT
  nnsettxt(desc_text,...
    'DIRECTIONAL DERIVATIVES',...
    '',...
    'To measure a directional derivative click on the graph and move',...
    'the cursor while holding your mouse button down.',...
    '',...
    'The directional derivative is taken at the point you clicked in the',...
    'direction of the current cursor position.');
    
  % LOCK WINDOW AND RETURN
  set(fig,'nextplot','new','pointer','arrow','color',nnltgray)

  nnchkfs;

  return
end

% SERVICE COMMANDS =======================================================

% UNLOCK FIGURE AND GET HANDLES
set(fig,'nextplot','add','pointer','arrow')
H = get(fig,'userdata');
desc_text = H(2);
big = H(3);
little = H(4);
marker_ptr = H(5);
position_ptr = H(6);
line_ptr = H(7);
derivative_ptr = H(8);

% COMMAND: DOWN

cmd = lower(cmd);
if strcmp(cmd,'down')

  % FIND CLICK POSITION
  axes(big)
  pt = get(big,'currentpoint');
  x1 = pt(1);
  x2 = pt(3);
  if (x1 < x1_lim(1)) | (x1 > x1_lim(2)) | (x2 < x2_lim(1)) | (x2 > x2_lim(2))
    set(fig,'nextplot','new','pointer','arrow')
    return
  end
  
  % MOVE MARKER
  marker = get(marker_ptr,'userdata');
  delete(marker);
  marker = [plot(x1,x2,'ok','markersize',marker_size,'erasemode','xor');
            plot(x1,x2,'or','markersize',marker_size+2,'erasemode','xor');
            plot(x1,x2,'ob','markersize',marker_size+4,'erasemode','xor');
    plot(x1,x2,'ok','markersize',marker_size+6,'erasemode','xor')];
  set(marker_ptr,'userdata',marker);
  set(position_ptr,'userdata',[x1 x2]);
  
  % ENABLE MOTION AND UP ACTIONS
  str = [me '(''motion'',get(0,''pointerloc''))'];
  set(fig,'WindowButtonMotionFcn',str);
  str = [me '(''up'',get(0,''pointerloc''))'];
  set(fig,'WindowButtonUpFcn',str);

% COMMAND: MOTION

elseif strcmp(cmd,'motion')

  % FIND CLICK POSITION
  axes(big)
  pt = get(big,'currentpoint');
  y1 = pt(1);
  y2 = pt(3);

  % GET MARKER POSITON
  position = get(position_ptr,'userdata');
  x1 = position(1);
  x2 = position(2);
  
  % NORMALIZE LINE LENGTH
  angle = atan2(y2-x2,y1-x1);
  y1 = x1+cos(angle);
  y2 = x2+sin(angle);
  
  % MOVE LINE
  the_line = get(line_ptr,'userdata');
  delete(the_line);
  the_line = plot3([x1 y1],[x2 y2],[1 1],'color','b','erasemode','xor','linewidth',2);
  set(line_ptr,'userdata',the_line);
  
  % CALCULATE DIRECTIONAL DERIVATIVE
  xnom = [x1; x2];
  p = [y1-x1;y2-x2];
  grad = b+a*xnom;
  dir_der = p'*grad/norm(p);
  
  % CHANGE DIRECTIONAL DERIVATIVE
  axes(little)
  der = get(derivative_ptr,'userdata');
  set(der,'facecolor',nnltyell);
  delete(der);
  der = fill3([1 1 0],[-1 1 0]+dir_der,[1 1 1],nndkblue,...
    'edgecolor','none',...
    'erasemode','none');
  %der = patch([0 1 1 0],[0 0 dir_der dir_der],'b','erasemode','xor');
  set(derivative_ptr,'userdata',der);

% COMMAND: UP

elseif strcmp(cmd,'up')
  
  % REMOVE MARKER
  marker = get(marker_ptr,'userdata');
  delete(marker);
  set(marker_ptr,'userdata',[]);

  % REMOVE LINE
  the_line = get(line_ptr,'userdata');
  delete(the_line);
  set(line_ptr,'userdata',[]);
  
  % REMOVE DIRECTIONAL DERIVATIVE
  derivative = get(derivative_ptr,'userdata');
  set(derivative,'facecolor',nnltyell)
  delete(derivative);
  set(derivative_ptr,'userdata',[]);

  % TURN OFF MOTION AND UP ACTIONS
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'WindowButtonUpFcn','');
  
end

% LOCK WINDOW AND RETURN
set(fig,'nextplot','new','pointer','arrow')

