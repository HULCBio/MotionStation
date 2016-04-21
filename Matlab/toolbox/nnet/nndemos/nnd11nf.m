function [ret1,ret2,ret3,ret4,ret5]=nnd11nf(cmd,arg1,arg2,arg3,arg4,arg5)
%NND11NF Network function demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.
%
%  NND11NF
%  Opens demonstration with default values.
%
%  NND11NF('set',W1,b1,W2,b2,f2)
%    W1 - 2x1 weight matrix for 1st layer.
%    b1 - 2x1 bias vector for 1st layer.
%    W2 - 1x2 weight matrix for 2nd layer.
%    b2 - 1x1 bias for 2nd layer.
%    f2 - Name (string) of 2nd layer transfer function.
%  Sets network parameters accordingly.
%
%  NND11NF('random')
%  Sets network parameters to randomly chosen values.
%
% [W1,b1,W2,b2,f2] = NND11NF('get')
%  Gets network parameters.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $

%==================================================================

% CONSTANTS
me = 'nnd11nf';
max_t = 0.5;
w_max = 10;
p_max = 2;

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
  meters = H(3:9);            % parameter axes
  indicators = H(10:16);      % paramter indicators
  tf_icon_ptr = H(17);        % 2nd layer transfer function icon
  tf_menu = H(18);            % 2nd layer transfer function menu
  func_axis = H(19);          % network function axis
  func_line = H(20);          % network function line
  p_line = H(21);             % vertical input line
  a_line = H(22);             % horizontal output line
  values_ptr = H(23);         % Network parameter, input & output values
  tf_ptr = H(24);             % 2nd layer transfer functio name
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
  W1 = [10; 10];
  b1 = [-10;10];
  W2 = [1 1];
  b2 = [0];
  tf = 'purelin';
  p = 0;
  a = feval(tf,W2*logsig(W1*p+b1)+b2);
  values = [W1(1) b1(1) W2(1) W1(2) b1(2) W2(2) b2 p a];

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Network Function','','Chapter 11');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(11,458,363,'shadow')

  % NETWORK POSITIONS
  x1 = 40;     % input
  x2 = x1+90;  % 1st layer sum
  x3 = x2+40;  % 1st layer transfer function
  x4 = x3+100; % 2nd layer sum
  x5 = x4+40;  % 2nd layer transfer function
  x6 = x5+50;  % output
  y1 = 265;    % top neuron
  y2 = y1-20;  % input & output neuron
  y3 = y1-40;  % bottom neuron
  sz = 15;     % size of icons
  wx = 50;     % weight vertical offset (from 1st layer)
  wy = 35;     % weight horizontal offset (from middle)

  % NETWORK INPUT
  nndtext(x1-10,y2,'p');
  plot([x2-sz x1 x2-sz],[y1 y2 y3],'linewidth',2,'color',nnred);

  % TOP NEURON
  plot([x2 x2 x3],[y1+sz*2 y1 y1],'linewidth',2,'color',nnred);
  nndsicon('sum',x2,y1,sz)
  nndsicon('logsig',x3,y1,sz)
  nndtext(x2-wx,y2+wy,'W1(1,1)');
  nndtext(x2+2,y1+sz*2+11,'1');
  nndtext(x2+10,y1+sz*2,'b1(1)','left');

  % BOTTOM NEURON
  plot([x2 x2 x3],[y3-sz*2 y3 y3],'linewidth',2,'color',nnred);
  nndsicon('sum',x2,y3,sz)
  nndsicon('logsig',x3,y3,sz)
  nndtext(x2-wx,y2-wy,'W1(2,1)');
  nndtext(x2+2,y3-sz*2-13,'1');
  nndtext(x2+10,y3-sz*2,'b1(2)','left');

  % OUTPUT NEURON
  plot([x3+sz x4-10 x3+sz],[y1 y2 y3],'linewidth',2,'color',nnred);
  plot([x4 x4 x6],[y2-sz*2 y2 y2],'linewidth',2,'color',nnred);
  plot([x6-10 x6 x6-10],[y2-7 y2 y2+7],'linewidth',2,'color',nnred);
  nndsicon('sum',x4,y2,sz)
  tf_icon = nndsicon(tf,x5,y2,sz);
  nndtext(x3+wx,y2+wy,'W2(1,1)');
  nndtext(x3+wx,y2-wy,'W2(1,2)');
  nndtext(x4+2,y2-sz*2-13,'1');
  nndtext(x4+10,y2-sz*2,'b2','left');
  nndtext(x5+sz+5,y2+8,'a2','left');

  % PARAMETER POSITIONS
  xx = 20 + [0:3]*90;
  yy = [330 150];

  % PARAMETER METERS & INDICATORS
  meters = [];
  indicators = [];
  for i=1:2
    for j=1:4
      pn = j+(i-1)*3;
      val = values(pn);
      if any([3 6 7] == pn)
        maxval = 2;
      else
        maxval = 10;
      end
      maxstr = num2str(maxval);
      if (i ~= 1) | (j ~= 4)
        ax = nnsfo('a2','','','');
        set(ax,...
          'units','points',...
          'position',[xx(j) yy(i) 70 20],...
          'color',nnmdgray,...
          'ylim',[-0.3 1.3],...
          'ytick',[],...
          'xlim',[-1.3 1.3]*maxval,...
          'xtick',[-1 -0.5 0 0.5 1]*maxval,...
          'xticklabel',str2mat(['-' maxstr],'','0','',maxstr));
        ind = fill([0 0.2 -0.2]*maxval+val,[0 1 1],nnred,...
          'edgecolor',nndkblue,...
          'erasemode','none');
        meters = [meters ax];
        indicators = [indicators ind];
      end
    end
  end

  % TRANSFER FUNCTION POPUP MENU
  tf_menu = uicontrol(...
    'units','points',...
    'position',[xx(4) yy(1) 70 20],...
    'style','popupmenu',...
    'string','logsig|purelin|tansig',...
    'callback',[me '(''tf'')']);
  set(tf_menu,'value',2);

  % PARAMETER LINES
  xx = xx + 0.5;
  y = yy(1)+10;
  x = xx(1)+70;
  plot([0 5 5]+x,[0 0 -45]+y,'color',nndkgray);
  x = xx(2)+70;
  plot([0 5 5 0]+x,[0 0 -45 -45]+y,'color',nndkgray);
  x = xx(3)+70;
  plot([0 5 5 -18]+x,[0 0 -60 -60]+y,'color',nndkgray);
  x = xx(4)+70;
  plot([0 5 5 -50 -50]+x,[0 0 -55 -55 -71]+y,'color',nndkgray);
  y = yy(2)+10;
  x = xx(1)+70;
  plot([0 5 5]+x,[0 0 35]+y,'color',nndkgray);
  x = xx(2)+70;
  plot([0 5 5 0]+x,[0 0 35 35]+y,'color',nndkgray);
  x = xx(3)+70;
  plot([0 5 5 -50 -50]+x,[0 0 20 20 35]+y,'color',nndkgray);
  x = xx(4)+70;
  plot([0 5 5 -55]+x,[0 0 55 55]+y,'color',nndkgray);

  % NETWORK FUNCTION
  P = -p_max:0.1:p_max;
  [R,Q] = size(P);
  A = feval(tf,W2*logsig(W1*P+b1*ones(1,Q))+b2*ones(1,Q));
  a_max = max(A);
  a_min = min(A);
  a_edge = (a_max-a_min)*0.1;

  % FUNCTION AXIS
  y = 20;
  x = 40;
  func_axis = nnsfo('a2','','','');
  set(func_axis, ...
    'units','points',...
    'position',[x y 320 110],...
    'color',nnltyell,...
    'xlim',[-1 1]*p_max+[-0.1 0.1],...
    'ylim',[a_min a_max]+[-a_edge a_edge])
  p_line = plot([p p],[a_min a_max],'--',...
    'color',nnred,...
    'erasemode','none');
  a_line = line([-p_max p],[a a],...
    'color',nnred,...
    'erasemode','none');
  func_line = plot(P,A,...
    'color',nndkblue,...
    'erasemode','none',...
    'linewidth',2);

  % BUTTONS
  drawnow % Let everything else appear before buttons 
  uicontrol(...
    'units','points',...
    'position',[400 145 60 20],...
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
  tf_icon_ptr = uicontrol('visible','off','userdata',tf_icon);
  value_ptr = uicontrol('visible','off','userdata',values);
  tf_ptr = uicontrol('visible','off','userdata',tf);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text meters indicators  tf_icon_ptr tf_menu ...
    func_axis func_line p_line a_line value_ptr tf_ptr];

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

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
% Respond to transfer function menu.
%
% ME('tf')
%==================================================================

