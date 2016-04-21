function nnd4db(cmd,arg1,arg2,arg3)
%NND4DB Decision boundaries demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd4db';
p_max = 3;

% FLAGS
change_func = 0;

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
  
% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  fig_axis = H(1);            % window axis
  desc_text = H(2);           % handle to first line of text sequence
  v_axis = H(3);              % training and weight vector axis
  t1_axis = H(4);             % black target marker axis
  cross = H(5);               % dotted origin lines
  w_arrow_ptr = H(6);         % pointer to weight vector & name
  db_line = H(7);             % decision boundary
  db1 = H(8);                 % decision boundary point #1
  db2 = H(9);                 % decision boundary point #2
  w_ptr = H(10);              % pointer to weights
  b_ptr = H(11);              % pointer to bias
  pt_ptr = H(12);             % pointer to point positions
  w1_text = H(13);            % text for w(1) value
  w2_text = H(14);            % text for w(2) value
  b_text = H(15);             % text for b value
  P_ptr = H(16);              % pointer to input vectors
  T_ptr = H(17);              % pointer to targets
  dots_ptr = H(18);           % pointer to input/target dots
  t2_axis = H(19);            % white target marker axis
  dot_ptr = H(20);            % pointer to dot being edited
end

%==================================================================
% Activate the window.
%
% ME() or ME('')
%==================================================================

if strcmp(cmd,'')
  if fig
    figure(fig)
    set(fig,'visible','on')
  else
    feval(me,'init')
  end

%==================================================================
% Close the window.
%
% ME() or ME('')
%==================================================================

elseif strcmp(cmd,'close') & (fig)
  delete(fig)

%==================================================================
% Initialize the window.
%
% ME('init')
%==================================================================

