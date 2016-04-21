function nnd14fm1(cmd,arg1,arg2,arg3)
%NND14FM1 1-D feature map demonstration.
%
%  This demonstration requires the Neural Network Toolbox.

% $Revision: 1.8 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd14fm1';
Fs = 8192;
Sx = 1;
Sy = 20;
S = Sx*Sy;
max_dist = ceil(sqrt(sum([Sx Sy].^2)));
NDEC = 0.998;

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end

% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  fig_axis = H(1);         % window axis
  desc_text = H(2);        % handle to first line of text sequence
  big_axis = H(3);         % Big axis
  big_edge = H(4);         % Light gray band around circle
  big_circle = H(5);       % Yellow circle
  big_cross = H(6);        % Blue cross bars
  W_ptr = H(7);            % Pointer to weights
  lr_bar = H(8);           % Learning rate slider bar
  lr_text = H(9);          % Learning rate text
  NN = H(10);              % Number of lines
  N_ptr = H(11);           % Neighbors
  NV_ptr = H(12);          % Handles to neighbor vectors.
  Nfrom_ptr = H(13);       % Neighbor from
  Nto_ptr = H(14);         % Neighbor to
  P_ptr = H(15);           % Pointer to input vectors
  ns_bar = H(16);          % Neighborhood size slider bar
  ns_text = H(17);         % Neighborhood size text
  pr_text = H(18);         % Handle to presentations text

  N = get(N_ptr,'userdata');
  NV = get(NV_ptr,'userdata');
  Nfrom = get(Nfrom_ptr,'userdata');
  Nto = get(Nto_ptr,'userdata');
  P = get(P_ptr,'userdata');
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

  % CHECK FOR TRANSFER FUNCTIONS
  if ~nntexist(me), return, end

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','1-D Feature Map','','Chapter 14');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(14,458,363,'shadow')

  % LEARNING RATE SLIDER BAR
  lr = 1;
  x = 20;
  y = 60;
  len = 150;
  text(x,y,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(x+len,y,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',0,...
    'max',1,...
    'value',lr);

  % NEIGHBORHOOD SLIDER BAR
  ns = max_dist;
  x = 190;
  y = 60;
  len = 150;
  text(x,y,'Neighborhood:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  ns_text = text(x+len,y,num2str(max_dist),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,num2str(max_dist),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  ns_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''neighborhood'')'],...
    'min',0,...
    'max',max_dist,...
    'value',max_dist);

  % PRESENTATIONS
  text(20,345,'Presentations:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left');
  pr_text = text(60,325,'0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','center');

  % BIG AXES
  big_axis = nnsfo('a1','Function F','x(1)','x(2)');
  set(big_axis,...
    'position',[45 65 290 290],...
    'visible','off',...
    'xlim',[-1.1 1.1],...
    'ylim',[-1.1 1.1])
  angle = [0:5:360]*pi/180;
  angle2 = fliplr(angle);
  big_edge = fill3([cos(angle)*1.1 cos(angle2)*1.1],[sin(angle) sin(angle2)],...
    zeros(1,length(angle)*2)-2,nnltgray,...
    'erasemode','none',...
    'edgecolor','none');
  big_circle = fill3(cos(angle)*1.01,sin(angle)*1.01,-ones(size(angle)),nnltyell,...
    'edgecolor',nndkblue,...
    'erasemode','none');
  big_cross = plot([-1 1 NaN 0 0],[0 0 NaN -1 1],'--',...
    'color',nndkblue,...
    'erasemode','none');
  view(2);

  % WEIGHT VECTORS
  W = [zeros(S,2) ones(S,1)];

  [Y,X] = meshgrid(1:Sy,1:Sx);
  Ind2Pos = [X(:) Y(:)];
  Pos2Ind = (X-1)*Sy+Y;
  N = zeros(S,S);
  for i=1:S
    for j=1:(i-1)
      posi = Ind2Pos(i,:);
      posj = Ind2Pos(j,:);
      N(i,j) = sqrt(sum((posi-posj).^2));
    end
  end

  [Nfrom,Nto] = find(N == 1);
  NN = length(Nfrom);
  NV = zeros(1,NN);
  for i=1:NN
    from = Nfrom(i);
    to = Nto(i);
    NV(i) = plot([W(from,1) W(to,1)],[W(from,2) W(to,2)],...
      'color',nnred,...
      'erasemode','none');
  end
  N = N + N';

  % INPUT VECTORS
  P = [rand(2,1000)-0.5; ones(1,1000)];
  P = P ./ (ones(3,1)*sqrt(sum(P.^2)));

  % INPUT BOX
  up = [-0.5:0.1:0.4];
  down = -up;
  flat = zeros(1,length(up))+0.5;
  xx = [up flat down -flat up(1)];
  yy = [-flat up flat down -flat(1)];
  zz = [xx; yy];
  zz = zz ./ (ones(2,1)*sqrt(sum(zz.^2)+1));
  plot(zz(1,:),zz(2,:),...
    'color',nndkblue,...
    'erasemode','none');

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 165 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
  uicontrol(...
    'units','points',...
    'position',[410 130 60 20],...
    'string','Reset',...
    'callback',[me '(''reset'')'])
  uicontrol(...
    'units','points',...
    'position',[410 95 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  W_ptr = uicontrol('visible','off','userdata',W);
  N_ptr = uicontrol('visible','off','userdata',N);
  NV_ptr = uicontrol('visible','off','userdata',NV);
  Nfrom_ptr = uicontrol('visible','off','userdata',Nfrom);
  Nto_ptr = uicontrol('visible','off','userdata',Nto);
  P_ptr = uicontrol('visible','off','userdata',P);

  H = [fig_axis, ...
       desc_text,...
       big_axis, big_edge, big_circle, big_cross,...
       W_ptr, lr_bar lr_text NN N_ptr NV_ptr Nfrom_ptr Nto_ptr P_ptr,...
       ns_bar ns_text pr_text];

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
    'Click on [Train] to',...
    'present 500 vectors',...
    'to the feature map.',...
    'Several clicks are',...
    'required to obtain',...
    'a stable network.',...
    '',...
    'Click [Reset] to',...
    'start over if the',...
    'network develops',...
    'a twist.')
    
%==================================================================
% Button down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)
  
  % FIND CLICK POSITION
  axes(big_axis)
  pt = get(big_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  length1 = sqrt(x^2 + y^2);

  if (length1 < 1.1) & (length1 > 0.9)

    % NORMALIZE
    x = x/length1;
    y = y/length1;
    p = [x;y];

    pv = plot(p(1),p(2),'.',...
      'color',nndkblue,...
      'markersize',25,...
      'erasemode','none');
    drawnow

    set(pv,'color',nnltyell);
    delete(pv);

  end

%==================================================================
% Train network.
%
% ME('train')
%==================================================================

elseif strcmp(cmd,'train') & (fig) & (nargin == 1)
  
  % GET DATA
  W = get(W_ptr,'userdata');
  axes(big_axis);
  set(fig,'nextplot','add')
  NS = get(ns_bar,'value');
  lr = get(lr_bar,'value');
  pr = str2num(get(pr_text,'string'));

[s,r] = size(W);

Q = size(P,2);

for z=1:500

  % NEW INPUT
  q = fix(rand*Q)+1;
  p = P(:,q);

  % NETWORK OUTPUT
  a = compet(W*p);
  i = find(a);
  a = 0.5*(a + (N(:,i) <= NS));

  % UPDATE NETWORK
  %W = W + feval('learnis',W,p,a,lr);
  W = W + (lr*a*ones(1,r)) .* (ones(s,1)*p'-W);

  lr = (lr-0.01)*0.998+0.01;
  NS = (NS-1)*NDEC+1;

  % DISPLAY
  if (rem(z,100) == 0)

    % HIDE LINES
    set(NV,'color',nnltyell)

    % MOVE LINES
    for i=1:NN
      from = Nfrom(i);
      to = Nto(i);
      set(NV(i),...
        'xdata',[W(from,1) W(to,1)],...
        'ydata',[W(from,2) W(to,2)])
    end
    set(NV,'color',nnred)
    set(big_cross,'color',nndkblue);
    drawnow

    set(lr_bar,'value',lr);
    set(lr_text,'string',sprintf('%5.2f',lr))
    set(ns_bar,'value',NS);
    set(ns_text,'string',sprintf('%5.2f',NS))
    set(pr_text,'string',sprintf('%g',pr+z))
    drawnow
  end
end

  % SET DATA
  set(fig,'nextplot','new')
  set(W_ptr,'userdata',W);
  set(lr_bar,'value',lr);
  set(lr_text,'string',sprintf('%5.2f',lr))
  set(ns_bar,'value',NS);
  set(ns_text,'string',sprintf('%5.2f',NS))

%==================================================================
% Respond to learning rate slider.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr')
  
  lr = get(lr_bar,'value');
  set(lr_text,'string',sprintf('%5.2f',lr))

%==================================================================
% Respond to neighborhood slider.
%
% ME('neighborhood')
%==================================================================

elseif strcmp(cmd,'neighborhood')
  
  ns = get(ns_bar,'value');
  set(ns_text,'string',sprintf('%5.2f',ns))

%==================================================================
% Reset map.
%
% ME('reset')
%==================================================================

elseif strcmp(cmd,'reset') & (fig) & (nargin == 1)
  
  % GET DATA
  axes(big_axis);
  set(fig,'nextplot','add')

  % RESET PRESENTATIONS
  set(pr_text,'string','0');

  % RESET WEIGHT VECTORS
  W = [zeros(S,2) ones(S,1)];

  % HIDE LINES
  set(NV,'color',nnltyell)
  drawnow

  % MOVE LINES
  for i=1:NN
    from = Nfrom(i);
    to = Nto(i);
    set(NV(i),...
      'xdata',[W(from,1) W(to,1)],...
      'ydata',[W(from,2) W(to,2)])
  end
  set(NV,'color',nnred)
  drawnow

  lr = 1;
  NS = max_dist;
  set(lr_bar,'value',lr);
  set(lr_text,'string',sprintf('%5.2f',lr))
  set(ns_bar,'value',NS);
  set(ns_text,'string',sprintf('%5.2f',NS))

  % SET DATA
  set(fig,'nextplot','new')
  set(W_ptr,'userdata',W);
end
