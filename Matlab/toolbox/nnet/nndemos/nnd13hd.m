function nnd13hd(cmd,arg1,arg2,arg3)
%NND13HD Hebb with decay demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd13hd';
Fs = 8192;
pause1 = 0.7;
pause2 = 0.1;

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
  lines = H(3:4);          % belt circle lines
  fruit_indicator = H(5);  % fruit entrance indicator
  top_indicator = H(6);    % top exit indicator
  bottom_indicator = H(7); % bottom exit indicator;
  sounds = H(8:15);        % pointers to sounds
  angle_ptr = H(16);       % angle (deg) of lines in conveyer ends
  fruit_ptr = H(17);       % pointer to fruit shape
  arrows = H(21:22);       % handles to arrows
  rb1 = H(23);             % Working radio button
  rb2 = H(24);             % Not working radio button
  cross = H(25);           % Not working cross
  p1_ptr = H(26);          % Input #1
  p2_ptr = H(27);          % Input #2
  a_ptr = H(28);           % Output
  W2_ptr = H(29);          % Weights #2
  p1_box = H(30);
  p1_text = H(31);
  p2_box = H(32);
  p2_text = H(33);
  a_box = H(34);
  a_text = H(35);
  go_button = H(36);
  mode_ptr = H(37);
  W2_box = H(38);
  W2_text = H(39);
  n_box = H(40);
  n_text = H(41);
  mode = get(mode_ptr,'userdata');
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
  fig = nndemof2(me,'DESIGN','Hebb with Decay','','Chapter 13');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % SOUND POINTERS
  wind = uicontrol('visible','off','userdata',nndsnd(3));
  knock = uicontrol('visible','off','userdata',nndsnd(5));
  scan = uicontrol('visible','off','userdata',nndsnd(1));
  classify = uicontrol('visible','off','userdata',nndsnd(4));
  blip = uicontrol('visible','off','userdata',nndsnd(6));
  bloop = uicontrol('visible','off','userdata',nndsnd(7));
  blp = uicontrol('visible','off','userdata',nndsnd(9));
  tribble = uicontrol('visible','off','userdata',nndsnd(8));

  % ICON
  nndicon(13,458,363,'shadow')

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
  
  % SENSOR BOX #1
  x = 140;
  fill(x+[0 40 20],y+[40 40 80],nndkblue,...
    'edgecolor',nnred)
  fill(x+[0 40 40 0],y+[14 14 8 8],nndkblue,...
    'edgecolor',nnred)
  cross = plot(x+[15 25 20 25 15],y+[50 60 55 50 60],...
    'color',nndkblue,...
    'linewidth',3,...
    'erasemode','none');
  
  % SENSOR BOX #2
  x = 200;
  fill(x+[0 40 20],y+[40 40 80],nndkblue,...
    'edgecolor',nnred)
  fill(x+[0 40 40 0],y+[14 14 8 8],nndkblue,...
    'edgecolor',nnred)

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
  top_ind = text(x+25,y+71,'Banana',...
    'color',[0.8 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');
  bottom_ind = text(x+24,y+48,'Other',...
    'color',[0.8 0.8 0],...
    'fontweight','bold',...
    'horiz','center',...
    'erasemode','none');

  % BUTTONS
  go_button = uicontrol(...
    'units','points',...
    'position',[400 165 60 20],...
    'string','Fruit',...
    'callback',[me '(''go'')']);
  uicontrol(...
    'units','points',...
    'position',[400 130 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[400 95 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[400 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % LOWER SEPERATION BAR
  fill([0 0 380 380],130+[0 4 4 0],nndkblue,...
    'edgecolor','none')

  % UPPER SEPERATION BAR
  fill([0 0 380 380],160+[0 4 4 0],nndkblue,...
    'edgecolor','none')
 
  % RADIO BUTTONS
  set(nndtext(20,147,'First Scanner:','left'),...
    'fontsize',12)
  rb1 = uicontrol(...
    'units','points',...
    'position',[140 139 100 20],...
    'string','Working',...
    'style','radio',...
    'value',1,...
    'callback',[me '(''working'')']);
  rb2 = uicontrol(...
    'units','points',...
    'position',[250 139 100 20],...
    'string','Not Working',...
    'style','radio',...
    'callback',[me '(''notworking'')']);

  W1 = 1;
  W2 = 0;
  set(fig,'nextplot','add')
  
  % NETWORK INPUT #1
  x1 = 70;
  y1 = 310;
  dy1 = 55;
  nndtext(x1-10,y1+10,'Banana','right');
  nndtext(x1-10,y1-10,'Shape?','right');
  p1_box = fill(x1+[0 20 20 0 0],y1-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'erasemode','none');
  p1_text = nndtext(x1+10,y1,'?');
  set(p1_text,'erasemode','none');

  % NETWORK INPUT #2
  y3 = y1-2*dy1;
  dy3 = 20;
  nndtext(x1-10,y3+10,'Banana','right');
  nndtext(x1-10,y3-10,'Smell?','right');
  p2_box = fill(x1+[0 20 20 0 0],y3-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'erasemode','none');
  p2_text = nndtext(x1+10,y3,'?');
  set(p2_text,'erasemode','none');

  % NEURON
  x2 = x1+165;
  y2 = y1-dy1;
  sumdist = 50;
  sz = 15;
  plot(x2+[0 0 sumdist],y2+[-25 0 0],'linewidth',2,'color',nnred);
  plot(x2-20+[0 40 40 0 0],y2-45+[0 0 20 20 0],'color',nnred,'linewidth',2);
  plot(x2+[0 0],y2+[-45 -55],'linewidth',2,'color',nnred);
  plot(x2+sumdist+sz+[20 30 0 30 20],y2+[10 0 0 0 -10],'linewidth',2,'color',nnred);
  nndtext(x2+sumdist+sz+45,y2+30,'Banana?');
  nndsicon('sum',x2,y2,sz)
  nndsicon('hardlim',x2+sumdist,y2,sz)
  nndtext(x2,y2-36,'-0.5');
  nndtext(x2,y2-66,'1');
  a_box = fill(x2+sumdist+sz+35+[0 20 20 0 0],y2-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'erasemode','none');
  a_text = nndtext(x2+sumdist+sz+45,y2,'?');
  set(a_text,'erasemode','none');
  
  % NET INPUT
  n_box = fill(x2+5+[0 40 40 0 0],y2+30+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'erasemode','none');
  n_text = nndtext(x2+25,y2+40,'?');
  plot(x2+25+[0 0],y2+[30 0],':','linewidth',2,'color',nnred);
  
  % WEIGHTS #1
  straight = 95;
  plot([x1+20 x1+straight-50],[y1 y1],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y1 y1 y2],'linewidth',2,'color',nnred);
  plot(x1+straight-50+[0 40 40 0 0],y1-10+[0 0 20 20 0],'color',nnred,'linewidth',2);
  nndtext(x1+straight-30,y1,'1');

  % WEIGHTS #2
  straight_dist = 100;
  plot([x1+20 x1+straight-50],[y3 y3],'linewidth',2,'color',nnred);
  plot([x1+straight-10 x1+straight x2-sz],[y3 y3 y2],'linewidth',2,'color',nnred);
  W2_box = fill(x1+straight-50+[0 40 40 0 0],y3-10+[0 0 20 20 0],nnltgray,...
    'edgecolor',nnred,...
    'linewidth',2,...
    'erasemode','none');
  W2_text = nndtext(x1+straight-30,y3,sprintf('%5.2f',W2));

  % INPUT HEADING
  temp = nndtext(x1+10,y1+30,'Inputs');

  % WEIGHT HEADING
  nndtext(x1+straight_dist-35,y1+30,'Weights');

  % SCANNER NAMES
  set(nndtext(160,120,'Banana'),...
    'fontsize',10)
  set(nndtext(160,110,'Shape?'),...
    'fontsize',10)
  set(nndtext(220,120,'Banana'),...
    'fontsize',10)
  set(nndtext(220,110,'Smell?'),...
    'fontsize',10)

  % SAVE WINDOW DATA AND LOCK
  angle_ptr = uicontrol('visible','off','userdata',line_angle);
  fruit_ptr = uicontrol('visible','off','userdata',[]);

  p1_ptr = uicontrol('visible','off','userdata',[]);
  p2_ptr = uicontrol('visible','off','userdata',[]);
  a_ptr = uicontrol('visible','off','userdata',[]);
  W2_ptr = uicontrol('visible','off','userdata',W2);
  W2_ptr = uicontrol('visible','off','userdata',W2);
  mode_ptr = uicontrol('visible','off','userdata',1);

  H = [fig_axis, ...
       desc_text, ...
       line_1 line_2, ...
       fruit_ind top_ind bottom_ind, ...
       wind knock scan classify blip bloop blp tribble, ...
       angle_ptr fruit_ptr 0 0 0, ...
       left_arrow right_arrow,rb1 rb2 cross, ...
       p1_ptr p2_ptr a_ptr W2_ptr,...
       p1_box p1_text p2_box p2_text a_box a_text,...
       go_button mode_ptr W2_box W2_text,...
       n_box n_text];

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
    'Click [Fruit] to send',...
    'a fruit down the belt',...
    'to be recognized.',...
    'Click [Update] to apply',...
    'the Hebb w/decay rule.',...
    '',...
    'Because of weight',...
    'decay the weight will',...
    'never exceed a value',...
    'of 2.0.')
    
%==================================================================
% Respond to fruit.
%
% ME('fruit')
%==================================================================

elseif strcmp(cmd,'go') & (fig) & (nargin == 1) & (mode == 1);

  % GET DATA
  wind = get(sounds(1),'userdata');
  knock = get(sounds(2),'userdata');
  scan = get(sounds(3),'userdata');
  classify = get(sounds(4),'userdata');
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  blp = get(sounds(7),'userdata');
  tribble = get(sounds(8),'userdata');
  angle = get(angle_ptr,'userdata');
  fruit = get(fruit_ptr,'userdata');
  axes(fig_axis);

  % NEW FRUIT
  nnpause(pause1)
  x = 82;
  y = 42;

  % FRUIT ID, COLOR & SHAPE
  
  if (rand > 0.25)
    % BANANA
    fruit_id = 3;
    fruit_x = 4+[8 6 3 1 0 1 3 6 8 6 5 6 8];
    fruit_y = [15 15 13 11 7.5 4 2 0 0 3 7.5 12 15];
    fruit_c = nnyellow;
    p1 = 1;
    p2 = 1;
  elseif (rand > 0.5)
    % ORANGE
    fruit_id = 1;
    fruit_x = [5 0 0 5 10 15 15 10];
    fruit_y = [15 10 5 0 0 5 10 15];
    fruit_c = [1 0.5 0];
    p1 = 0;
    p2 = 0;
  else
    % APPLE
    fruit_id = 2;
    fruit_x = [7.5 5 0 0 5 7.5 10 15 15 10];
    fruit_y = [13 15 10 5 0 2 0 5 10 15];
    fruit_c = [1 0 0];
    p1 = 0;
    p2 = 0;
  end

  % FLASH FRUIT INDICATOR TWICE
  set(fig,'nextplot','add')
  nnsound(blip,Fs);
  set(fruit_indicator,...
    'color',[1 1 1])
  box = plot([10 60 60 10 10],[72 72 88 88 72],...
    'color',[1 1 1],...
    'erasemode','none');

  nnpause(pause2)
  nnsound(bloop,Fs);
  set(fruit_indicator,...
    'color',[0.8 0.8 0])
  set(box,...
    'color',nndkblue)
  delete(box)
  nnpause(pause2)

  set(arrows(1),...
    'facecolor',nnred)
  t1 = clock;
  nnsound(wind,Fs);
  while etime(clock,t1) < 1, end
  nnpause(pause2)
  set(arrows(1),...
    'facecolor',nndkblue)

  set(fruit_indicator,...
    'color',[0.8 0.8 0])

  % CREATE FRUIT
  fruit = fill(x+fruit_x,y+fruit_y,fruit_c,...
    'edgecolor',fruit_c*0.5,...
    'erasemode','none');
  set(fig,'nextplot','new')
  nnsound(knock,Fs);
  nnpause(pause2)

  % MOVE FRUIT TO SENSOR #1
  deg = pi/180;
  for dx=10:10:70
    t1 = clock;
    nnsound(blp,Fs);
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
    while etime(clock,t1) < 0.1, end
  end

  % SCAN FRUIT #1
  nnpause(pause2)
  working = get(rb1,'value');
  set(fig,'nextplot','add')
  if (working)
    h1 = fill(10+[170 130 130 170],[35 35 39 39],[1 1 1],...
      'edgecolor','none',...
      'erasemode','none');
    h2 = fill(10+[170 130 130 170],[41 41 58 58],[1 1 1],...
      'edgecolor','none',...
      'erasemode','none');
    set(fruit,...
     'facecolor',[1 1 1])
    t1 = clock;
    nnsound(scan,Fs);
    while etime(clock,t1) < 1; end
  else
    t1 = clock;
    nnsound(tribble,Fs);
    while etime(clock,t1) < 1, end
    p1 = 0;
  end

  t1 = clock;
  set(p1_box,'facecolor',[1 1 1]);
  set(p1_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(p1_box,'facecolor',nnltgray);
  set(p1_text,'string',num2str(p1),'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  if (working)
    set(h1,'facecolor',nnltgray)
    set(h2,'facecolor',nnltgray)
    delete(h1)
    delete(h2)
    set(fruit,...
      'facecolor',fruit_c)
    set(fig,'nextplot','new')
  end
  nnpause(pause2)

  % MOVE FRUIT TO SENSOR #2
  deg = pi/180;
  for dx=80:10:130
    t1 = clock;
    nnsound(blp,Fs);
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
    while etime(clock,t1) < 0.1, end
  end

  % SCAN FRUIT #2
  nnpause(pause2)
  set(fig,'nextplot','add')
  h1 = fill(70+[170 130 130 170],[35 35 39 39],[1 1 1],...
    'edgecolor','none',...
    'erasemode','none');
  h2 = fill(70+[170 130 130 170],[41 41 58 58],[1 1 1],...
    'edgecolor','none',...
    'erasemode','none');
  set(fruit,...
   'facecolor',[1 1 1])

  t1 = clock;
  nnsound(scan,Fs);
  while etime(clock,t1) < 1, end

  t1 = clock;
  set(p2_box,'facecolor',[1 1 1]);
  set(p2_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(p2_box,'facecolor',nnltgray);
  set(p2_text,'string',num2str(p2),'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  set(h1,'facecolor',nnltgray)
  set(h2,'facecolor',nnltgray)
  delete(h1)
  delete(h2)
  set(fruit,...
    'facecolor',fruit_c)
  set(fig,'nextplot','new')
  nnpause(pause2)

  % CLASSIFY FRUIT
  W2 = get(W2_ptr,'userdata');
  n = p1+W2*p2-0.5;
  a = hardlim(n);
  if (a == 1)
    result = 1;
  else
    result = 2;
  end

  t1 = clock;
  set(n_box,'facecolor',[1 1 1]);
  set(n_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(n_box,'facecolor',nnltgray);
  set(n_text,'string',sprintf('%5.2f',n),'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  t1 = clock;
  set(a_box,'facecolor',[1 1 1]);
  set(a_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(a_box,'facecolor',nnltgray);
  set(a_text,'string',num2str(a),'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  % MOVE DATA FROM NETWORK TO EXIT
  if (result == 1)
    indicator = top_indicator;
    box_x = 84;
  else
    indicator = bottom_indicator;
    box_x = 62;
  end
  set(indicator,...
    'color',[1 1 1])
  axes(fig_axis)
  set(fig,'nextplot','add')
  box = plot([0 62 62 0 0]+314,[0 0 14 14 0]+box_x,...
    'color',[1 1 1],...
    'erasemode','none');

  nnpause(pause2);
  nnsound(bloop,Fs);

  % MOVE FRUIT TO EXIT
  for dx=140:10:200
    t1 = clock;
    nnsound(blp,Fs);
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
    while etime(clock,t1) < 0.1, end
  end

  % REMOVE FRUIT
  nnpause(pause1)
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
  nnpause(pause1)
  nnsound(bloop,Fs);
  set(indicator,...
    'color',[0.8 0.8 0])
  set(box,...
    'color',nndkblue)
  delete(box)
  set(fig,'nextplot','new')

  % CHANGE GO BUTTON
  set(go_button,'string','Update');
  set(mode_ptr,'userdata',2);

  % SAVE DATA
  set(angle_ptr,'userdata',angle);
  set(fruit_ptr,'userdata',fruit);
  set(p1_ptr,'userdata',p1);
  set(p2_ptr,'userdata',p2);
  set(a_ptr,'userdata',a);  

%==================================================================
% Respond to fruit.
%
% ME('update')
%==================================================================

elseif strcmp(cmd,'go') & (fig) & (nargin == 1) & (mode == 2);

  % GET DATA
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');
  p2 = get(p2_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  a = get(a_ptr,'userdata');

  % UPDATE WEIGHT
  W2 = W2 + 0.2*a*p2'-0.1*W2;
  if (W2 >= 10)
    W2_str = '>=10';
  else
    W2_str = sprintf('%5.2f',W2);
  end

  t1 = clock;
  set(W2_box,'facecolor',[1 1 1]);
  set(W2_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(W2_box,'facecolor',nnltgray);
  set(W2_text,'string',W2_str,'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  % CLEAR INPUT AND OUTPUT
  set(p1_text,'color',nnltgray);
  set(p2_text,'color',nnltgray);
  set(a_text,'color',nnltgray);
  set(n_text,'color',nnltgray);
  set(p1_text,'color',nndkblue,'string','?');
  set(p2_text,'color',nndkblue,'string','?');
  set(a_text,'color',nndkblue,'string','?');
  set(n_text,'color',nndkblue,'string','?');
  
  % CHANGE GO BUTTON
  set(go_button,'string','Fruit');
  set(mode_ptr,'userdata',1);

  % SAVE DATA
  set(W2_ptr,'userdata',W2);

%==================================================================
% Clear weights.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig) & (nargin == 1)
  
  % GET DATA
  blip = get(sounds(5),'userdata');
  bloop = get(sounds(6),'userdata');

  % CLEAR WEIGHT
  W2 = 0;

  t1 = clock;
  set(W2_box,'facecolor',[1 1 1]);
  set(W2_text,'color',nndkblue);
  nnsound(blip,Fs);
  while etime(clock,t1) < 1; end
  t1 = clock;
  set(W2_box,'facecolor',nnltgray);
  set(W2_text,'string',sprintf('%5.2f',W2),'color',nndkblue);
  nnsound(bloop,Fs);
  while etime(clock,t1) < 1; end

  % CLEAR INPUT AND OUTPUT
  set(p1_text,'color',nnltgray);
  set(p2_text,'color',nnltgray);
  set(a_text,'color',nnltgray);
  set(n_text,'color',nnltgray);
  set(p1_text,'color',nndkblue,'string','?');
  set(p2_text,'color',nndkblue,'string','?');
  set(a_text,'color',nndkblue,'string','?');
  set(n_text,'color',nndkblue,'string','?');
  
  % CHANGE GO BUTTON
  set(go_button,'string','Fruit');
  set(mode_ptr,'userdata',1);

  % SAVE DATA
  set(W2_ptr,'userdata',W2);

%==================================================================
% "Working" radio button.
%
% ME('working')
%==================================================================

elseif strcmp(cmd,'working') & (fig)

  set(rb1,'value',1);
  set(rb2,'value',0);
  set(cross,'color',nndkblue);

%==================================================================
% "Not Working" radio button.
%
% ME('working')
%==================================================================

elseif strcmp(cmd,'notworking') & (fig)

  set(rb1,'value',0);
  set(rb2,'value',1);
  set(cross,'color',nnred);
end
