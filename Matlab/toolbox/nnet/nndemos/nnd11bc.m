function [ret1,ret2,ret3,ret4]=nnd11bc(cmd,arg1,arg2,arg3,arg4,arg5)
% NND11BC Backpropagation calculation demonstration.
%
%  This demonstration requires the Neural Network Toolbox.
%
%  NND11BC runs this demo.
%
%  NND11BC('set',W1,b1,W2,b2)
%    sets the network's weight and bias values.
%
%  [W1,b1,W2,b2] = NND11BC('get')
%    gets the network's weight and bias values.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd11bc';
max_t = 0.5;
w_max = 10;
p_max = 2;
box_len = 40;
box_x = [0 1 1 0 0]*box_len;
box_y = [-1 -1 1 1 -1]*10;
pause_time = 1;

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
  W1_ptr = H(3);
  b1_ptr = H(4);
  W2_ptr = H(5);
  b2_ptr = H(6);
  p_name = H(7);
  W11_box = H(8);
  W11_text = H(9);
  W11_name = H(10);
  W12_box = H(11);
  W12_text = H(12);
  W12_name= H(13);
  b11_box = H(14);
  b11_text = H(15);
  b11_name = H(16);
  b12_box = H(17);
  b12_text = H(18);
  b12_name = H(19);
  a11_name = H(20);
  a12_name = H(21);
  W21_box = H(22);
  W21_text = H(23);
  W21_name = H(24);
  W22_box = H(25);
  W22_text = H(26);
  W22_name = H(27);
  b2_box = H(28);
  b2_text = H(29);
  b2_name = H(30);
  a2_name = H(31);
  t_name = H(32);
  e_name = H(33);
  vars = H(34+[0:10]);
  vals = H(45+[0:10]);
  fp1_marker = H(56);
  fp2_marker = H(57);
  fp3_marker = H(58);
  bp1_marker = H(59);
  bp2_marker = H(60);
  W1_marker = H(61);
  b1_marker = H(62);
  W2_marker = H(63);
  b2_marker = H(64);
  p_marker = H(65);
  t_marker = H(66);
  state_ptr = H(67);
  p_ptr = H(68);
  a1_ptr = H(69);
  a2_ptr = H(70);
  e_ptr = H(71);
  s1_ptr = H(72);
  s2_ptr = H(73);
  t_ptr = H(74);
  go_button = H(75);
  s11_name = H(76);
  s12_name = H(77);
  s2_name = H(78);
  blip_ptr = H(79);
  bloop_ptr = H(80);
  blp_ptr = H(81);
  state1 = H(82);
  state2 = H(83);
  state3 = H(84);
  state4 = H(85);
  go_box = H(86);
  last_text = H(87);
  p_edit = H(88);

  state = get(state_ptr,'userdata');
  blip = get(blip_ptr,'userdata');
  bloop = get(bloop_ptr,'userdata');
  blp = get(blp_ptr,'userdata');
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
  W1 = [-0.27; -0.41];
  b1 = [-0.48; -0.13];
  W2 = [0.09 -0.17];
  b2 = [0.48];

%%%%%%%% Copied from NNDEMOF2

s2 = 'DESIGN';
s3 = 'Backpropagation Calculation';
s4 = '';
s5 = 'Chapter 11';

fig = nnbg(me);
set(fig,'nextplot','add')
H = get(fig,'userdata');
h1 = H(1);
text(25,380,'Neural Network', ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontangle','italic', ...
  'fontweight','bold');