elseif strcmp(cmd,'tf') & (fig)

  % GET NEW TRANSFER FUNCTION NAME
  i = get(tf_menu,'value');
  if i == 1, tf = 'logsig';
  elseif i == 2, tf = 'purelin';
  elseif i == 3, tf = 'tansig';
  end

  % ALTER ICON
  axes(fig_axis);
  tf_icon = get(tf_icon_ptr,'userdata');
  delete(tf_icon);
  tf_icon = nndsicon(tf,310,245,15);
  set(tf_icon_ptr,'userdata',tf_icon);

  % SAVE DATA
  set(tf_ptr,'userdata',tf);
  
  % UPDATA FUNCTION
  cmd = 'update';

%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  handled = 0;
  for i=1:7

    if any([3 6 7] == i)
      maxval = 2;
    else
      maxval = 10;
    end

    pt = get(meters(i),'currentpoint');
    x = pt(1);
    y = pt(3);

    if (abs(x) <= maxval*1.3) & (y >= -0.3 & y <= 1.3)
      handled = 1;

      % SET UP MOTION TRACKING IN METER
      set(fig,'WindowButtonMotionFcn',[me '(''m_motion'',' num2str(i) ')']);
      set(fig,'WindowButtonUpFcn',[me '(''m_up'',' num2str(i) ')']);
      feval(me,'m_motion',i);
    end
  end

  if (~handled)
    pt = get(func_axis,'currentpoint');
    x = pt(1);
    y = pt(3);
    ylim = get(func_axis,'ylim');
    if (abs(x) <= p_max) & (y >= ylim(1) & y <= ylim(2))

      % SET UP MOTION TRACKING FOR FUNCTION
      set(fig,'WindowButtonMotionFcn',[me '(''f_motion'')']);
      set(fig,'WindowButtonUpFcn',[me '(''f_up'')']);
      feval(me,'f_motion',i);
    end
  end

