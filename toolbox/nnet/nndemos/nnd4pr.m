function nnd4pr(cmd,arg1,arg2,arg3)
%NND4PR Perceptron rule demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd4pr';
p_max = 3;
max_epoch = 5;

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
  bias = H(8);                % "Bias" radio button
  no_bias = H(9);             % "No bias" radio button
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
  index_ptr = H(21);          % index of pattern to train on
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
  w = [1 -0.8];
  b = 0;
  P = [1 2; -1 2; 0 -1]';
  T = [1 0 0];

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Perceptron Rule','','Chapter 4');
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
  plot(bracket_x+285,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  plot(-bracket_x+355,bracket_y*4+20,'color',nndkblue,'linewidth',3);
  b_text = text(320,40,sprintf('%5.3g',b),...
    'fontsize',16,...
    'fontweight','normal',...
    'color',nndkblue,...
    'horiz','center',...
    'erasemode','none');

  % VECTOR DIAGRAM
  v_axis = nnsfo('a2','','','');
  set(v_axis,...
    'position',[105 90 240*1.05 240*1.05],...
    'xlim',[-p_max p_max]*1.05,...
    'xtick',-p_max:p_max,...
    'ylim',[-p_max p_max]*1.05,...
    'ytick',-p_max:p_max)

  % OBJECTS
  zz1 = [-p_max p_max];
  zz2 = zz1*0;
  cross = plot([zz1 NaN zz2],[zz2 NaN zz1],':',...
    'color',nndkblue,...
    'erasemode','none');
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
  [R,Q] = size(P);
  if all(T == hardlim(w*P+b*ones(1,Q)))
    col = nndkblue;
  else
    col = nnred;
  end
  db_line = plot(pp1,pp2,...
    'linewidth',2,...
    'color',col,...
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
    'position',[40 320 20*1.05 20*1.05],...
    'xlim',[-.16 .16],...
    'ylim',[-.16 .16])
  axis('off')
  fill(cx,cy,[0 0 0],...
    'edgecolor',nndkgray,...
      'linewidth',2)
  t2_axis = nnsfo('a2','','','');
  set(t2_axis,...
    'position',[40 270 20*1.05 20*1.05],...
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
    'position',[20 220 60 20],...
    'string','Learn',...
    'callback',[me '(''learn'')'])
  uicontrol(...
    'units','points',...
    'position',[20 185 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
  uicontrol(...
    'units','points',...
    'position',[20 150 60 20],...
    'string','Random',...
    'callback',[me '(''random'')'])
  bias = uicontrol(...
    'units','points',...
    'position',[20 115 70 20],...
    'string','Bias',...
    'callback',[me '(''bias'')'],...
    'style','radio',...
    'value',0,...
    'back',nnltgray);
  no_bias = uicontrol(...
    'units','points',...
    'position',[20 85 70 20],...
    'string','No Bias',...
    'callback',[me '(''nobias'')'],...
    'style','radio',...
    'value',1,...
    'back',nnltgray);

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
  w_ptr = uicontrol('visible','off','userdata',w);
  b_ptr = uicontrol('visible','off','userdata',b);
  pt_ptr = uicontrol('visible','off','userdata',pt);
  P_ptr = uicontrol('visible','off','userdata',P);
  T_ptr = uicontrol('visible','off','userdata',T);
  dots_ptr = uicontrol('visible','off','userdata',dots);
  dot_ptr = uicontrol('visible','off','userdata',[]);
  index_ptr = uicontrol('visible','off','userdata',1);

  % SAVE WINDOW DATA AND LOCK

  H = [fig_axis desc_text v_axis t1_axis cross NaN db_line...
    bias no_bias w_ptr b_ptr pt_ptr w1_text w2_text b_text P_ptr T_ptr ...
    dots_ptr t2_axis dot_ptr index_ptr];
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
    'Click [Learn] to apply',...
    'the perceptron rule',...
    'to a single vector.',...
    '',...
    'Click [Train] to apply',...
    'the rule up to 5 times.',...
    '',...
    'Click [Random] to set',...
    'the weights to random',...
    'values.',...
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

    % EDIT INPUT/TARGET DOT
    P = get(P_ptr,'userdata');
    q = size(P,2);
    for i=1:q
      if sqrt(sum(P(:,i)-[x; y]).^2) < 0.15
        T = get(T_ptr,'userdata');
        w = get(w_ptr,'userdata');
        b = get(b_ptr,'userdata');
        dots = get(dots_ptr,'userdata');
          
        set(dots(i),...
          'facecolor',nnltyell,...
          'edgecolor',nnltyell);

        delete(dots(i));
        t = T(i);
        T(i) = [];
        P(:,i) = [];
        dots(i) = [];

        [R,Q] = size(P);
        if all(T == hardlim(w*P+b*ones(1,Q)))
          col = nndkblue;
        else
          col = nnred;
        end
        set(db_line,...
         'color',col)
        set(cross,...
         'color',nndkblue)

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

    P = [P [x;y]];
    T = [T dot];

    [R,Q] = size(P);
    if all(T == hardlim(w*P+b*ones(1,Q)))
      col = nndkblue;
    else
      col = nnred;
    end
    set(db_line,...
      'color',col);

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
  
    set(P_ptr,'userdata',P);
    set(T_ptr,'userdata',T);
    set(dots_ptr,'userdata',dots);
  end

  set(fig,...
    'pointer','arrow',...
    'WindowButtonUpFcn','')
    
%==================================================================
% Learn.
%
% ME('learn')
%==================================================================

elseif strcmp(cmd,'learn')
  
  max_epoch = 1;
  cmd = 'train';

%==================================================================
% Bias.
%
% ME('bias')
%==================================================================

elseif strcmp(cmd,'bias')

  set(no_bias,'value',0);

%==================================================================
% Bias.
%
% ME('bias')
%==================================================================

elseif strcmp(cmd,'nobias')

  set(bias,'value',0);
  
  w = get(w_ptr,'userdata');
  b = 0;
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  dots = get(dots_ptr,'userdata');
  
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
    'color',nnltyell)
  set(cross,...
    'color',nndkblue);
  [R,Q] = size(P);
  if all(T == hardlim(w*P+b*ones(1,Q)))
    col = nndkblue;
  else
    col = nnred;
  end
  set(db_line,...
    'xdata',pp1,...
    'ydata',pp2,...
    'color',col)

  % REFRESH DOTS
  for k=1:length(T)
    a = hardlim(w*P(:,k)+b);
    if (a == T(k))
      col = nndkgray;
    else
      col = nnred;
    end
    set(dots(k),...
     'facecolor',[1 1 1]-T(k),...
     'edgecolor',col)
  end

  % NEW PARAMETER VALUES
  set(b_text,...
    'color',nnltgray)
  nntxtchk;
  set(b_text,...
    'string',sprintf('%5.3g',b),...
    'color',nndkblue)
  nntxtchk;
  
  set(b_ptr,'userdata',b);

%==================================================================
% Random weights.
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random')

  [w,b] = feval('rands',1,2);
  if get(no_bias,'value'), b = 0; end

  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  dots = get(dots_ptr,'userdata');

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
    'color',nnltyell)
  set(cross,...
    'color',nndkblue);
  [R,Q] = size(P);
  if all(T == hardlim(w*P+b*ones(1,Q)))
    col = nndkblue;
  else
    col = nnred;
  end
  set(db_line,...
    'xdata',pp1,...
    'ydata',pp2,...
    'color',col)

  % REFRESH DOTS
  for k=1:length(T)
    a = hardlim(w*P(:,k)+b);
    if (a == T(k))
      col = nndkgray;
    else
      col = nnred;
    end
    set(dots(k),...
     'facecolor',[1 1 1]-T(k),...
     'edgecolor',col)
  end

  % NEW PARAMETER VALUES
  set(w1_text,...
    'color',nnltgray)
  set(w2_text,...
    'color',nnltgray)
  set(b_text,...
    'color',nnltgray)
  nntxtchk;
  set(w1_text,...
    'string',sprintf('%5.3g',w(1)),...
    'color',nndkblue)
  set(w2_text,...
    'string',sprintf('%5.3g',w(2)),...
    'color',nndkblue)
  set(b_text,...
    'string',sprintf('%5.3g',b),...
    'color',nndkblue)
  nntxtchk;
  
  set(w_ptr,'userdata',w);
  set(b_ptr,'userdata',b);
  
%==================================================================
end

%==================================================================
% Train.
%
% ME('train')
%==================================================================

if strcmp(cmd,'train')
  
  % GET DATA
  w = get(w_ptr,'userdata');
  b = get(b_ptr,'userdata');
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  dots = get(dots_ptr,'userdata');
  bf = get(bias,'value');
  j = get(index_ptr,'userdata');
  q = length(T);
  if (q == 0)
    return
  end

  for i=1:max_epoch
    if (j > q), j = 1; end
    if all(T == hardlim(w*P+b*ones(1,q))), break, end

    dot_col = get(dots(j),'facecolor');
    set(dots(j),...
      'facecolor',nngreen)
    nnpause(0.5);
    set(dots(j),...
      'facecolor',nnltyell)
    nnpause(0.5);
    set(dots(j),...
      'facecolor',nngreen)
    nnpause(0.5);

    a = hardlim(w*P(:,j)+b);
    e = T(:,j) - a;
    dw = e*P(:,j)';
    db = e;
    w = w + dw;
    if bf, b = b + db; end

    % CALCULATE NEW DECISION BOUNDARY
    if (dw ~= 0) | (db ~= 0)
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
        'color',nnltyell)
      set(cross,...
        'color',nndkblue);

      [R,Q] = size(P);
      if all(T == hardlim(w*P+b*ones(1,Q)))
        col = nndkblue;
      else
        col = nnred;
      end
      set(db_line,...
        'xdata',pp1,...
        'ydata',pp2,...
        'color',col)

      % REFRESH DOTS
      for k=1:length(T)
        a = hardlim(w*P(:,k)+b);
        if (a == T(k))
          col = nndkgray;
        else
          col = nnred;
        end
        set(dots(k),...
          'facecolor',[1 1 1]-T(k),...
          'edgecolor',col)
      end

      % NEW PARAMETER VALUES
      set(w1_text,...
        'color',nnltgray)
      set(w2_text,...
        'color',nnltgray)
      set(b_text,...
        'color',nnltgray)
      nntxtchk;
      set(w1_text,...
        'string',sprintf('%5.3g',w(1)),...
        'color',nndkblue)
      set(w2_text,...
        'string',sprintf('%5.3g',w(2)),...
        'color',nndkblue)
      set(b_text,...
        'string',sprintf('%5.3g',b),...
        'color',nndkblue)
      nntxtchk;
    end
    set(dots(j),...
      'facecolor',dot_col)
    j = j + 1;
  end
 
  set(w_ptr,'userdata',w);
  set(b_ptr,'userdata',b);
  set(index_ptr,'userdata',j);
end