text(135,380,s2, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontweight','bold');
text(415,380,s3,...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',16, ...
  'fontweight','bold',...
  'HorizontalAlignment','right');
nndrwlin([0 415],[365 365],4,nndkblue);
h2 = text(390,315,'',...
  'color',nnblack, ...
  'fontname','helvetica', ...
  'fontsize',10);
text1 = h2;
for i=1:30
  text2 = text(390,315-6*i,'',...
    'color',nnblack, ...
    'fontname','helvetica', ...
    'fontsize',10);
  set(text1,'userdata',text2);
  text1 = text2;
end
set(text1,'userdata','end');
text(410,54,s4, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
text(410,38,s5, ...
  'color',nnblack, ...
  'fontname','times', ...
  'fontsize',12, ...
  'fontweight','bold');
nndrwlin([410 501],[24 24],4,nndkblue);
set(fig,'userdata',[h1 h2])
set(fig,'color',nndkgray,'color',nnltgray)

%%%%%%%%

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(11,458,363,'shadow')

  % NETWORK POSITIONS
  x1 = 30;     % input
  x2 = x1+85;  % 1st layer sum
  x3 = x2+70;  % 1st layer transfer function
  x4 = x3+125; % 2nd layer sum
  x5 = x4+55;  % 2nd layer transfer function
  x6 = x5+50;  % output
  y1 = 305;    % top neuron
  y2 = y1-20;  % input & output neuron
  y3 = y1-40;  % bottom neuron
  sz = 15;     % size of icons
  wx = 50;     % weight horizontal offset (from 1st layer)
  wy = 40;     % weight vertical offset (from middle)

  % NETWORK INPUT
  p_name = nndtext(x1-10,y2,'p');
  set(p_name,'fontsize',10);

  % TOP NEURON: WEIGHT
  plot([x1 x1+20],[y2 y1],'linewidth',2,'color',nnred);
  W11_box = fill(x1+20+box_x,y1+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  W11_text = nndtext(x1+20+box_len/2,y1,sprintf('%5.3f',W1(1)));
  set(W11_text,'fontsize',10);
  plot([x1+20+box_len x2-sz],[y1 y1],'linewidth',2,'color',nnred);
  W11_name = nndtext(x2-wx,y2+wy,'W1(1,1)');
  set(W11_name,'fontsize',10);

  % TOP NEURON: BIAS
  plot([x2 x2 x3],[y1+sz*2 y1 y1],'linewidth',2,'color',nnred);
  b11_box = fill(x2-box_len/2+box_x,y1+sz*2+10+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  b11_text = nndtext(x2,y1+sz*2+10,sprintf('%5.3f',b1(1)));
  set(b11_text,'fontsize',10);
  b11_name = nndtext(x2+25,y1+sz*2+10,'b1(1)','left');
  set(b11_name,'fontsize',10);

  % TOP NEURON: BODY
  nndsicon('sum',x2,y1,sz)
  n11_name = nndtext(x2+sz+20,y1+10,'n1(1)');
  set(n11_name,'fontsize',10);
  nndsicon('logsig',x3,y1,sz)
  s11_name = nndtext(x2+sz+75,y1+40,'s1(1)');
  set(s11_name,'fontsize',10);
  plot(x2+sz+[30 60],y1+[18 32],'--',...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none')
  a11_name = nndtext(x3+sz+20,y1+10,'a1(1)');
  set(a11_name,'fontsize',10);

  % BOTTOM NEURON: WEIGHT
  plot([x1 x1+20],[y2 y3],'linewidth',2,'color',nnred);
  W12_box = fill(x1+20+box_x,y3+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  W12_text = nndtext(x1+20+box_len/2,y3,sprintf('%5.3f',W1(2)));
  set(W12_text,'fontsize',10);
  plot([x1+20+box_len x2-sz],[y3 y3],'linewidth',2,'color',nnred);
  W12_name = nndtext(x2-wx,y2-wy,'W1(2,1)');
  set(W12_name,'fontsize',10);

  % BOTTOM NEURON: BIAS
  plot([x2 x2 x3],[y3-sz*2 y3 y3],'linewidth',2,'color',nnred);
  b12_box = fill(x2-box_len/2+box_x,y3-sz*2-10+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  b12_text = nndtext(x2,y3-sz*2-10,sprintf('%5.3f',b1(2)));
  set(b12_text,'fontsize',10);
  b12_name = nndtext(x2+25,y3-sz*2-10,'b1(2)','left');
  set(b12_name,'fontsize',10);

  % BOTTOM NEURON: BODY
  nndsicon('sum',x2,y3,sz)
  n12_name = nndtext(x2+sz+20,y3-10,'n1(2)');
  set(n12_name,'fontsize',10);
  nndsicon('logsig',x3,y3,sz)
  s12_name = nndtext(x2+sz+75,y3-40,'s1(2)');
  set(s12_name,'fontsize',10);
  plot(x2+sz+[30 60],y3-[18 32],'--',...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none')
  a12_name = nndtext(x3+sz+20,y3-10,'a1(2)');
  set(a12_name,'fontsize',10);

  % OUTPUT NEURON: TOP WEIGHT
  plot([x3+sz+1 x3+sz+40],[y1 y1],'linewidth',2,'color',nnred);
  W21_box = fill(x3+sz+40+box_x,y1+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  W21_text = nndtext(x3+sz+40+box_len/2,y1,sprintf('%5.3f',W2(1)));
  set(W21_text,'fontsize',10);
  plot([x3+sz+40+box_len x4-10],[y1 y2],'linewidth',2,'color',nnred);
  W21_name = nndtext(x3+4+wx+20,y2+wy,'W2(1,1)');
  set(W21_name,'fontsize',10);

  % OUTPUT NEURON: BOTTOM WEIGHT
  plot([x3+sz+1 x3+sz+40],[y3 y3],'linewidth',2,'color',nnred);
  W22_box = fill(x3+sz+40+box_x,y3+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  W22_text = nndtext(x3+sz+40+box_len/2,y3,sprintf('%5.3f',W2(2)));
  set(W22_text,'fontsize',10);
  plot([x3+sz+40+box_len x4-10],[y3 y2],'linewidth',2,'color',nnred);
  W22_name = nndtext(x3+4+wx+20,y2-wy,'W2(1,2)');
  set(W22_name,'fontsize',10);

  % OUTPUT NEURON: BIAS
  plot([x4 x4 x6],[y2-sz*2 y2 y2],'linewidth',2,'color',nnred);
  b2_box = fill(x4-box_len/2+box_x,y2-sz*2-10+box_y,nnltgray,...
    'linewidth',2,...
    'edgecolor',nnred,...
    'erasemode','none');
  b2_text = nndtext(x4,y2-sz*2-10,sprintf('%5.3f',b2));
  set(b2_text,'fontsize',10);
  b2_name = nndtext(x4+25,y2-sz*2-10,'b2','left');
  set(b2_name,'fontsize',10);

  % OUTPUT
  plot([x6-10 x6 x6-10],[y2-7 y2 y2+7],'linewidth',2,'color',nnred);
  nndsicon('sum',x4,y2,sz)
  temp = nndtext(x4+sz+13,y2+10,'n2');
  set(temp,'fontsize',10);
  tf_icon = nndsicon('purelin',x5,y2,sz);
  s2_name = nndtext(x4+sz+60,y2+40,'s2');
  set(s2_name,'fontsize',10);
  plot(x4+sz+[20 50],y2+[18 32],'--',...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none')

  a2_name = nndtext(x5+sz+5,y2+10,'a2','left');
  set(a2_name,'fontsize',10);

  % DIFFERENCE
  angle = [0:5:360]*pi/180;
  circle_x = cos(angle)*15;
  circle_y = sin(angle)*15;
  fill(x6+sz+circle_x,y2+circle_y,nndkblue,...
    'edgecolor',nnred,...
    'linewidth',1);
  plot(x6+sz-[10 5],[y2 y2],...
    'color',nnyellow,...
    'linewidth',2)
  plot(x6+sz+1+4*[-1 1 NaN 0 0],y2-8+4*[0 0 NaN -1 1],...
    'color',nnyellow,...
    'linewidth',2)

  % ERROR
  plot(30+2*sz+[x6-10 x6 x6-10],[y2-7 y2 y2+7],'linewidth',2,'color',nnred);
  plot(2*sz+x6+[1 30],[y2 y2],'linewidth',2,'color',nnred);
  e_name = nndtext(x6+2*sz+5,y2+10,'e','left');
  set(e_name,'fontsize',10);

  % TARGET
  plot(x6+sz+8*[-1 0 1],y2-sz-[10 0 10],'linewidth',2,'color',nnred);
  plot(x6+sz+[0 0],y2-sz-[0 20],'linewidth',2,'color',nnred);
  t_name = nndtext(x6+sz,y2-sz-30,'t');

  % SEPERATION BAR
  fill([0 0 480 480],193+[0 4 4 0],nndkblue,...
    'edgecolor','none')

  % EQUATIONS
  y = 181;
  dy = 17;
  init_str = str2mat('p','t','a1','a2','e','s2','s1','W1','b1','W2','b2');
  vars = zeros(1,11);
  vals = vars;
  for i=1:11
    yy = y-dy*(i-1);
    vars(i) = nndtext(140,yy,deblank(init_str(i,:)),'right');
    set(vars(i),'fontsize',10);
    eq_sign = nndtext(148,yy,'=');
    set(eq_sign,'fontsize',10);
  if i==1
    vals(i) = nndtext(1000,1000,' ','left');
  else
      vals(i) = nndtext(156,yy,'?','left');
  end
    set(vals(i),'fontsize',10);
  end
  nndtext(15,y,'Input:','left');
  state1 = nndtext(15,y-dy,'Target:','left');
  state2 = nndtext(15,y-2*dy,'Simulate:','left');
  state3 = nndtext(15,y-5*dy,'Backpropagate:','left');
  state4 = nndtext(15,y-7*dy,'Update:','left');
  p_edit = uicontrol(...
    'units','points',...
  'position',[156 173 60 18],...
    'style','edit',...
  'string','1.0',...
    'callback',[me '(''p'')']);

  % MARKERS
  y = 204;
  wdth = 3;
  p_marker = plot(x1+[-10 -5 0],y+[-5 5 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  t_marker = plot(x6+sz+[-5 0 5],y+[-5 5 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  fp1_marker = plot([x1 (x3+sz-[0 10 0 10])],y+[0 0 5 0 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  fp2_marker = plot([x3+sz+5 (x5+sz-[0 10 0 10])],y+[0 0 5 0 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  fp3_marker = plot([x5+sz+5 (x6+sz*2-[0 10 0 10])],y+[0 0 5 0 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  bp1_marker = plot([x6+sz*2 (x5-sz+[0 10 0 10])],y+[0 0 5 0 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  bp2_marker = plot([x5-sz-5 (x3-sz+[0 10 0 10])],y+[0 0 5 0 -5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  W1_marker = plot(x1+20+[0 0 box_len box_len],y+[5 -5 -5 5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  b1_marker = plot(x2-box_len/2+[0 0 box_len box_len],y+[5 -5 -5 5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  W2_marker = plot(x3+sz+40+[0 0 box_len box_len],y+[5 -5 -5 5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');
  b2_marker = plot(x4-box_len/2+[0 0 box_len box_len],y+[5 -5 -5 5],...
    'color',nnltgray,...
    'linewidth',wdth,...
    'erasemode','none');

  % LAST ERROR
  temp = nndtext(430,220,'Last Error:','right');
  set(temp,'fontsize',10);
  last_text = nndtext(440,220,'?.??','left');
  set(last_text,'fontsize',10);

  % BUTTONS
  go_box = plot(409+[0 1 1 0 0]*64,157+[0 0 1 1 0]*24,...
    'color',nnred,...
    'linewidth',4,...
    'erasemode','none');
  go_button = uicontrol(...
    'units','points',...
    'position',[410 160 60 20],...
    'string','Target',...
    'callback',[me '(''go'')']);
  uicontrol(...
    'units','points',...
    'position',[410 130 60 20],...
    'string','Reset',...
    'callback',[me '(''reset'')']);
  uicontrol(...
    'units','points',...
    'position',[410 105 60 20],...
    'string','Random',...
    'callback',[me '(''random'')'])
  uicontrol(...
    'units','points',...
    'position',[410 80 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 55 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % DATA POINTERS
  W1_ptr = uicontrol('visible','off','userdata',W1);
  b1_ptr = uicontrol('visible','off','userdata',b1);
  W2_ptr = uicontrol('visible','off','userdata',W2);
  b2_ptr = uicontrol('visible','off','userdata',b2);
  state_ptr = uicontrol('visible','off','userdata',1);
  p_ptr = uicontrol('visible','off','userdata',1);
  a1_ptr = uicontrol('visible','off','userdata',[]);
  a2_ptr = uicontrol('visible','off','userdata',[]);
  e_ptr = uicontrol('visible','off','userdata',[]);
  s1_ptr = uicontrol('visible','off','userdata',[]);
  s2_ptr = uicontrol('visible','off','userdata',[]);
  t_ptr = uicontrol('visible','off','userdata',[]);
  blip_ptr = uicontrol('visible','off','userdata',nndsnd(6));
  bloop_ptr = uicontrol('visible','off','userdata',nndsnd(7));
  blp_ptr = uicontrol('visible','off','userdata',nndsnd(9));

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text,...
       W1_ptr b1_ptr W2_ptr b2_ptr,...
       p_name W11_box W11_text W11_name W12_box W12_text W12_name,...
       b11_box b11_text b11_name b12_box b12_text b12_name,...
       a11_name a12_name W21_box W21_text W21_name,...
       W22_box W22_text W22_name b2_box b2_text b2_name,...
       a2_name t_name e_name,...
       vars vals,...
       fp1_marker fp2_marker fp3_marker bp1_marker bp2_marker,...
       W1_marker b1_marker W2_marker b2_marker p_marker t_marker,...
       state_ptr, ...
       p_ptr a1_ptr a2_ptr e_ptr s1_ptr s2_ptr t_ptr,...
       go_button,...
       s11_name s12_name s2_name,...
       blip_ptr bloop_ptr blp_ptr,...
       state1 state2 state3 state4,...
       go_box last_text,...
       p_edit];

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  % eval(me,'instr');

  % LOCK WINDOW
  set(fig,'nextplot','new','color',nnltgray);

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & (fig)
  nnsettxt(desc_text,...
    'Alter network weights',...
    'and biases by dragging',...
    'the triangular shaped',...
    'indicators.',...
    '',...
    'Drag the vertical line',...
    'in the graph below to',...
    'find the output for a',...
    'particular input.',...
    '',...
    'Click on [Random] to',...
    'set each parameter',...
    'to a random value.')
    
%==================================================================
% Change input.
%
% ME('p')
%==================================================================

elseif strcmp(cmd,'p') & (fig)

  p = str2num(get(p_edit,'string'));
  set(p_ptr,'userdata',p);
  set(p_edit,'string',num2str(p));

%==================================================================
% Reset parameters.
%
% ME('reset')
%==================================================================

elseif strcmp(cmd,'reset') & (fig)

  W1 = [-0.27; -0.41];
  b1 = [-0.48; -0.13];
  W2 = [0.09 -0.17];
  b2 = [0.48];

  set(W1_ptr,'userdata',W1);
  set(b1_ptr,'userdata',b1);
  set(W2_ptr,'userdata',W2);
  set(b2_ptr,'userdata',b2);

  set(W11_name,'color',nnwhite);
  set(W12_name,'color',nnwhite);
  set(b11_name,'color',nnwhite);
  set(b12_name,'color',nnwhite);
  set(W21_name,'color',nnwhite);
  set(W22_name,'color',nnwhite);
  set(b2_name,'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnwhite);
  set(W12_box,'facecolor',nnwhite);
  set(b11_box,'facecolor',nnwhite);
  set(b12_box,'facecolor',nnwhite);
  set(W21_box,'facecolor',nnwhite);
  set(W22_box,'facecolor',nnwhite);
  set(b2_box,'facecolor',nnwhite);
  set(W11_text,'color',nndkblue);
  set(W12_text,'color',nndkblue);
  set(b11_text,'color',nndkblue);
  set(b12_text,'color',nndkblue);
  set(W21_text,'color',nndkblue);
  set(W22_text,'color',nndkblue);
  set(b2_text,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnltgray);
  set(W12_box,'facecolor',nnltgray);
  set(b11_box,'facecolor',nnltgray);
  set(b12_box,'facecolor',nnltgray);
  set(W21_box,'facecolor',nnltgray);
  set(W22_box,'facecolor',nnltgray);
  set(b2_box,'facecolor',nnltgray);
  set(W11_text,'string',sprintf('%5.3f',W1(1)));
  set(W12_text,'string',sprintf('%5.3f',W1(2)));
  set(b11_text,'string',sprintf('%5.3f',b1(1)));
  set(b12_text,'string',sprintf('%5.3f',b1(2)));
  set(W21_text,'string',sprintf('%5.3f',W2(1)));
  set(W22_text,'string',sprintf('%5.3f',W2(2)));
  set(b2_text,'string',sprintf('%5.3f',b2));
  set(W11_name,'color',nndkblue);
  set(W12_name,'color',nndkblue);
  set(b11_name,'color',nndkblue);
  set(b12_name,'color',nndkblue);
  set(W21_name,'color',nndkblue);
  set(W22_name,'color',nndkblue);
  set(b2_name,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(state_ptr,'userdata',1);
  set(go_button,'string','Target');
  for i=1:11
    set(vals(i),'color',nnltgray);
    set(vals(i),'string','?');
    set(vals(i),'color',nndkblue);
  end
  nnsound(bloop);

  set(last_text,'color',nnltgray);
  set(last_text,'string','?.??');
  set(last_text,'color',nndkblue);

%==================================================================
% Randomize parameters.
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random') & (fig)

  W1 = rands(2,1);
  b1 = rands(2,1);
  W2 = rands(1,2);
  b2 = rands(1,1);

  set(W1_ptr,'userdata',W1);
  set(b1_ptr,'userdata',b1);
  set(W2_ptr,'userdata',W2);
  set(b2_ptr,'userdata',b2);

  set(W11_name,'color',nnwhite);
  set(W12_name,'color',nnwhite);
  set(b11_name,'color',nnwhite);
  set(b12_name,'color',nnwhite);
  set(W21_name,'color',nnwhite);
  set(W22_name,'color',nnwhite);
  set(b2_name,'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnwhite);
  set(W12_box,'facecolor',nnwhite);
  set(b11_box,'facecolor',nnwhite);
  set(b12_box,'facecolor',nnwhite);
  set(W21_box,'facecolor',nnwhite);
  set(W22_box,'facecolor',nnwhite);
  set(b2_box,'facecolor',nnwhite);
  set(W11_text,'color',nndkblue);
  set(W12_text,'color',nndkblue);
  set(b11_text,'color',nndkblue);
  set(b12_text,'color',nndkblue);
  set(W21_text,'color',nndkblue);
  set(W22_text,'color',nndkblue);
  set(b2_text,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnltgray);
  set(W12_box,'facecolor',nnltgray);
  set(b11_box,'facecolor',nnltgray);
  set(b12_box,'facecolor',nnltgray);
  set(W21_box,'facecolor',nnltgray);
  set(W22_box,'facecolor',nnltgray);
  set(b2_box,'facecolor',nnltgray);
  set(W11_text,'string',sprintf('%5.3f',W1(1)));
  set(W12_text,'string',sprintf('%5.3f',W1(2)));
  set(b11_text,'string',sprintf('%5.3f',b1(1)));
  set(b12_text,'string',sprintf('%5.3f',b1(2)));
  set(W21_text,'string',sprintf('%5.3f',W2(1)));
  set(W22_text,'string',sprintf('%5.3f',W2(2)));
  set(b2_text,'string',sprintf('%5.3f',b2));
  set(W11_name,'color',nndkblue);
  set(W12_name,'color',nndkblue);
  set(b11_name,'color',nndkblue);
  set(b12_name,'color',nndkblue);
  set(W21_name,'color',nndkblue);
  set(W22_name,'color',nndkblue);
  set(b2_name,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(state_ptr,'userdata',1);
  set(go_button,'string','Target');
  for i=1:11
    set(vals(i),'color',nnltgray);
    set(vals(i),'string','?');
    set(vals(i),'color',nndkblue);
  end
  nnsound(bloop);

  set(last_text,'color',nnltgray);
  set(last_text,'string','?.??');
  set(last_text,'color',nndkblue);

%==================================================================
% Set parameters.
%
% ME('set',W1,b1,W2,b2,f2)
%==================================================================

elseif strcmp(cmd,'set') & (fig) & (nargin == 6)

  % CHECK SIZES
  if all(size(arg1) == [2 1]) & ...
     all(size(arg2) == [2 1]) & ...
     all(size(arg3) == [1 2]) & ...
     all(size(arg4) == [1 1])

    W1 = arg1;
    b1 = arg2;
    W2 = arg3;
    b2 = arg4;

    set(W1_ptr,'userdata',W1);
    set(b1_ptr,'userdata',b1);
    set(W2_ptr,'userdata',W2);
    set(b2_ptr,'userdata',b2);

  set(W11_name,'color',nnwhite);
  set(W12_name,'color',nnwhite);
  set(b11_name,'color',nnwhite);
  set(b12_name,'color',nnwhite);
  set(W21_name,'color',nnwhite);
  set(W22_name,'color',nnwhite);
  set(b2_name,'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnwhite);
  set(W12_box,'facecolor',nnwhite);
  set(b11_box,'facecolor',nnwhite);
  set(b12_box,'facecolor',nnwhite);
  set(W21_box,'facecolor',nnwhite);
  set(W22_box,'facecolor',nnwhite);
  set(b2_box,'facecolor',nnwhite);
  set(W11_text,'color',nndkblue);
  set(W12_text,'color',nndkblue);
  set(b11_text,'color',nndkblue);
  set(b12_text,'color',nndkblue);
  set(W21_text,'color',nndkblue);
  set(W22_text,'color',nndkblue);
  set(b2_text,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnltgray);
  set(W12_box,'facecolor',nnltgray);
  set(b11_box,'facecolor',nnltgray);
  set(b12_box,'facecolor',nnltgray);
  set(W21_box,'facecolor',nnltgray);
  set(W22_box,'facecolor',nnltgray);
  set(b2_box,'facecolor',nnltgray);
  set(W11_text,'string',sprintf('%5.3f',W1(1)));
  set(W12_text,'string',sprintf('%5.3f',W1(2)));
  set(b11_text,'string',sprintf('%5.3f',b1(1)));
  set(b12_text,'string',sprintf('%5.3f',b1(2)));
  set(W21_text,'string',sprintf('%5.3f',W2(1)));
  set(W22_text,'string',sprintf('%5.3f',W2(2)));
  set(b2_text,'string',sprintf('%5.3f',b2));
  set(W11_name,'color',nndkblue);
  set(W12_name,'color',nndkblue);
  set(b11_name,'color',nndkblue);
  set(b12_name,'color',nndkblue);
  set(W21_name,'color',nndkblue);
  set(W22_name,'color',nndkblue);
  set(b2_name,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(state_ptr,'userdata',1);
  set(go_button,'string','Target');
  for i=1:11
    set(vals(i),'color',nnltgray);
    set(vals(i),'string','?');
    set(vals(i),'color',nndkblue);
  end
  nnsound(bloop);

  set(last_text,'color',nnltgray);
  set(last_text,'string','?.??');
  set(last_text,'color',nndkblue);

  end

%==================================================================
% Get parameters.
%
% [W1,b1,W2,b2,f2] = ME('get')
%==================================================================

elseif strcmp(cmd,'get') & (fig)

  % GET DATA
  ret1 = get(W1_ptr,'userdata');
  ret2 = get(b1_ptr,'userdata');
  ret3 = get(W2_ptr,'userdata');
  ret4 = get(b2_ptr,'userdata');

%==================================================================
% Simulate network.
%
% [W1,b1,W2,b2,f2] = ME('go')
%==================================================================

elseif strcmp(cmd,'go') & (fig)

  % TARGET
  % ======

  set(go_box,'color',nnltgray);

  if (state == 1)

  % P
  p = get(p_ptr,'userdata');

  set(state1,'color',nngreen);
  set(vars(2),'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time)

  % T
  t = 1+sin(pi/4*p);
  set(t_name,'color',nnwhite);
  set(t_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = '1+sin(p*pi/4)';
  set(vals(2),'color',nnltgray);
  set(vals(2),'string',str);
  set(vals(2),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  str = sprintf('1+sin(p*pi/4) = %5.3f',t);
  set(vals(2),'color',nnltgray);
  set(vals(2),'string',str);
  set(vals(2),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(vars(2),'color',nndkblue);
  set(t_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  set(state1,'color',nndkblue);
  set(p_marker,'color',nnltgray);
  set(t_marker,'color',nnltgray);
  nnsound(blp);
  nnpause(pause_time)

  set(state_ptr,'userdata',2);
  set(go_button,'string','Simulate');
  set(p_ptr,'userdata',p);
  set(t_ptr,'userdata',t);

  % SIMULATE
  % ========

  elseif (state == 2)

  p = get(p_ptr,'userdata');
  t = get(t_ptr,'userdata');
  W1 = get(W1_ptr,'userdata');
  b1 = get(b1_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  b2 = get(b2_ptr,'userdata');

  % A1
  a1 = logsig(W1*p+b1);
  set(state2,'color',nngreen);
  set(vars(3),'color',nnwhite);
  set(vars(4),'color',nnwhite);
  set(vars(5),'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time)

  set(a11_name,'color',nnwhite);
  set(a12_name,'color',nnwhite);
  set(fp1_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'logsig(W1*p+b1)';
  set(vals(3),'color',nnltgray);
  set(vals(3),'string',str);
  set(vals(3),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  str = sprintf('logsig(W1*p+b1) = [%5.3f; %5.3f]',a1(1),a1(2));
  set(vals(3),'color',nnltgray);
  set(vals(3),'string',str);
  set(vals(3),'color',nndkblue);
  nnsound(blp);
  nnpause(1);

  set(a11_name,'color',nndkblue);
  set(a12_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % A2
  a2 = W2*a1+b2;
  set(a2_name,'color',nnwhite);
  set(fp2_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'purelin(W2*a1+b2)';
  set(vals(4),'color',nnltgray);
  set(vals(4),'string',str);
  set(vals(4),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  str = sprintf('purelin(W2*a1+b2) = %5.3f',a2);
  set(vals(4),'color',nnltgray);
  set(vals(4),'string',str);
  set(vals(4),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(a2_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % E
  e = t-a2;
  set(e_name,'color',nnwhite);
  set(fp3_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 't-a2';
  set(vals(5),'color',nnltgray);
  set(vals(5),'string',str);
  set(vals(5),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('t-a2 = %5.3f',e);
  set(vals(5),'color',nnltgray);
  set(vals(5),'string',str);
  set(vals(5),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(e_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  set(vars(3),'color',nndkblue);
  set(vars(4),'color',nndkblue);
  set(vars(5),'color',nndkblue);
  set(fp1_marker,'color',nnltgray);
  set(fp2_marker,'color',nnltgray);
  set(fp3_marker,'color',nnltgray);
  set(state2,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(state_ptr,'userdata',3);
  set(go_button,'string','Backprop');
  set(a1_ptr,'userdata',a1);
  set(a2_ptr,'userdata',a2);
  set(e_ptr,'userdata',e);

  % BACKPROPAGATE
  % =============

  elseif (state == 3)

  a1 = get(a1_ptr,'userdata');
  a2 = get(a2_ptr,'userdata');
  e = get(e_ptr,'userdata');
  W1 = get(W1_ptr,'userdata');
  b1 = get(b1_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  b2 = get(b2_ptr,'userdata');

  % S2
  s2 = -2*e;
  set(state3,'color',nngreen);
  set(vars(6),'color',nnwhite);
  set(vars(7),'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time)

  set(s2_name,'color',nnwhite);
  set(bp1_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = '-2*dpurelin(n2)/dn2*e';
  set(vals(6),'color',nnltgray);
  set(vals(6),'string',str);
  set(vals(6),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('-2*dpurelin(n2)/dn2*e = %5.3f',s2);
  set(vals(6),'color',nnltgray);
  set(vals(6),'string',str);
  set(vals(6),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(s2_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % S1
  s1 = (1-a1).*a1.*(W2'*s2);
  set(s11_name,'color',nnwhite);
  set(s12_name,'color',nnwhite);
  set(bp2_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'dlogsig(n1)/dn1*W2''*s2';
  set(vals(7),'color',nnltgray);
  set(vals(7),'string',str);
  set(vals(7),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('dlogsig(n1)/dn1*W2''*s2 = [%5.3f;%5.3f]',...
    s1(1),s1(2));
  set(vals(7),'color',nnltgray);
  set(vals(7),'string',str);
  set(vals(7),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(s11_name,'color',nndkblue);
  set(s12_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  set(vars(6),'color',nndkblue);
  set(vars(7),'color',nndkblue);
  set(bp1_marker,'color',nnltgray);
  set(bp2_marker,'color',nnltgray);
  set(state3,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(state_ptr,'userdata',4);
  set(go_button,'string','Update');
  set(s1_ptr,'userdata',s1);
  set(s2_ptr,'userdata',s2);

  % UPDATE
  % ======

  elseif (state == 4)

  p = get(p_ptr,'userdata');
  a1 = get(a1_ptr,'userdata');
  a2 = get(a2_ptr,'userdata');
  e = get(e_ptr,'userdata');
  W1 = get(W1_ptr,'userdata');
  b1 = get(b1_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  b2 = get(b2_ptr,'userdata');
  s1 = get(s1_ptr,'userdata');
  s2 = get(s2_ptr,'userdata');

  lr = 0.1;

  % W1
  W1 = W1-lr*s1*p';
  set(state4,'color',nngreen);
  set(vars(8),'color',nnwhite);
  set(vars(9),'color',nnwhite);
  set(vars(10),'color',nnwhite);
  set(vars(11),'color',nnwhite);

  nnsound(blip);
  nnpause(pause_time)
  set(W11_name,'color',nnwhite);
  set(W12_name,'color',nnwhite);
  set(W1_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'W1-lr*s1*p''';
  set(vals(8),'color',nnltgray);
  set(vals(8),'string',str);
  set(vals(8),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('W1-lr*s1*p'' = [%5.3f;%5.3f]',...
    W1(1),W1(2));
  set(vals(8),'color',nnltgray);
  set(vals(8),'string',str);
  set(vals(8),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(W11_name,'color',nndkblue);
  set(W12_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % b1
  b1 = b1-lr*s1;
  set(b11_name,'color',nnwhite);
  set(b12_name,'color',nnwhite);
  set(b1_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'b1-lr*s1';
  set(vals(9),'color',nnltgray);
  set(vals(9),'string',str);
  set(vals(9),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('b1-lr*s1 = [%5.3f;%5.3f]',...
    b1(1),b1(2));
  set(vals(9),'color',nnltgray);
  set(vals(9),'string',str);
  set(vals(9),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(b11_name,'color',nndkblue);
  set(b12_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % W2
  W2 = W2-lr*s2*a1';
  set(W21_name,'color',nnwhite);
  set(W22_name,'color',nnwhite);
  set(W2_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'W2-lr*s2*a1''';
  set(vals(10),'color',nnltgray);
  set(vals(10),'string',str);
  set(vals(10),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('W2-lr*s2*a1'' = [%5.3f;%5.3f]',...
    W2(1),W2(2));
  set(vals(10),'color',nnltgray);
  set(vals(10),'string',str);
  set(vals(10),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(W21_name,'color',nndkblue);
  set(W22_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  % b2
  b2 = b2-lr*s2;
  set(b2_name,'color',nnwhite);
  set(b2_marker,'color',nngreen);
  nnsound(blip);
  nnpause(pause_time)

  str = 'b2-lr*s2';
  set(vals(11),'color',nnltgray);
  set(vals(11),'string',str);
  set(vals(11),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  str = sprintf('b2-lr*s2 = %5.3f',b2);
  set(vals(11),'color',nnltgray);
  set(vals(11),'string',str);
  set(vals(11),'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(b2_name,'color',nndkblue);
  nnsound(bloop);
  nnpause(pause_time)

  set(vars(8),'color',nndkblue);
  set(vars(9),'color',nndkblue);
  set(vars(10),'color',nndkblue);
  set(vars(11),'color',nndkblue);
  set(W1_marker,'color',nnltgray);
  set(b1_marker,'color',nnltgray);
  set(W2_marker,'color',nnltgray);
  set(b2_marker,'color',nnltgray);
  set(state4,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time)

  set(state_ptr,'userdata',5);
  set(go_button,'string','Continue');
  set(W1_ptr,'userdata',W1);
  set(b1_ptr,'userdata',b1);
  set(W2_ptr,'userdata',W2);
  set(b2_ptr,'userdata',b2);

  % CONTINUE
  % ========

  elseif (state == 5)

  W1 = get(W1_ptr,'userdata');
  b1 = get(b1_ptr,'userdata');
  W2 = get(W2_ptr,'userdata');
  b2 = get(b2_ptr,'userdata');
  e = get(e_ptr,'userdata');

  set(W11_name,'color',nnwhite);
  set(W12_name,'color',nnwhite);
  set(b11_name,'color',nnwhite);
  set(b12_name,'color',nnwhite);
  set(W21_name,'color',nnwhite);
  set(W22_name,'color',nnwhite);
  set(b2_name,'color',nnwhite);
  nnsound(blip);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnwhite);
  set(W12_box,'facecolor',nnwhite);
  set(b11_box,'facecolor',nnwhite);
  set(b12_box,'facecolor',nnwhite);
  set(W21_box,'facecolor',nnwhite);
  set(W22_box,'facecolor',nnwhite);
  set(b2_box,'facecolor',nnwhite);
  set(W11_text,'color',nndkblue);
  set(W12_text,'color',nndkblue);
  set(b11_text,'color',nndkblue);
  set(b12_text,'color',nndkblue);
  set(W21_text,'color',nndkblue);
  set(W22_text,'color',nndkblue);
  set(b2_text,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(W11_box,'facecolor',nnltgray);
  set(W12_box,'facecolor',nnltgray);
  set(b11_box,'facecolor',nnltgray);
  set(b12_box,'facecolor',nnltgray);
  set(W21_box,'facecolor',nnltgray);
  set(W22_box,'facecolor',nnltgray);
  set(b2_box,'facecolor',nnltgray);
  set(W11_text,'string',sprintf('%5.3f',W1(1)));
  set(W12_text,'string',sprintf('%5.3f',W1(2)));
  set(b11_text,'string',sprintf('%5.3f',b1(1)));
  set(b12_text,'string',sprintf('%5.3f',b1(2)));
  set(W21_text,'string',sprintf('%5.3f',W2(1)));
  set(W22_text,'string',sprintf('%5.3f',W2(2)));
  set(b2_text,'string',sprintf('%5.3f',b2));
  set(W11_name,'color',nndkblue);
  set(W12_name,'color',nndkblue);
  set(b11_name,'color',nndkblue);
  set(b12_name,'color',nndkblue);
  set(W21_name,'color',nndkblue);
  set(W22_name,'color',nndkblue);
  set(b2_name,'color',nndkblue);
  nnsound(blp);
  nnpause(pause_time);

  set(state_ptr,'userdata',1);
  set(go_button,'string','Target');
  for i=1:11
    set(vals(i),'color',nnltgray);
    set(vals(i),'string','?');
    set(vals(i),'color',nndkblue);
  end
  nnsound(bloop);


  set(last_text,'color',nnltgray);
  set(last_text,'string',sprintf('%5.3f',e));
  set(last_text,'color',nndkblue);
  end

  set(go_box,'color',nnred);
end