%==================================================================
% Respond to motion in meter.
%
% ME('m_motion',meter_index)
%==================================================================

elseif strcmp(cmd,'m_motion') & (fig)
  
  if any([3 6 7] == arg1)
    maxval = 2;
  else
    maxval = 10;
  end

  % GET CURRENT POINT
  pt = get(meters(arg1),'currentpoint');
  x = pt(1);
  x = round(x*10/maxval)*maxval/10;
  x = max(-maxval,min(maxval,x));

  % GET DATA
  mdgray = nnmdgray;
  values = get(values_ptr,'userdata');
 
  % MOVE INDICATOR
  xdata = [0 0.2 -0.2]*maxval+x;
  set(indicators(arg1),'facecolor',mdgray,'edgecolor',mdgray);
  set(indicators(arg1),'facecolor',nnwhite,'edgecolor',nndkblue,'xdata',xdata);

  % STORE DATA
  values(arg1) = x;
  set(values_ptr,'userdata',values);

%==================================================================
% Respond to mouse up in meter.
%
% ME('m_up',meter_index)
%==================================================================

elseif strcmp(cmd,'m_up') & (fig)
  
  % DISABLE TRACKING
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'WindowButtonMotionFcn','');

  % RESET INDICATOR COLORS
  set(indicators(arg1),'facecolor',nnred,'edgecolor',nndkblue);

  % UPDATE FUNCTION
  cmd = 'update';