elseif strcmp(cmd,'init') & (~fig)

  % CHECK FOR NNT
  if ~nnfexist(me), return, end

  % CONSTANTS
  pt1 = [-1 0];
  pt2 = [0 -2];
  pt = [pt1; pt2];
  w_dir = [pt(1,2)-pt(2,2),pt(2,1)-pt(1,1)];
  w = w_dir/sqrt(sum(sum(w_dir.^2)))*2;
  b = -w*pt(1,:)';
  P = [0 0; 0 1; 1 0; 1 1]';
  T = [0 0 0 1];

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Decision Boundaries','','Chapter 4');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(4,458,363,'shadow')

  % VALUES
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  text(55,40,'W=',...
    'fontsize',20,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right')
  plot(bracket_x+60,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+190,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  w1_text = text(95,40,sprintf('%5.3g',w(1)),...
    'fontsize',16,...
    'fontweight','normal',...
    'color',nndkblue,...
    'horiz','center',...
    'erasemode','none');
  w2_text = text(150,40,sprintf('%5.3g',w(2)),...
    'fontsize',16,...
    'fontweight','normal',...
    'color',nndkblue,...
    'horiz','center',...
    'erasemode','none');
  text(255,40,'b=',...
    'fontsize',20,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right')
  plot(bracket_x+270,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+340,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  b_text = text(305,40,sprintf('%5.3g',b),...
    'fontsize',16,...
    'fontweight','normal',...
    'color',nndkblue,...
    'horiz','center',...
    'erasemode','none');

  % VECTOR DIAGRAM
  v_axis = nnsfo('a2','','','');
  set(v_axis,...
    'position',[90 90 240*1.05 240*1.05],...
    'xlim',[-p_max p_max]*1.05,...
    'xtick',-p_max:p_max,...
    'ylim',[-p_max p_max]*1.05,...
    'ytick',-p_max:p_max)

  % OBJECTS
  zz1 = [-p_max:0.5:p_max];
  zz2 = zz1*0;
  cross = plot([zz1 NaN zz2],[zz2 NaN zz1],'.',...
    'color',nndkblue,...
    'erasemode','none');
  [R,Q] = size(P);
  A = hardlim(w*P+b*ones(1,Q));
  if all(A == T)
    col = nndkgray;
  else
    col = nnred;
  end
  w_arrow = nndrwvec(w(1),w(2),2,0.2,col,'W','none');
  if (w(1) ~= 0)
    pp2 = [-p_max p_max];
    pp1 = -(w(2)*pp2+b)/w(1);
  elseif (w(2) ~= 0)
    pp1 = [-p_max p_max];
    pp2 = -(w(1)*pp1+b)/w(2);
  else
    pp1 = [0 0];
    pp2 = [0 0];
  end
  db_line = plot(pp1,pp2,...
    'linewidth',2,...
    'color',nndkblue,...
    'erasemode','none');
  db1 = plot(pt1(1),pt1(2),'o',...
    'color',nndkblue,...
    'markersize',10,...
    'erasemode','none');
  db2 = plot(pt2(1),pt2(2),'o',...
    'color',nndkblue,...
    'markersize',10,...
    'erasemode','none');
  q = length(T);
  deg = pi/180;
  angle = [0:5:360]*deg;
  cx = cos(angle)*0.15;
  cy = sin(angle)*0.15;
  dots = zeros(1,q);
  for i=1:q
    a = hardlim(w*P(:,i)+b);
    if (a == T(i))
      col = nndkgray;
    else
      col = nnred;
    end
    dots(i) = fill(cx+P(1,i),cy+P(2,i),[1 1 1]-T(i),...
      'edgecolor',col,...
      'erasemode','none',...
      'linewidth',2);
  end

  % TARGET AXES
  t1_axis = nnsfo('a2','','','');
  set(t1_axis,...
    'position',[30 230 20*1.05 20*1.05],...
    'xlim',[-.16 .16],...
    'ylim',[-.16 .16])
  axis('off')
  fill(cx,cy,[0 0 0],...
    'edgecolor',nndkgray,...
    'linewidth',2)
  t2_axis = nnsfo('a2','','','');
  set(t2_axis,...
    'position',[30 180 20*1.05 20*1.05],...
    'xlim',[-.16 .16],...
    'ylim',[-.16 .16])
  axis('off')
  fill(cx,cy,[1 1 1],...
    'edgecolor',nndkgray,...
    'linewidth',2)

  % BUTTONS
  drawnow % Let everything else appear before buttons 
  uicontrol(...
    'units','points',...
    'position',[400 110 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[400 75 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % DATA POINTERS
  w_ptr = uicontrol('visible','off'); set(w_ptr,'userdata',w);
  b_ptr = uicontrol('visible','off'); set(b_ptr,'userdata',b);
  pt_ptr = uicontrol('visible','off'); set(pt_ptr,'userdata',pt);
  w_arrow_ptr = uicontrol('visible','off'); set(w_arrow_ptr,'userdata',w_arrow);
  P_ptr = uicontrol('visible','off'); set(P_ptr,'userdata',P);
  T_ptr = uicontrol('visible','off'); set(T_ptr,'userdata',T);
  dots_ptr = uicontrol('visible','off'); set(dots_ptr,'userdata',dots);
  dot_ptr = uicontrol('visible','off'); set(dot_ptr,'userdata',[]);

  % SAVE WINDOW DATA AND LOCK

  H = [fig_axis desc_text v_axis t1_axis cross w_arrow_ptr db_line...
    db1 db2 w_ptr b_ptr pt_ptr w1_text w2_text b_text P_ptr T_ptr ...
    dots_ptr t2_axis dot_ptr];
  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

  % LOCK WINDOW
  set(fig,...
   'nextplot','new',...
   'color',nnltgray);

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & (fig)
  nnsettxt(desc_text,...
    'Move the perceptron',...
    'decision boundary by',...
    'dragging its handles.',...
    '',...
    'Try to divide the',...
    'circles so that none',...
    'of their edges are red.',...
    '',...
    'The weights and bias',...
    'will take on values',...
    'associated with the',...
    'chosen boundary.',...
    '',...
    'Drag the white and',...
    'black dots to define',...
    'different problems.')
    
%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  pt = get(v_axis,'currentpoint');
  x = pt(1);
  y = pt(3);

  % EDIT VECTOR AXIS
  if (x >= -p_max) & (x <= p_max) & (y >= -p_max) & (y <= p_max)

    % GET DATA
    pt = get(pt_ptr,'userdata');
    w_arrow = get(w_arrow_ptr,'userdata');

    % EDIT DECISION BOUNDARY PT #1
    if sum(sum((pt(1,:)-[x y]).^2)) < 0.2
      set(db1,...
        'color',nnltyell)
      set(db_line,...
        'color',nnltyell)
      set(w_arrow,...
        'color',nnltyell)
      set(w1_text,...
        'color',nnltgray)
      set(w2_text,...
        'color',nnltgray)
      set(b_text,...
        'color',nnltgray)
      nntxtchk;
      set(db2,...
        'color',nndkblue)
      set(cross,...
        'color',nndkblue)
      dots = get(dots_ptr,'userdata');
      T = get(T_ptr,'userdata');
      for i=1:length(T)
        set(dots(i),...
          'facecolor',[1 1 1]-T(i))
      end

      set(fig,...
        'pointer','circle',...
        'WindowButtonMotionFcn',[me '(''movept1'')'],...
        'WindowButtonUpFcn',[me '(''setpt1'')'])
    
    % EDIT DECISION BOUNDARY PT #1
    elseif sqrt(sum(sum((pt(2,:)-[x y]).^2))) < 0.2
      set(db2,...
        'color',nnltyell)
      set(db_line,...
        'color',nnltyell)
      set(w_arrow,...
        'color',nnltyell)
      set(w1_text,...
        'color',nnltgray)
      set(w2_text,...
        'color',nnltgray)
      set(b_text,...
        'color',nnltgray)
      nntxtchk
      set(db1,...
        'color',nndkblue)
      set(cross,...
        'color',nndkblue)
      dots = get(dots_ptr,'userdata');
      T = get(T_ptr,'userdata');
      for i=1:length(T)
        set(dots(i),...
          'facecolor',[1 1 1]-T(i))
      end

      set(fig,...
        'pointer','circle',...
        'WindowButtonMotionFcn',[me '(''movept2'')'],...
        'WindowButtonUpFcn',[me '(''setpt2'')'])

    % EDIT INPUT/TARGET DOT
    else
      P = get(P_ptr,'userdata');
      q = size(P,2);
      for i=1:q
        if sqrt(sum(sum((P(:,i)-[x; y]).^2))) < 0.15
          T = get(T_ptr,'userdata');
          w = get(w_ptr,'userdata');
          b = get(b_ptr,'userdata');
          dots = get(dots_ptr,'userdata');
          
          set(dots(i),...
            'facecolor',nnltyell,...
            'edgecolor',nnltyell);
          set(db_line,...
           'color',nndkblue)

          A = hardlim(w*P+b*ones(1,q));
          if all(A == T)
            col = nndkgray;
          else
            col = nnred;
          end
          set(w_arrow,...
           'color',col)

          set(db1,...
           'color',nndkblue)
          set(db2,...
           'color',nndkblue)
          set(cross,...
           'color',nndkblue)

          delete(dots(i));
          t = T(i);
          T(i) = [];
          P(:,i) = [];
          dots(i) = [];
          for i=1:length(T)
            set(dots(i),...
             'facecolor',[1 1 1]-T(i))
          end
          
          set(T_ptr,'userdata',T);
          set(P_ptr,'userdata',P);
          set(dots_ptr,'userdata',dots);

          set(fig,...
           'pointer','circle',...
           'WindowButtonUpFcn',[me '(''setdot'')'])
          set(dot_ptr,'userdata',t);
          break;
        end
      end
    end
  
  % NEW DOTS
  else
    pt = get(t1_axis,'currentpoint');
    x = pt(1);
    y = pt(3);

    % BLACK DOT
    if (x >= -.15) & (x <= .15) & (y >= -.15) & (y <= .15)
       set(fig,...
       'pointer','circle',...
       'WindowButtonUpFcn',[me '(''setdot'')'])
      set(dot_ptr,'userdata',1);
    
    else
      pt = get(t2_axis,'currentpoint');
      x = pt(1);
      y = pt(3);

      % WHITE DOT
      if (x >= -.15) & (x <= .15) & (y >= -.15) & (y <= .15)
         set(fig,...
         'pointer','circle',...
         'WindowButtonUpFcn',[me '(''setdot'')'])
        set(dot_ptr,'userdata',0);
      end
    end
  end

%==================================================================
% Set decision dot.
%
% ME('setdot')
%==================================================================

elseif strcmp(cmd,'setdot') & (fig) & (nargin == 1)

  pt = get(v_axis,'currentpoint');
  x = pt(1);
  x = round(x*2)/2;
  y = pt(3);
  y = round(y*2)/2;

  dot = get(dot_ptr,'userdata');
 
  if (x >= -p_max) & (x <= p_max) & (y >= -p_max) & (y <= p_max)
    P = get(P_ptr,'userdata');
    T = get(T_ptr,'userdata');
    w = get(w_ptr,'userdata');
    b = get(b_ptr,'userdata');
    dots = get(dots_ptr,'userdata');
    
    q = length(dots)+1;
    deg = pi/180;
    angle = [0:5:360]*deg;
    cx = cos(angle)*0.15;
    cy = sin(angle)*0.15;
    set(fig,'nextplot','add');
    axes(v_axis);

    a = hardlim(w*[x;y]+b);
    if (a == dot)
      col = nndkgray;
    else
      col = nnred;
    end

    dots(q) = fill(cx+x,cy+y,[1 1 1]-dot,...
      'edgecolor',col,...
      'erasemode','none',...
      'linewidth',2);
    set(fig,'nextplot','new');
    P = [P [x;y]];
    T = [T dot];
  
    set(P_ptr,'userdata',P);
    set(T_ptr,'userdata',T);
    set(dots_ptr,'userdata',dots);
    cmd = 'update';
  end

  set(fig,...
    'pointer','arrow',...
    'WindowButtonUpFcn','')
    
%==================================================================
% Move decision boundary point #1.
%
% ME('movept1')
%==================================================================

elseif strcmp(cmd,'movept1') & (fig) & (nargin == 1)

  pt = get(v_axis,'currentpoint');
  x = pt(1);
  x = round(x*4)/4;
  y = pt(3);
  y = round(y*4)/4;

  % MOVE DECISION POINT #1
  if (x >= -p_max) & (x <= p_max) & (y >= -p_max) & (y <= p_max)
    pt = get(pt_ptr,'userdata');
    pt(1,:) = [x y];
    set(pt_ptr,'userdata',pt);
  end

%==================================================================
% Respond to set decision boundary point #1.
%
% ME('setpt1')
%==================================================================

elseif strcmp(cmd,'setpt1') & (fig) & (nargin == 1)

  set(fig,...
    'WindowButtonMotionFcn','',...
    'WindowButtonUpFcn','',...
    'pointer','arrow')

  pt = get(pt_ptr,'userdata');
  set(db1,...
    'xdata',pt(1,1),...
    'ydata',pt(1,2),...
    'color',nndkblue)
  cmd = 'update';

%==================================================================
% Move decision boundary point #1.
%
% ME('movept2')
%==================================================================

elseif strcmp(cmd,'movept2') & (fig) & (nargin == 1)

  pt = get(v_axis,'currentpoint');
  x = pt(1);
  x = round(x*4)/4;
  y = pt(3);
  y = round(y*4)/4;

  % MOVE DECISION POINT #1
  if (x >= -p_max) & (x <= p_max) & (y >= -p_max) & (y <= p_max)
    pt = get(pt_ptr,'userdata');
    pt(2,:) = [x y];
    set(pt_ptr,'userdata',pt);
  end

%==================================================================
% Respond to set decision boundary point #2.
%
% ME('setpt2')
%==================================================================

elseif strcmp(cmd,'setpt2') & (fig) & (nargin == 1)

  set(fig,...
    'WindowButtonMotionFcn','',...
    'WindowButtonUpFcn','',...
    'pointer','arrow')

  pt = get(pt_ptr,'userdata');
  set(db2,...
    'xdata',pt(2,1),...
    'ydata',pt(2,2),...
    'color',nndkblue)
  cmd = 'update';

%==================================================================
end

%==================================================================
% Respond to request to update displays.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update')
  
  % GET DATA
  b = get(b_ptr,'userdata');
  pt = get(pt_ptr,'userdata');
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');

  % UPDATE WEIGHTS & DECISION BOUNDARY
  w_dir = [pt(1,2)-pt(2,2),pt(2,1)-pt(1,1)];
  w = w_dir/sqrt(sum(sum(w_dir.^2)))*2;
  b = -w*pt(1,:)';

  if (w(1) ~= 0)
    pp2 = [-p_max p_max];
    pp1 = -(w(2)*pp2+b)/w(1);

    if (pp1(1) < -p_max | pp1(1) > p_max)
      pp1(1) = p_max*sign(pp1(1));
      pp2(1) = -(w(1)*pp1(1)+b)/w(2);
    end
    if (pp1(2) < -p_max | pp1(2) > p_max)
      pp1(2) = p_max*sign(pp1(2));
      pp2(2) = -(w(1)*pp1(2)+b)/w(2);
    end

  elseif (w(2) ~= 0)
    pp1 = [-p_max p_max];
    pp2 = -(w(1)*pp1+b)/w(2);
  else
    pp1 = [0 0];
    pp2 = [0 0];
  end

  % NEW BOUNDARY
  set(db_line,...
    'xdata',pp1,...
    'ydata',pp2,...
    'color',nndkblue)

  % NEW WEIGHT VECTOR
  set(fig,'nextplot','add')
  axes(v_axis)
  w_arrow = get(w_arrow_ptr,'userdata');
  delete(w_arrow);
  [R,Q] = size(P);
  A = hardlim(w*P+b*ones(1,Q));
  if all(A == T)
    col = nndkgray;
  else
    col = nnred;
  end
  w_arrow = nndrwvec(w(1),w(2),2,0.2,col,'W','none');
  set(w_arrow_ptr,'userdata',w_arrow)
  set(fig,'nextplot','new')

  % REFRESH DOTS
  dots = get(dots_ptr,'userdata');
  T = get(T_ptr,'userdata');
  for i=1:length(T)
    a = hardlim(w*P(:,i)+b);
    if (a == T(i))
      col = nndkgray;
    else
      col = nnred;
    end
    set(dots(i),...
      'facecolor',[1 1 1]-T(i),...
      'edgecolor',col)
  end

  % NEW PARAMETER VALUES
  set(w1_text,...
    'string',sprintf('%5.3g',w(1)),...
    'color',nndkblue)
  set(w2_text,...
    'string',sprintf('%5.3g',w(2)),...
    'color',nndkblue)
  set(b_text,...
    'string',sprintf('%5.3g',b),...
    'color',nndkblue)
  nntxtchk

end
