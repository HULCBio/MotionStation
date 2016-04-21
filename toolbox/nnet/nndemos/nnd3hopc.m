function nnd3hopc(cmd,arg1,arg2,arg3)
%NND3HOPC Hopfield classification demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.

% $Revision: 1.8 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd3hopc';
Fs = 8192;

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
  lines = H(3:4);          % handles to red lines in conveyor ends
  indicators = H(5:7);     % fruit, orange & apple indicators
  sounds = H(8:14);        % pointers to sounds
  nnet = H(15:17);         % handles to box & text of neural network
  p_text = H(18:20);       % handles to three input displays
  angle_ptr = H(21);       % angle (deg) of lines in conveyer ends
  fruit_ptr = H(22);       % pointer to fruit shape
  id_ptr = H(23);          % pointer to fruit type (1-orange 2-apple)
  net_ptr = H(24);         % pointer to network specific data
  p_ptr = H(25);           % pointer to input vector
  arrows = H(26:27);       % handles to arrows
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
  fig = nndemof2(me,'DESIGN','Hopfield Classification','','Chapter 3');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % nnsound POINTERS
  wind = uicontrol('visible','off','userdata',nndsnd(3));
  knock = uicontrol('visible','off','userdata',nndsnd(5));
  scan = uicontrol('visible','off','userdata',nndsnd(1));
  classify = uicontrol('visible','off','userdata',nndsnd(4));
  blip = uicontrol('visible','off','userdata',nndsnd(6));
  bloop = uicontrol('visible','off','userdata',nndsnd(7));
  blp = uicontrol('visible','off','userdata',nndsnd(9));

  % ICON
  nndicon(3,458,363,'shadow')

  % CONVEYER BELT
  deg = pi/180;
  angle = [0:5:360]*deg;
  cx = cos(angle);
  cy = sin(angle);

  % ENTRANCE BOX
  x = 60;
  y = 20;
  fill([0 0 x+10 x+10],y+[70 50 50 70],nndkblue,...
    'edgecolor','none')
  fill(x+[10 10 50 50],y+[80 40 40 80],nndkblue,...
    'edgecolor','none')
  plot([0 x+[10 10 50 50 10 10] 0],...
    y+[50 50 40 40 80 80 70 70],...
    'color',nnred)
  left_arrow = fill(x+30+[-5 -5 -10 0 10 5 5],y+60+[15 5 5 -15 5 5 15],nndkblue,...
    'edgecolor',nnred,...
    'erasemode','none');
  fruit_ind = text(x-25,y+60,'Fruit',...
    'color',[0.8 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');

  % LEFT CIRCLE
  line_angle = 45*deg;
  fill(x-10+cx*10,y+10+cy*10,nnred,...
    'edgecolor',nndkblue,...
    'linewidth',2)
  line_1 = plot(x-10+cos([0 pi]+line_angle)*8,y+10+sin([0 pi]+line_angle)*8,...
    'color',nndkblue,...
    'erasemode','none',...
    'linewidth',2);

  % RIGHT CIRCLE
  x = 320;
  fill(x+10+cx*10,y+10+cy*10,nnred,...
    'edgecolor',nndkblue,...
    'linewidth',2)
  line_2 = plot(x+10+cos([0 pi]+line_angle)*8,y+10+sin([0 pi]+line_angle)*8,...
    'color',nndkblue,...
    'erasemode','none',...
    'linewidth',2);

  % BELT
  plot([50 330],[y y]+20,...
    'color',nndkblue,...
    'linewidth',2)
  plot([50 330],[y y],...
    'color',nndkblue,...
    'linewidth',2)

  % SENSOR BOX
  x = 130;
  plot(x+[10 10 60 NaN 0 0 60 NaN -10 -10 60],...
    y+[90 70 70 NaN 90 60 60 NaN 90 50 50],...
    'color',nndkblue,...
    'linewidth',2)
  fill(x+[0 40 20],y+[40 40 80],nndkblue,...
    'edgecolor',nnred)
  fill(x+[0 40 40 0],y+[14 14 8 8],nndkblue,...
    'edgecolor',nnred)
  fill([0 0 380 380],y+[90 110 110 90],nndkblue,...
    'edgecolor','none')
  p1_text = text(20,y+100,'SHAPE: ?',...
    'color',nnltgray,...
    'fontweight','bold',...
    'horiz','left',...
    'erasemode','none');
  p2_text = text(190,y+100,'TEXTURE: ?',...
    'color',nnltgray,...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');
  p3_text = text(360,y+100,'WEIGHT: ?',...
    'color',nnltgray,...
    'fontweight','bold',...
    'horiz','right',...
    'erasemode','none');

  % NEURAL NETWORK
  x = 190;
  plot(x+[60 80],y+[60 60],...
    'color',nndkblue,...
    'linewidth',2)
  nn_box = fill(x+[5 0 0 5 55 60 60 55],y+[80 75 45 40 40 45 75 80],nndkblue,...
    'edgecolor',nnred,...
    'erasemode','none');
  nn_text1 = text(x+30,y+68,'Neural',...
    'color',[0 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');
  nn_text2 = text(x+30,y+52,'Network',...
    'color',[0 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');

  % EXIT BOX
  x = 320;
  fill([x-10 x-10 380 380],y+[80 62 62 80],nndkblue,...
    'edgecolor','none')
  fill([x-10 x-10 380 380],y+[40 58 58 40],nndkblue,...
    'edgecolor','none')
  fill(x-[10 10 50 50],y+[80 40 40 80],nndkblue,...
    'edgecolor','none')
  plot([378 x-[50 50] 378],y+[80 80 40 40],...
    'color',nnred)
  plot([378 x-[10 10] 378],y+[62 62 58 58],...
    'color',nnred)
  right_arrow = fill(x-30+[-5 -5 -10 0 10 5 5],y+60-[15 5 5 -15 5 5 15],nndkblue,...
    'edgecolor',nnred,...
    'erasemode','none');
  orange_ind = text(x+25,y+72,'Oranges',...
    'color',[1 0.5 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');
  apple_ind = text(x+25,y+50,'Apples',...
    'color',[1 0 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');

  % BUTTONS
  drawnow % Let everything else appear before buttons
  uicontrol(...
    'units','points',...
    'position',[400 180 60 20],...
    'string','Go',...
    'callback',[me '(''fruit'')'])
  uicontrol(...
    'units','points',...
    'position',[400 145 60 20],...
    'string','Clear',...
    'callback',[me '(''remove'')'])
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

  % SAVE WINDOW DATA AND LOCK
  angle_ptr = uicontrol('visible','off','userdata',line_angle);
  fruit_ptr = uicontrol('visible','off','userdata',[]);
  id_ptr = uicontrol('visible','off','userdata',[]);
  net_ptr = uicontrol('visible','off','userdata',[]);
  p_ptr = uicontrol('visible','off','userdata',[]);

  H = [fig_axis, ...
       desc_text, ...
       line_1 line_2, ...
       fruit_ind orange_ind apple_ind, ...
       wind knock scan classify blip bloop blp, ...
       nn_box nn_text1 nn_text2, ...
       p1_text p2_text p3_text, ...
       angle_ptr fruit_ptr id_ptr net_ptr p_ptr, ...
       left_arrow right_arrow];

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

  % SETUP NETWORK SPECIFIC STUFF
  feval(me,'setup')

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
    'Click [Go] to send a',...
    'fruit down the belt',...
    'to be classified by a',...
    'Hopfield network.',...
    '',...
    'The calculations for',...
    'the Hopfield network',...
    'will appear to the left.')
    
%==================================================================
% Respond to fruit.
%
% ME('fruit')
%==================================================================

elseif strcmp(cmd,'fruit') & (fig) & (nargin == 1)

  set(fig,'pointer','watch');
  
  % GET DATA
  wind = get(sounds(1),'userdata');
  knock = get(sounds(2),'userdata');
  scan = get(sounds(3),'userdata');
  classify = get(sounds(4),'userdata');
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  blp = get(sounds(7),'userdata');
  angle = get(angle_ptr,'userdata');
  fruit = get(fruit_ptr,'userdata');
  fruit_id = get(id_ptr,'userdata');
  axes(fig_axis);

  % GET RID OF PREVIOUS FRUIT
  if length(fruit) > 0

    % CLEAR VALUES
    set(p_text,...
      'color',nndkblue)
    set(p_text(1),...
      'string','SHAPE: ?',...
      'color',nnltgray)
    set(p_text(2),...
      'string','TEXTURE: ?',...
      'color',nnltgray)
    set(p_text(3),...
      'string','WEIGHT: ?',...
      'color',nnltgray)

    % CLEAR NETWORK DEPENDENT STUFF
    feval(me,'clear')

    nnpause(0.5)
    end

  % NEW FRUIT
  nnpause(0.5)
  x = 82;
  y = 42;

  % FRUIT ID, COLOR & SHAPE
  if (rand > 0.5)
    % ORANGE
    fruit_id = 1;
    fruit_x = [5 0 0 5 10 15 15 10];
    fruit_y = [15 10 5 0 0 5 10 15];
    fruit_c = [1 0.5 0];
    p = [1; -1; -1];
  else
    % APPLE
    fruit_id = 2;
    fruit_x = [7.5 5 0 0 5 7.5 10 15 15 10];
    fruit_y = [13 15 10 5 0 2 0 5 10 15];
    fruit_c = [1 0 0];
    p = [1; 1; -1];
  end
  p = p*0.6 + (rands(3,1) .^ 2) * 0.4;
  p = round(p*100)/100;
  set(p_ptr,'userdata',p);

  % FLASH FRUIT INDICATOR TWICE
  set(fig,'nextplot','add')
  nnsound(blip,Fs);
  set(indicators(1),...
    'color',[1 1 1])
  box = plot([10 60 60 10 10],[72 72 88 88 72],...
    'color',[1 1 1],...
    'erasemode','none');

  nnpause(0.25)
  nnsound(bloop,Fs);
  set(indicators(1),...
    'color',[0.8 0.8 0])
  set(box,...
    'color',[0.8 0.8 0])

  nnpause(0.25)
  nnsound(blip,Fs);
  set(indicators(1),...
    'color',[1 1 1])
  set(box,...
    'color',[1 1 1])

  nnpause(0.25)
  nnsound(bloop,Fs);
  set(indicators(1),...
    'color',[0.8 0.8 0])
  set(box,...
    'color',nndkblue)
  delete(box)
  nnpause(0.25)

  set(arrows(1),...
    'facecolor',nnred)
  t1 = clock;
  nnsound(wind,Fs);
  while etime(clock,t1) < 0.5, end
  nnpause(0.25)
  set(arrows(1),...
    'facecolor',nndkblue)

  set(indicators(1),...
    'color',[0.8 0.8 0])

  % CREATE FRUIT
  fruit = fill(x+fruit_x,y+fruit_y,fruit_c,...
    'edgecolor',fruit_c*0.5,...
    'erasemode','none');
  set(fig,'nextplot','new')
  nnsound(knock,Fs);
  nnpause(0.25)

  % MOVE FRUIT TO SENSOR
  deg = pi/180;
  for dx=10:10:60
    t1 = clock;
    nnsound(blp,Fs);
    while etime(clock,t1) < 0.05, end
    set(fruit,...
      'facecolor',nnltgray,...
      'edgecolor',nnltgray);
    set(fruit,...
      'facecolor',fruit_c,...
      'edgecolor',fruit_c*0.5,...
      'xdata',fruit_x + x + dx)
    angle = angle + 20;
    adata = [0 pi]-angle*deg;
    xdata = cos(adata)*8;
    ydata = sin(adata)*8+30;
    set(lines,'color',nnred);
    set(lines(1),...
      'xdata',xdata+50,...
      'ydata',ydata,...
      'color',nndkblue)
    set(lines(2),...
      'xdata',xdata+330,...
      'ydata',ydata,...
      'color',nndkblue)
  end

  % SCAN FRUIT
  nnpause(0.25)
  set(fig,'nextplot','add')
  h1 = fill([170 130 130 170],[35 35 39 39],[1 1 1],...
    'edgecolor','none',...
    'erasemode','none');
  h2 = fill([170 130 130 170],[41 41 58 58],[1 1 1],...
    'edgecolor','none',...
    'erasemode','none');
  set(fruit,...
   'facecolor',[1 1 1])

  t1 = clock;
  nnsound(scan,Fs);
  while etime(clock,t1) < 0.5, end

  set(h1,'facecolor',nnltgray)
  set(h2,'facecolor',nnltgray)
  delete(h1)
  delete(h2)
  set(fruit,...
    'facecolor',fruit_c)
  set(fig,'nextplot','new')
  nnpause(0.25)

  % MOVE DATA FROM SCANNER TO NETWORK & DISPLAY
  xx = [157 188 NaN 162 188 NaN 167 188 NaN, ...
        142 140 140 NaN 137 130 130 NaN 132 120 120];
  yy = [90 90 NaN 80 80 NaN 70 70 NaN, ...
        90 90 110 NaN 80 80 110 NaN 70 70 110];
  set(fig,'nextplot','add')

  nnsound(blip,Fs);
  data = plot(xx,yy,...
    'color',[1 1 1],...
    'erasemode','none',...
    'linewidth',2);
  for j=1:3
    if j == 1, str = 'SHAPE: ';
    elseif j == 2, str = 'TEXTURE: ';
    else str = 'WEIGHT: '; end

    if p(j) >= 0
      sign = '+';
    else
      sign = '-';
    end

    set(p_text(j),...
      'color',nndkblue)
    set(p_text(j),...
      'string',[str,sign,num2str(abs(p(j)))],...
      'color',nngreen)
  end

  nnpause(0.25);
  nnsound(bloop,Fs);
  set(data,...
    'color',nndkblue)
  delete(data);

  % CLASSIFY FRUIT
  nnpause(0.25)
  nnsound(blip,Fs);
  set(nnet(1),...
    'edgecolor',[1 1 1],...
    'facecolor',nndkblue)
  set(nnet(2:3),...
    'color',[1 1 1])
  axes(fig_axis);
  nnpause(0.25)
  nnsound(bloop,Fs);
  set(nnet(1),...
    'edgecolor',[1 0 0],...
    'facecolor',nndkblue)
  set(nnet(2:3),...
    'color',[0 1 0])

  % CALL CLASSIFICATION ROUTINE
  t1 = clock;
  nnsound(classify,Fs);
  while etime(clock,t1) < 1, end

  feval(me,'classify')
  nnpause(0.25)

  % MOVE DATA FROM NETWORK TO EXIT
  xx = [252 268];
  yy = [80 80];
  set(fig,'nextplot','add')
  nnsound(blip,Fs);
  data = plot(xx,yy,...
    'color',[1 1 1],...
    'erasemode','none',...
    'linewidth',2);
  set(indicators(fruit_id+1),...
     'color',[1 1 1])
  axes(fig_axis)
  if fruit_id == 1
    box_x = 84;
  else
    box_x = 62;
  end
  box = plot([0 62 62 0 0]+314,[0 0 14 14 0]+box_x,...
    'color',[1 1 1],...
    'erasemode','none');

  nnpause(0.25);
  nnsound(bloop,Fs);
  set(data,...
    'color',nndkblue)
  delete(data);
    
  % MOVE FRUIT TO EXIT
  for dx=70:10:200
    t1 = clock;
    nnsound(blp,Fs);
    while etime(clock,t1) < 0.05, end
    set(fruit, ...
      'facecolor',nnltgray, ...
      'edgecolor',nnltgray);
    set(fruit, ...
      'facecolor',fruit_c, ...
      'edgecolor',fruit_c*0.5, ...
      'xdata',fruit_x + x + dx)
    angle = angle + 20;
    adata = [0 pi]-angle*deg;
    xdata = cos(adata)*8;
    ydata = sin(adata)*8+30;
    set(lines,'color',nnred);
    set(lines(1),...
      'xdata',xdata+50,...
      'ydata',ydata,...
      'color',nndkblue)
    set(lines(2),...
      'xdata',xdata+330,...
      'ydata',ydata,...
      'color',nndkblue)
  end

  % REMOVE FRUIT
  nnpause(0.5)
  nnsound(blip,Fs);
  set(fruit,...
    'facecolor',nnltgray,...
    'edgecolor',nnltgray);
  delete(fruit)
  set(arrows(2),...
    'facecolor',nnred)
  nnsound(wind,Fs);
  set(arrows(2),...
    'facecolor',nndkblue)

  % UNLIGHT APPROPRIATE INDICATOR
  nnpause(0.5)
  nnsound(bloop,Fs);
  set(indicators(fruit_id+1),...
    'color',fruit_c)
  set(box,...
    'color',nndkblue)
  delete(box)
  set(fig,'nextplot','new')

  % SAVE DATA
  set(angle_ptr,'userdata',angle);
  set(fruit_ptr,'userdata',fruit);
  set(id_ptr,'userdata',fruit_id);
  
  set(fig,'pointer','arrow')

%==================================================================
% Remove previous fruit (activated by hitting "Clear" button).
%
% ME('remove')
%==================================================================

elseif strcmp(cmd,'remove') & (fig) & (nargin == 1)
  
  % GET DATA
  wind = get(sounds(1),'userdata');
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  fruit = get(fruit_ptr,'userdata');
  fruit_id = get(id_ptr,'userdata');
  axes(fig_axis);

  % GET RID OF PREVIOUS FRUIT
  if length(fruit) > 0

    % FRUIT COLOR
    if (fruit_id == 1)
      fruit_c = [1 0.5 0];
    else
      fruit_c = [1 0 0];
    end

    % UNLIGHT APPROPRIATE INDICATOR
    nnpause(0.5)
    nnsound(bloop,Fs);
    set(indicators(fruit_id+1),...
      'color',fruit_c)

    % CLEAR VALUES
    set(p_text,...
      'color',nndkblue)
    set(p_text(1),...
      'string','SHAPE: ?',...
      'color',nnltgray)
    set(p_text(2),...
      'string','TEXTURE: ?',...
      'color',nnltgray)
    set(p_text(3),...
      'string','WEIGHT: ?',...
      'color',nnltgray)

    % CLEAR NETWORK DEPENDENT STUFF
    feval(me,'clear')

    % STORE DATA
    set(fruit_ptr,'userdata',[]);
  end

%==================================================================
% Setup network specific parts of window.
%
% ME('setup')
%==================================================================

elseif strcmp(cmd,'setup') & (fig) & (nargin == 1)

  set(fig,'nextplot','add')

  % EXPRESSION
  x = 220;
  text(x,340,'W = [.2 0 0; 0 1.2 0; 0 0 .2]',...
    'color',nndkblue,...
    'fontweight','bold',...
    'fontsize',10)
  text(x,304,'b1 = [0.9; 0; -0.9]',...
    'color',nndkblue,...
    'fontweight','bold',...
    'fontsize',10)
  line1 = text(x,268,'p = [?; ?; ?]',...
    'color',nnltgray,...
    'erasemode','none',...
    'fontweight','bold',...
    'fontsize',10);
  line2 = text(x,232,'a(0) = p',...
    'color',nnltgray,...
    'erasemode','none',...
    'fontweight','bold',...
    'fontsize',10);
  line3 = text(x,196,'a(0) = [?; ?; ?]',...
    'color',nnltgray,...
    'erasemode','none',...
    'fontweight','bold',...
    'fontsize',10);
  line4 = text(x,160,'Fruit = ?',...
    'color',nnltgray,...
    'erasemode','none',...
    'fontweight','bold',...
    'fontsize',10);

  % INPUT SPACE AXES
  ext = 1.25;
  input_axis = nnsfo('a4','Input Space','shape','texture','weight');
  set(input_axis,...
    'xlim',[-1 1]*ext,'xtick',[-1 1],...
    'ylim',[-1 1]*ext,'ytick',[-1 1],...
    'zlim',[-1 1]*ext,'ztick',[-1 1],...
    'pos',[48 175 140 140],...
    'box','off');
  view(3)
  
  % EDGE
  edge = plot3([-1 -1 -1 1 1 1 -1]*ext,[-1 1 1 1 -1 -1 -1]*ext,...
    [-1 -1 1 1 1 -1 -1]*ext,...
    'color',nndkblue,...
    'erasemode','none');

  % BOX
  box1 = plot3([-1 1 1 -1 -1],[-1 -1 -1 -1 -1],[-1 -1 1 1 -1],':',...
    'color',nndkblue,...
    'erasemode','none');
  box2 = plot3([-1 1 1 -1 -1],[1 1 1 1 1],[-1 -1 1 1 -1],':',...
    'color',nndkblue,...
    'erasemode','none');
  box3 = plot3([-1 -1 -1 -1 -1],[-1 1 1 -1 -1],[-1 -1 1 1 -1],':',...
    'color',nndkblue,...
    'erasemode','none');
  box4 = plot3([1 1 1 1 1],[-1 1 1 -1 -1],[-1 -1 1 1 -1],':',...
    'color',nndkblue,...
    'erasemode','none');

  boundary = plot3([-1 1 1 -1 -1],[0 0 0 0 0],[-1 -1 1 1 -1],...
    'color',nndkblue,...
    'erasemode','none');

  % PROTOTYPE ORANGE
  orange_dot = plot3(1,-1,-1,'.',...
    'markersize',25,...
    'color',[1 0.5 0],...
    'erasemode','none');

  % PROTOTYPE APPLE
  apple_dot = plot3(1,1,-1,'.',...
    'markersize',25,...
    'color',[1 0 0],...
    'erasemode','none');

  % STORE DATA
  p_mark_ptr = uicontrol('visible','off','userdata',[]);
  lines_ptr = uicontrol('visible','off','userdata',...
     [line1 line2 line3 line4]);
  H = [input_axis, ...
       orange_dot apple_dot,...
       edge box1 box2 box3 box4 boundary,...
       lines_ptr,...
       p_mark_ptr];
  set(net_ptr,'userdata',H);

  set(fig,'nextplot','new')

%==================================================================
% Classify fruit with network.
%
% ME('classify')
%==================================================================

elseif strcmp(cmd,'classify') & (fig) & (nargin == 1)

  % GET DATA
  p = get(p_ptr,'userdata');
  H = get(net_ptr,'userdata');
  input_axis = H(1);           % handle to input space axis
  dots = H(2:3);               % handles to orange & apple dots
  frame = H(4:9);              % frame & boundary
  lines_ptr = H(10);
  p_mark_ptr = H(11);          % pointer to input marks

  lines = get(lines_ptr,'userdata');

  axes(input_axis);
  set(fig,'nextplot','add')

  % SHOW INPUT LINES
  p1 = p(1);
  p2 = p(2);
  p3 = p(3);
  p_marks = plot3([p1 p1 NaN p1 p1 NaN -1 1],[p2 p2 NaN -1 1 NaN p2 p2],...
    [-1 1 NaN p3 p3 NaN p3 p3],'-',...
    'color',nngreen,...
    'erasemode','none',...
    'markersize',15);
  
  % FLASH INPUT LINES
  for i=1:8
    nnpause(0.075)
    set(p_marks,...
      'color',nnltyell)
    set(dots(1),...
      'color',[1 0.5 0])
    set(dots(2),...
      'color',[1 0 0])
    set(frame,...
      'color',nndkblue)
    nnpause(0.05)
    set(p_marks,...
      'color',nngreen)
  end

  % PERFORM CALCULATION
  W = [0.2 0 0; 0 1.2 0; 0 0 0.2];
  b = [0.9; 0; -0.9];
  a = p;

  % SHOW FIRST CALCULATION
  axes(fig_axis);
  nntxtchk;

  for i=1:3
    if i == 1
      str = ['p = [',num2str(p1),';',num2str(p2),';',num2str(p3),']'];
    elseif i == 2
      str = 'a(0) = p';
    elseif i == 3
      str = ['a(0) = [' num2str(a(1)) '; ' num2str(a(2)) '; ', ...
             num2str(a(3)) ']'];
    end
    nnpause(1)
    set(lines(i),...
      'string',str,...
      'color',nndkblue);
  end

  % REPEAT CALCULATION
  i = 1;
  path = [];

  while any(a ~= [1;-1;-1]) & any(a ~= [1;1;-1])
    nnpause(1)

    set(lines(2),...
      'color',nnltgray);

    str = ['a(' num2str(i) ') = satlins(W*a(' num2str(i-1) ')+b)'];
    set(lines(2),...
      'string',str,...
      'color',nndkblue);

    nnpause(1)
    old_a = a;
    a = satlins(W*a+b);
    a = round(a*100)*0.01;

    set(lines(3),...
      'color',nnltgray);

    str = ['a(' num2str(i) ') = [' num2str(a(1)) '; ' num2str(a(2)) '; ', ...
           num2str(a(3)) ']'];
    set(lines(3),...
      'string',str,...
      'color',nndkblue);

    new_path = plot3([a(1) old_a(1)],[a(2) old_a(2)],[a(3) old_a(3)],...
      'color',nndkblue,...
      'erasemode','none',...
      'linewidth',2);
    path = [path new_path];
    i = i + 1;
  end
  p_marks = [p_marks path];

  if (a(2) < 0)
    fruit_str = 'Orange';
    fruit_c = [1 0.5 0];
  else
    fruit_str = 'Apple';
    fruit_c = [1 0 0];
  end

  % SHOW FRUIT
  nnpause(1)
  str = ['Fruit = ' fruit_str];
  set(lines(4),...
    'string',str,...
    'color',nndkblue);

  set(p_mark_ptr,'userdata',p_marks)
  set(fig,'nextplot','new')

%==================================================================
% Clear fruit calculations.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig) & (nargin == 1)

  % GET DATA
  p = get(p_ptr,'userdata');
  H = get(net_ptr,'userdata');
  input_axis = H(1);           % handle to input space axis
  dots = H(2:3);               % handles to orange & apple dots
  frame = H(4:9);              % frame & boundary
  lines_ptr = H(10);
  p_mark_ptr = H(11);          % pointer to input marks

  lines = get(lines_ptr,'userdata');

  % HIDE INPUT LINES
  p_marks = get(p_mark_ptr,'userdata');
  set(p_marks,...
    'color',nnltyell)
  delete(p_marks)
  set(dots(1),...
    'color',[1 0.5 0])
  set(dots(2),...
    'color',[1 0 0])
  set(frame,...
    'color',nndkblue)
  
  % HIDE CALCULATION
  axes(fig_axis)
  set(fig,'nextplot','add')
  set(lines,'color',nnltgray);
  nntxtchk;

  set(fig,'nextplot','new')
end