%==================================================================
% Respond to motion in function.
%
% ME('f_motion')
%==================================================================

elseif strcmp(cmd,'f_motion') & (fig)
  
  % GET CURRENT POINT
  pt = get(func_axis,'currentpoint');
  x = pt(1);
  x = max(-p_max,min(p_max,x));

  % GET DATA
  mdgray = nnmdgray;
  tf = get(tf_ptr,'userdata');
  values = get(values_ptr,'userdata');
  W1 = values([1 4])';
  b1 = values([2 5])';
  W2 = values([3 6]);
  b2 = values(7);
  ltyell = nnltyell;
  
  % NEW INPUT & OUTPUT
  p = x;
  a = feval(tf,W2*logsig(W1*p+b1)+b2);

  % MOVE LINES
  set(a_line,'color',ltyell);
  set(p_line,'color',ltyell);
  set(p_line,'color',nngreen,'xdata',[p p])
  set(a_line,'color',nnred,'ydata',[a a],'xdata',[-p_max p])
  set(func_line,'color',nndkblue)

  % STORE DATA
  values(8) = p;
  values(9) = a;
  set(values_ptr,'userdata',values);

%==================================================================
% Respond to mouse up in function.
%
% ME('f_up')
%==================================================================

elseif strcmp(cmd,'f_up') & (fig)
  
  % DISABLE TRACKING
  set(fig,'WindowButtonMotionFcn','');
  set(fig,'WindowButtonMotionFcn','');

  % RESET P-LINE COLOR
  red = nnred;
  set(p_line,'color',red)
  set(a_line,'color',red)
  set(func_line,'color',nndkblue)

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

    % GET VALUES
    values = get(values_ptr,'userdata');
    tf = get(tf_ptr,'userdata');
    p = values(8);
 
    % ALTER VALUES
    W1 = min(w_max,max(-w_max,arg1));
    b1 = min(w_max,max(-w_max,arg2));
    W2 = min(w_max,max(-w_max,arg3));
    b2 = min(w_max,max(-w_max,arg4));
    if strcmp(arg5,'linear')
      tf = 'purelin';
      set(tf_menu,'value',2)
    elseif strcmp(arg5,'logsig')
      tf = 'logsig';
      set(tf_menu,'value',1)
    elseif strcmp(arg5,'purelin')
      tf = 'purelin';
      set(tf_menu,'value',2)
    elseif strcmp(arg5,'tansig')
      tf = 'tansig';
      set(tf_menu,'value',3)
    end

    [R,Q] = size(p);
    a = feval(tf,W2*logsig(W1*p+b1*ones(1,Q))+b2*ones(1,Q));
    values = [W1(1) b1(1) W2(1) W1(2) b1(2) W2(2) b2 p a];

    % SAVE VALUES
    set(values_ptr,'userdata',values);

    % MOVE METERS
    cmd = 'move';
  end

%==================================================================
% Randomize parameters.
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random') & (fig)

  % GET VALUES
  values = get(values_ptr,'userdata');
  p = values(8);
 
  % ALTER VALUES
  W1 = (rand(2,1)*2-1)*10;
  b1 = (rand(2,1)*2-1)*01;
  W2 = (rand(1,2)*2-1)*2;
  b2 = (rand(1,1)*2-1)*2;
  tf_ind = fix(rand*3)+1;
  set(tf_menu,'value',tf_ind)
  if tf_ind == 1
    tf = 'logsig';
  elseif tf_ind == 2
    tf = 'purelin';
  elseif tf_ind == 3
    tf = 'tansig';
  end
  set(tf_ptr,'userdata',tf)

  [R,Q] = size(p);
  a = feval(tf,W2*logsig(W1*p+b1*ones(1,Q))+b2*ones(1,Q));
  values = [W1(1) b1(1) W2(1) W1(2) b1(2) W2(2) b2 p a];

  % SAVE VALUES
  set(values_ptr,'userdata',values);

  % MOVE METERS
  cmd = 'move';

