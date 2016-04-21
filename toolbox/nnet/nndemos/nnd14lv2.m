function nnd14lv2(cmd,arg1,arg2,arg3)
%NND4LV1 LVQ2 demonstration.
%
%  This demonstration requires the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd14lv2';
p_max = 3;
max_epoch = 5;
W2 = [1 1 0 0;
      0 0 1 1];
box_x = [-1 1 1 -1 -1]*0.1;
box_y = [-1 -1 1 1 -1]*0.1;
cross_x = [-1 1 NaN 0 0]*0.15;
cross_y = [0 0 NaN -1 1]*0.15;
lr = 0.6;
center_colors = [nnblack;nnltblue];

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
  t2_axis = H(5);             % white target marker axis
  W1_ptr = H(6);
  P_ptr = H(7);
  T_ptr = H(8);
  PV_ptr = H(9);
  t_ptr = H(10);
  WV_ptr = H(11);
  blip_ptr = H(12);
  bloop_ptr = H(13);
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
  if ~nntexist(me), return, end

  % CONSTANTS
  W1 = rands(4,2);
  P = [-1.5  -2.0 2.0  1.5  2.0  2.0 -2.0 -1.5;
        2.0   1.5 2.0  2.0 -2.0 -1.5 -2.0 -2.0];
  T = [  1    1    0    0    1    1    0    0;
         0    0    1    1    0    0    1    1];
  A1 = compet(-dist(W1,P));
  A2 = W2*A1;
  E = T-A2;
  blip = nndsnd(6);
  bloop = nndsnd(7);

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','LVQ2','','Chapter 14');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(14,458,363,'shadow')

  % VECTOR DIAGRAM
  v_axis = nnsfo('a2','','','');
  set(v_axis,...
    'position',[50 60 270*1.05 270*1.05],...
    'xlim',[-p_max p_max]*1.05,...
    'xtick',[],...
    'ylim',[-p_max p_max]*1.05,...
    'ytick',[])

  % INPUT VECTOR MARKERS
  cross = plot([-p_max p_max NaN 0 0],[0 0 NaN -p_max p_max],':',...
    'color',nndkblue,...
    'erasemode','none');
  Q = size(P,2);
  PV = zeros(1,Q);
  for q=1:Q
    if E(1,q)
      edge_color = nnred;
    else
      edge_color = nndkgray;
    end
    PV(q) = fill(box_x+P(1,q),box_y+P(2,q),center_colors(1+T(1,q),:),...
      'edgecolor',edge_color,...
      'erasemode','none',...
      'linewidth',2);
  end

  % WEIGHT MARKERS
  S1 = size(W1,1);
  for i=S1:-1:1
    WV(i) = plot(cross_x+W1(i,1),cross_y+W1(i,2),...
      'color',center_colors(1+W2(1,i),:),...
      'linewidth',3,...
      'erasemode','none');
  end

  % NEW INPUT MARKERS
  t1_axis = nnsfo('a2','','','');
  set(t1_axis,...
    'position',[50 20 20*1.05 20*1.05],...
    'xlim',[-.16 .16],...
    'ylim',[-.16 .16])
  axis('off')
  fill(box_x,box_y,nnltblue,...
    'edgecolor',nndkgray,...
      'linewidth',2)
  t2_axis = nnsfo('a2','','','');
  set(t2_axis,...
    'position',[70 20 20*1.05 20*1.05],...
    'xlim',[-.16 .16],...
    'ylim',[-.16 .16])
  axis('off')
  fill(box_x,box_y,[0 0 0],...
    'edgecolor',nndkgray,...
    'linewidth',2)

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[110 20 60 20],...
    'string','Learn',...
    'callback',[me '(''learn'')'])
  uicontrol(...
    'units','points',...
    'position',[190 20 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
  uicontrol(...
    'units','points',...
    'position',[270 20 60 20],...
    'string','Random',...
    'callback',[me '(''random'')'])

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
  W1_ptr = uicontrol('visible','off','userdata',W1);
  P_ptr = uicontrol('visible','off','userdata',P);
  T_ptr = uicontrol('visible','off','userdata',T);
  PV_ptr = uicontrol('visible','off','userdata',PV);
  t_ptr = uicontrol('visible','off','userdata',[0;0]);
  WV_ptr = uicontrol('visible','off','userdata',WV);
  blip_ptr = uicontrol('visible','off','userdata',blip);
  bloop_ptr = uicontrol('visible','off','userdata',bloop);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text v_axis t1_axis t2_axis,...
       W1_ptr P_ptr T_ptr PV_ptr t_ptr WV_ptr blip_ptr bloop_ptr];
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
    'the LVQ2 rule once.',...
    'Click [Train] to apply',...
    'the rule 5 times.',...
    'Click [Random] to get',...
    'random weights.',...
    '',...
    'Drag the blue and',...
    'black squares to define',...
    'different problems.',...
    '',...
    'Colors of crosses (wts)',...
    'and inside squares',...
    'indicate class. Red',...
    'edge indicates a',...
    'misclassified vector.')
    
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
    T = get(T_ptr,'userdata');
    PV = get(PV_ptr,'userdata');
    WV = get(WV_ptr,'userdata');

    Q = size(P,2);
    for q=1:Q

      if sqrt(sum((P(:,q)-[x; y]).^2)) < 0.15
        t = T(:,q);        
        set(PV(q),...
          'facecolor',nnltyell,...
          'edgecolor',nnltyell);
        delete(PV(q));
        P(:,q) = [];
        T(:,q) = [];
        PV(:,q) = [];

        set(fig,...
         'pointer','cross',...
         'WindowButtonUpFcn',[me '(''setdot'')'])

        set(P_ptr,'userdata',P);
        set(T_ptr,'userdata',T);
        set(PV_ptr,'userdata',PV);
        set(t_ptr,'userdata',t);

        set(WV,'visible','off')
        for i=length(WV):-1:1
          set(WV(i),'visible','on')
        end
        break;
      end
    end
  
  % NEW SQUARE
  else
    pt = get(t1_axis,'currentpoint');
    x = pt(1);
    y = pt(3);

    % BLACK SQUARE
    if (x >= -.15) & (x <= .15) & (y >= -.15) & (y <= .15)
       set(fig,...
       'pointer','circle',...
       'WindowButtonUpFcn',[me '(''setdot'')'])
      set(t_ptr,'userdata',[1;0]);
    
    else
      pt = get(t2_axis,'currentpoint');
      x = pt(1);
      y = pt(3);

      % WHITE SQUARE
      if (x >= -.15) & (x <= .15) & (y >= -.15) & (y <= .15)
         set(fig,...
         'pointer','circle',...
         'WindowButtonUpFcn',[me '(''setdot'')'])
        set(t_ptr,'userdata',[0;1]);
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

  if (x >= -p_max) & (x <= p_max) & (y >= -p_max) & (y <= p_max)
    P = get(P_ptr,'userdata');
    T = get(T_ptr,'userdata');
    W1 = get(W1_ptr,'userdata');
    PV = get(PV_ptr,'userdata');
    t = get(t_ptr,'userdata');
    WV = get(WV_ptr,'userdata');
    
    q = size(PV,2)+1;
    set(fig,'nextplot','add');
    axes(v_axis);

    P = [P [x;y]];
    T = [T t];

    A1 = compet(W1*P);
    A2 = W2*A1;
    E = T-A2;

    if E(1,q)
      edge_color = nnred;
    else
      edge_color = nndkgray;
    end
    PV(q) = fill(box_x+x,box_y+y,center_colors(1+T(1,q),:),...
      'edgecolor',edge_color,...
      'erasemode','none',...
      'linewidth',2);
    set(fig,'nextplot','new');
  
    set(P_ptr,'userdata',P);
    set(T_ptr,'userdata',T);
    set(PV_ptr,'userdata',PV);

    set(WV,'visible','off')
    for i=length(WV):-1:1
      set(WV(i),'visible','on')
    end
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
% Random weights.
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random')
  
  % GET DATA
  W1 = get(W1_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  PV = get(PV_ptr,'userdata');
  blip = get(blip_ptr,'userdata');
  bloop = get(bloop_ptr,'userdata');
  Q = size(P,2);

  % MOVE WEIGHTS
  set(WV,'color',nngreen);
  nnsound(blip);
  nnpause(0.5)
 
  W1 = (rand(4,2)*2-1)*1.25;
  set(WV,'color',nnltyell);
  set(WV,'visible','off');
  for i=length(WV):-1:1
    set(WV(i),...
      'xdata',cross_x + W1(i,1),...
      'ydata',cross_y + W1(i,2),...
      'color',center_colors(1+W2(1,i),:));
    set(WV(i),'visible','on')
    nnsound(bloop);
  end

  % REDRAW INPUT VECTORS
  A1 = compet(-dist(W1,P));
  A2 = W2*A1;
  E = T-A2;
  for q=1:Q
    if E(1,q)
     edge_color = nnred;
    else
      edge_color = nndkgray;
    end
    set(PV(q),...
      'facecolor',center_colors(1+T(1,q),:),...
      'edgecolor',edge_color);
  end

  % REFRESH WEIGHT VECTORS
  set(WV,'visible','off')
  for i=length(WV):-1:1
    set(WV(i),'visible','on')
  end

  % SAVE DATA
  set(W1_ptr,'userdata',W1);

%==================================================================
end

%==================================================================
% Train.
%
% ME('train')
%==================================================================

if strcmp(cmd,'train')
  
  % GET DATA
  W1 = get(W1_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  PV = get(PV_ptr,'userdata');
  Q = length(PV);
  if (Q == 0)
    return
  end
  blip = get(blip_ptr,'userdata');
  bloop = get(bloop_ptr,'userdata');
  axes(v_axis)
  set(fig,'nextplot','add')
  T1 = W2'*T;

  for i=1:max_epoch

    z = rand(5,5);

    % CHECK ERROR
    A1 = compet(-dist(W1,P));
    A2 = W2*A1;
    E = T-A2;
    if ~any(any(E)) & (max_epoch > 1) & 0, break, end
    
    % PRESENT VECTOR
    q = floor(rand*Q)+1;
    p = P(:,q);
    t = T(:,q);
    t1 = T1(:,q);
    n = -dist(W1,p);
    a1 = compet(n);
    a2 = W2*a1;
    e = t-a2;
    i = find(a1);
    set(PV(q),'facecolor',nngreen);
    nnsound(blip);
    nnpause(0.5)

    % MOVE WEIGHT: LVQ1
    if any(e)
      face_color = nnred;
    else
      face_color = nngreen;
    end
    set(WV(i),'color',face_color);
    nnsound(blip);
    nnpause(0.5)
 
    e1 = W2'*t;
    newW1 = W1;
    [s,r] = size(W1(i,:));
    %newW1(i,:) = W1(i,:) + (e1(i)*2-1)*feval('learnis',W1(i,:),p,a1(i),lr);
    newW1(i,:) = W1(i,:) + (e1(i)*2-1)*((lr*a1(i)*ones(1,r)) .* (ones(s,1)*p'-W1(i,:)));

    temp = nndrwvec([W1(i,1) newW1(i,1)],[W1(i,2) newW1(i,2)],...
      1,0.2,face_color,'','none');
    nnsound(blip);
    nnpause(1)
    set(temp,'color',nnltyell)
    delete(temp);
    W1 = newW1;

    set(WV(i),'color',nnltyell);
    set(WV(i),'visible','off');
    set(WV(i),...
      'xdata',cross_x + W1(i,1),...
      'ydata',cross_y + W1(i,2),...
      'color',center_colors(1+W2(1,i),:));
    set(WV(i),'visible','on')
    nnsound(bloop);

    % IF ERROR
    if any(e)

      a1 = compet(n + W2'*t*1e5);
      i = find(a1);

      % MOVE WEIGHT: LVQ2
      face_color = nngreen;
      set(WV(i),'color',face_color);
      nnsound(blip);
      nnpause(0.5)
 
      e1 = W2'*t;
      i = find(a1);
      newW1 = W1;
      [s,r] = size(W1(i,:));
      %newW1(i,:) = W1(i,:) + (e1(i)*2-1)*feval('learnis',W1(i,:),p,a1(i),lr);
      newW1(i,:) = W1(i,:) + (e1(i)*2-1)*((lr*a1(i)*ones(1,r)) .* (ones(s,1)*p'-W1(i,:)));

      temp = nndrwvec([W1(i,1) newW1(i,1)],[W1(i,2) newW1(i,2)],...
        1,0.2,face_color,'','none');
      nnsound(blip);
      nnpause(1)
      set(temp,'color',nnltyell)
      delete(temp);
      W1 = newW1;

      set(WV(i),'color',nnltyell);
      set(WV(i),'visible','off');
      set(WV(i),...
        'xdata',cross_x + W1(i,1),...
        'ydata',cross_y + W1(i,2),...
        'color',center_colors(1+W2(1,i),:));
      set(WV(i),'visible','on')
      nnsound(bloop);
    end

    % REDRAW INPUT VECTORS
    A1 = compet(-dist(W1,P));
    A2 = W2*A1;
    E = T-A2;
    for q=1:Q
      if E(1,q)
       edge_color = nnred;
      else
        edge_color = nndkgray;
      end
      set(PV(q),...
        'facecolor',center_colors(1+T(1,q),:),...
        'edgecolor',edge_color);
    end
  
    % REFRESH WEIGHT VECTORS
    set(WV,'visible','off')
    for i=length(WV):-1:1
      set(WV(i),'visible','on')
    end
  end

  set(W1_ptr,'userdata',W1);
  set(fig,'nextplot','new')
end
