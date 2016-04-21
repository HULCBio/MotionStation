function nnd14cl(cmd,arg1,arg2,arg3)
%NND14CL Competitive learning demonstration.
%
%  This demonstration requires either the MININNET functions
%   on the NND disk or the Neural Network Toolbox.

% $Revision: 1.8 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd14cl';
Fs = 8192;
colors = [nnred; nngreen; nndkgray];

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
  big_circle = H(4);       % Yellow circle
  big_cross = H(5);        % Blue cross bars
  WV_ptr = H(6);           % Pointer to weight vector handles
  W_ptr = H(7);            % Pointer to weights
  PV_ptr = H(8);           % Pointer to input vector handles
  P_ptr = H(9);           % Pointer to inputs
  lr_bar = H(10);          % Learning rate slider bar
  lr_text = H(11);         % Learning rate text
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
  if ~nnfexist(me), return, end

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Competitive Learning','','Chapter 14');

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
  lr = 0.4;
  x = 40;
  y = 60;
  len = 300;
  text(x,y,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(x+300,y,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+300,y-38,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 300 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',0,...
    'max',1,...
    'value',lr);

  % BIG AXES
  big_axis = nnsfo('a1','Function F','x(1)','x(2)');
  set(big_axis,...
    'position',[40 60 300 300],...
    'visible','off',...
    'xlim',[-1.1 1.1],...
    'ylim',[-1.1 1.1])
  angle = [0:5:360]*pi/180;
  angle2 = fliplr(angle);
  big_circle = fill3(cos(angle)*1.03,sin(angle)*1.03,-ones(size(angle)),nnltyell,...
    'edgecolor',nndkblue,...
    'erasemode','none');
  big_cross = plot([-1 1 NaN 0 0],[0 0 NaN -1 1],'--',...
    'color',nndkblue,...
    'erasemode','none');
  view(2);

  % WEIGHT VECTORS
  W = [sqrt(0.5) sqrt(0.5); sqrt(0.5) -sqrt(0.5); -1 0];
  WV = zeros(1,3);
  for i=1:3
    WV(i) = nndrwvec(W(i,1),W(i,2),2,0.05,colors(i,:),'','none');
  end

  % INPUT VECTORS
  angles = [105:5:120, -10:5:5, -120:5:-105]*pi/180;
  P = [cos(angles); sin(angles)];
  PV = zeros(length(angles),1);
  for i=1:length(angles)
    PV(i) = plot(P(1,i),P(2,i),'.',...
      'color',nndkblue,...
      'markersize',25,...
      'erasemode','none');
  end

  % REFRESH
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  for i=1:3
    set(WV(i),'color',colors(i,:));
  end
  a = compet(W*P);
  [ai,aj] = find(a);
  for i=1:size(ai,1)
    set(PV(i),'color',colors(ai(i),:));
  end

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 180 60 20],...
    'string','Learn',...
    'callback',[me '(''learn'')'])
  uicontrol(...
    'units','points',...
    'position',[410 150 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
  uicontrol(...
    'units','points',...
    'position',[410 120 60 20],...
    'string','Random',...
    'callback',[me '(''random'')'])
  uicontrol(...
    'units','points',...
    'position',[410 90 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  WV_ptr = uicontrol('visible','off','userdata',WV);
  W_ptr = uicontrol('visible','off','userdata',W);
  PV_ptr = uicontrol('visible','off','userdata',PV);
  P_ptr = uicontrol('visible','off','userdata',P);

  H = [fig_axis, ...
       desc_text,...
       big_axis, big_circle, big_cross,...
       WV_ptr, W_ptr, PV_ptr P_ptr, ...
       lr_bar lr_text];

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
    'Click on the edge of',...
    'the circle to add and',...
    'remove input vectors.',...
    'Click and drag to',...
    'move weight vectors.',...
    '',...
    'Click [Learn] to',...
    'present one input.',...
    'Click [Train] to',...
    'present five inputs.')
    
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

  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  W = get(W_ptr,'userdata');
  set(fig,'nextplot','add')
  axes(big_axis);

  % NORMALIZE
  angle = atan2(y,x);
  deg5 = 5*pi/180;
  angle = round(angle/deg5)*deg5;
  length1 = sqrt(x^2 + y^2);
  x = cos(angle);
  y = sin(angle);
  p = [x;y];

  % ATTEMPT TO FIND OLD INPUT NEAR CLICK
  found = 0;
  if (length1 < 1.1) & (length1 > 0.95)
    for i=1:size(PV,1)
      axy = atan2(P(2,i),P(1,i));
      if abs(angle - axy) < 0.001
        found = i;
        break;
      end
    end
  end

  % REMOVE INPUT VECTOR
  if found
    set(PV(i),'color',nnltgray);
    delete(PV(i));
    PV(i) = [];
    P(:,i) = [];

    % REFRESH
    set(big_circle,'facecolor',nnltyell);
    set(big_cross,'color',nndkblue);
    for i=1:3
      set(WV(i),'color',colors(i,:));
    end
    a = compet(W*P);
    [ai,aj] = find(a);
    for i=1:size(ai,1)
      set(PV(i),'color',colors(ai(i),:));
    end

  else

    % ATTEMPT TO IDENTIFY WEIGHT
    for i=1:size(WV,2)
      wa = atan2(W(i,2),W(i,1));
      wl = sqrt(W(i,1)^2 + W(i,2)^2);
      if (abs(angle - wa) < 0.001) & (length1 <= wl)
        found = i;
        break;
      end
    end

    % MOVE WEIGHT VECTORS
    if (found)
      set(WV(i),'color',nnltyell)
      set(fig,...
        'windowbuttonupfcn',[me '(''up'',' num2str(i) ')'],...
        'pointer','crosshair')

      % REFRESH
      set(big_circle,'facecolor',nnltyell);
      set(big_cross,'color',nndkblue);
      for j=1:3
        if j ~= i
          set(WV(j),'color',colors(j,:));
        end
      end
      a = compet(W*P);
      [ai,aj] = find(a);
      for i=1:size(ai,1)
        set(PV(i),'color',colors(ai(i),:));
      end

    % NEW INPUT VECTOR
    else
      pv = plot(x,y,'.',...
        'color',nndkblue,...
        'markersize',25,...
        'erasemode','none');
      PV = [PV; pv];
      P = [P [x; y]];

      % REFRESH
      set(big_circle,'facecolor',nnltyell);
      set(big_cross,'color',nndkblue);
      for i=1:3
        set(WV(i),'color',colors(i,:));
      end
      a = compet(W*P);
      [ai,aj] = find(a);
      for i=1:size(ai,1)
        set(PV(i),'color',colors(ai(i),:));
      end
    end

  end

  % SET DATA
  set(fig,'nextplot','new')
  set(PV_ptr,'userdata',PV);
  set(P_ptr,'userdata',P);
  set(WV_ptr,'userdata',WV);
  set(W_ptr,'userdata',W);

%==================================================================
% Button up.
%
% ME('up')
%==================================================================

elseif strcmp(cmd,'up') & (fig) & (nargin == 2)
  
  % INDEX
  i = arg1;

  % FIND CLICK POSITION
  axes(big_axis)
  pt = get(big_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  length1 = sqrt(x^2 + y^2);

  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  W = get(W_ptr,'userdata');
  set(fig,'nextplot','add')
  axes(big_axis);

  % NORMALIZE
  angle = atan2(y,x);
  deg5 = 5*pi/180;
  angle = round(angle/deg5)*deg5;
  length1 = sqrt(sum(x^2 + y^2));
  if length1 < 1.1
    length1 = min(length1,1);
  end
  x = cos(angle)*length1;
  y = sin(angle)*length1;
  p = [x;y];

  if length1 <= 1
    delete(WV(i));
    W(i,:) = [x y];
    WV(i) = nndrwvec(W(i,1),W(i,2),2,0.05,colors(i,:),'','none');
  else
    set(WV(i),'color',colors(i,:));
  end
  set(fig,...
     'windowbuttonupfcn','',...
     'pointer','arrow')

  % REFRESH
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  for i=1:3
    set(WV(i),'color',colors(i,:));
  end
  a = compet(W*P);
  [ai,aj] = find(a);
  for i=1:size(ai,1)
    set(PV(i),'color',colors(ai(i),:));
  end

  % SET DATA
  set(fig,'nextplot','new')
  set(PV_ptr,'userdata',PV);
  set(WV_ptr,'userdata',WV);
  set(W_ptr,'userdata',W);

%==================================================================
% Button down.
%
% ME('learn')
%==================================================================

elseif strcmp(cmd,'learn') & (fig) & (nargin == 1)
  
  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  W = get(W_ptr,'userdata');
  axes(big_axis);
  set(fig,'nextplot','add')
  lr = get(lr_bar,'value');

  i = floor(rand*size(PV,1))+1;
  p = P(:,i);

  % SHOW INPUT
  nnpause(0.5);
  set(fig,'nextplot','add');
  temp_circle = plot(p(1),p(2),'.',...
    'color',nndkblue,...
    'markersize',32,...
    'erasemode','none');
  set(PV(i),'color',nnwhite);
  nnpause(0.5);

  % CALCULATE NEW WEIGHT
  a = compet(W*p);
  i = find(a);
  newW = W + (lr*a*ones(1,2)).*(ones(3,1)*p'-W);

  temp1 = plot([W(i,1) p(1)],[W(i,2) p(2)],'--',...
    'color',nndkblue,...
    'erasemode','none');
  temp2 = nndrwvec([W(i,1) newW(i,1)],[W(i,2) newW(i,2)],2,0.05,nndkblue,'','none');
  nnpause(0.5);
  W = newW;

  % MOVE WEIGHT
  set(WV(i),'color',nnltyell);
  set(temp1,'color',nnltyell);
  set(temp2,'color',nnltyell);
  delete(WV(i));
  delete(temp1);
  delete(temp2);

  set(big_cross,'color',nndkblue);
  WV(i) = nndrwvec(W(i,1),W(i,2),2,0.05,colors(i,:),'','none');
  nnpause(0.5);

  % REFRESH
  delete(temp_circle);
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  for i=1:3
    set(WV(i),'color',colors(i,:));
  end
  a = compet(W*P);
  [ai,aj] = find(a);
  for i=1:size(ai,1)
    set(PV(i),'color',colors(ai(i),:));
  end

  % SET DATA
  set(fig,'nextplot','new')
  set(WV_ptr,'userdata',WV);
  set(W_ptr,'userdata',W);

%==================================================================
% Button down.
%
% ME('train')
%==================================================================

elseif strcmp(cmd,'train') & (fig) & (nargin == 1)

  nnpause(0.5);
  for xx=1:5
  
  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  W = get(W_ptr,'userdata');
  axes(big_axis);
  set(fig,'nextplot','add')
  lr = get(lr_bar,'value');

  i = floor(rand*size(PV,1))+1;
  p = P(:,i);

  % SHOW INPUT
  set(fig,'nextplot','add');
  temp_circle = plot(p(1),p(2),'.',...
    'color',nndkblue,...
    'markersize',32,...
    'erasemode','none');
  set(PV(i),'color',nnwhite);
  nnpause(1);

  % CALCULATE NEW WEIGHT
  a = compet(W*p);
  i = find(a);
  newW = W + (lr*a*ones(1,2)).*(ones(3,1)*p'-W);

  temp1 = plot([W(i,1) p(1)],[W(i,2) p(2)],'--',...
    'color',nndkblue,...
    'erasemode','none');
  temp2 = nndrwvec([W(i,1) newW(i,1)],[W(i,2) newW(i,2)],2,0.05,nndkblue,'','none');
  nnpause(0.5);
  W = newW;

  % MOVE WEIGHT
  set(WV(i),'color',nnltyell);
  set(temp1,'color',nnltyell);
  set(temp2,'color',nnltyell);
  delete(WV(i));
  delete(temp1);
  delete(temp2);

  set(big_cross,'color',nndkblue);
  WV(i) = nndrwvec(W(i,1),W(i,2),2,0.05,colors(i,:),'','none');
  nnpause(0.5);

  % REFRESH
  delete(temp_circle);
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  for i=1:3
    set(WV(i),'color',colors(i,:));
  end
  a = compet(W*P);
  [ai,aj] = find(a);
  for i=1:size(ai,1)
    set(PV(i),'color',colors(ai(i),:));
  end

  % SET DATA
  set(fig,'nextplot','new')
  set(WV_ptr,'userdata',WV);
  set(W_ptr,'userdata',W);

  nnpause(0.5);
  set(fig,'nextplot','new');

  end

%==================================================================
% Respond to learning rate slider.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr')
  
  lr = get(lr_bar,'value');
  set(lr_text,'string',sprintf('%5.2f',round(lr*10)*0.1))

%==================================================================
% Clear input vectors.
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random') & (fig) & (nargin == 1)
  
  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  axes(big_axis);
  set(fig,'nextplot','add')

  delete(WV);
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  set(PV,'color',nndkblue);

  angle = rand(1,3)*2*pi;
  WV = [];
  for i=1:3
    W(i,:) = [cos(angle(i)) sin(angle(i))];
    WV(i) = nndrwvec(W(i,1),W(i,2),2,0.05,colors(i,:),'','none');
    set(WV(i),'color',colors(i,:));
  end

  % REFRESH
  set(big_circle,'facecolor',nnltyell);
  set(big_cross,'color',nndkblue);
  for i=1:3
    set(WV(i),'color',colors(i,:));
  end
  a = compet(W*P);
  [ai,aj] = find(a);
  for i=1:size(ai,1)
    set(PV(i),'color',colors(ai(i),:));
  end

  % SET DATA
  set(fig,'nextplot','new')
  set(W_ptr,'userdata',W);
  set(WV_ptr,'userdata',WV);
end