%==================================================================
% Get parameters.
%
% [W1,b1,W2,b2,f2] = ME('get')
%==================================================================

elseif strcmp(cmd,'get') & (fig)

  % GET DATA
  values = get(values_ptr,'userdata');
  ret1 = values([1 4])';
  ret2 = values([2 5])';
  ret3 = values([3 6]);
  ret4 = values(7);
  ret5 = get(tf_ptr,'userdata');
end

%==================================================================
% Move meters.
%
% ME('move')
%==================================================================

if strcmp(cmd,'move') & (fig)
  
  % GET DATA
  values = get(values_ptr,'userdata');

  % PICK PROPER ICON
  axes(fig_axis);
  tf_icon = get(tf_icon_ptr,'userdata');
  delete(tf_icon);
  tf_icon = nndsicon(tf,310,245,15);
  set(tf_icon_ptr,'userdata',tf_icon);

  % HILIGHT METERS
  mdgray = nnmdgray;
  red = nnred;
  white = nnwhite;
  dkblue = nndkblue;
  for i=1:7
    set(indicators(i),'facecolor',white);
  end
  nnpause(0.25)

  % MOVE METERS
  for i=1:7
    if any([3 6 7] == i)
      maxval = 2;
    else
      maxval = 10;
    end
    xx = [0 0.2 -0.2]*maxval+values(i);
    set(indicators(i),'facecolor',mdgray,'edgecolor',mdgray);
    set(indicators(i),'facecolor',white,'edgecolor',dkblue,'xdata',xx);
  end
  nnpause(0.25)

  % UNHILIGHT METERS
  for i=1:7
    set(indicators(i),'facecolor',red);
  end

  % ALWAYS DO AN UPDATE AFTERWARDS
  cmd = 'update';
end

%==================================================================
% Update function.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update') & (fig)

  % GET DATA
  tf = get(tf_ptr,'userdata');
  values = get(values_ptr,'userdata');
  W1 = values([1 4])';
  b1 = values([2 5])';
  W2 = values([3 6]);
  b2 = values(7);
  p = values(8);
  ltyell = nnltyell;
  red = nnred;

  % NEW FUNCTION
  [R,Q] = size(p);
  a = feval(tf,W2*logsig(W1*p+b1*ones(1,Q))+b2*ones(1,Q));
  P = -p_max:0.05:p_max;
  [R,Q] = size(P);
  A = feval(tf,W2*logsig(W1*P+b1*ones(1,Q))+b2*ones(1,Q));

  % CALCULATE AXIS AND LINE LIMITS
  a_max = max(A);
  a_min = min(A);
  a_mid = (a_max+a_min)/2;
  a_dif = a_max-a_min;

  a_dif = a_dif + max(a_dif*0.1,0.1);
  a_max = a_mid+0.45*a_dif;
  a_min = a_mid-0.45*a_dif;
  a_edge = 0.05*a_dif;

  % HIDE LINES
  set(func_line,'color',ltyell);
  set(p_line,'color',ltyell);
  set(a_line,'color',ltyell);

  % RESIZE AXIS
  set(func_axis,'ylim',[a_min-a_edge a_max+a_edge]);
  hold on

  % REDRAW LINES
  set(p_line,'color',red,'xdata',[p p],'ydata',[a_min a_max])
  set(a_line,'color',red,'ydata',[a a],'xdata',[-p_max p])
  set(func_line,'color',nndkblue,'xdata',P,'ydata',A)
  
  % STORE DATA
  set(values_ptr,'userdata',values);
end
