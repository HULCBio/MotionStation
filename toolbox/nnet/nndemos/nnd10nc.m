function nnd10nc(cmd,arg1,arg2,arg3)
% NND10NC Adaptive noise cancellation demonstration.
 
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd10nc';
max_t = 0.5;

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
  signal_axis = H(3);         % signal axis
  weight_axis = H(4);         % weight axis
  lr_text = H(5);             % text displaying value of learning rate
  lr_bar = H(6);              % learning rate slider
  mc_bar = H(7);              % text displaying value of momentum constant
  mc_text = H(8);             % momentum constant slider
  dc_line = H(9);             % dc line in signal axis
  w_ptr = H(10);              % Pointer to current weights
  w_cont_ptr = H(11);         % Pointer to contour lines in weight axis
  w_pt = H(12);               % Initial weight marker
  P_ptr = H(13);              % Pointer to network input data
  T_ptr = H(14);              % Pointer to network target data
  show_s = H(15);             % "Show signals" radio button
  show_e = H(16);             % "Show error" radio button
  w_line = H(17);             % Weight line in weight axis
  e_line = H(18);             % Estimated signal line in signal axis
  t_line = H(19);             % Target line in signal axis
  d_line = H(20);             % Difference line in signal axis
  S_ptr = H(21);              % Origonal signal
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

  % CHECK FOR FILES
  if ~nnfexist(me),return,end

  % CONSTANTS
  N = 3;                      % Samples per cycle
  f = 60;                     % Frequency of noise
  s = N*f;                    % Samples per second
  ts = s*max_t+1;             % Number of samples
  A = 0.1;                    % Gain on noise
  theta = pi/2;               % Phase shift of noise

  k = 0.2;                    % Signal amplitude
  signal = k*rands(1,ts);     % Signal

  i = 1:ts;
  noise = 1.20*sin(2*pi*(i-1)/N);
  filtered_noise = A*1.20*sin (2*pi*(i-1)/N + theta);
  delayed_noise = [noise; 0 noise(1:length(noise)-1)];

  noisy_signal = signal + filtered_noise;

  w = [0 -2];
  time = [1:ts]/ts*max_t;     % Simulation time points

  % THE FUNCTION
  P = delayed_noise;
  T = noisy_signal(1:ts);
  A=2*P*P';
  d=-2*P*T';   
  c=T*T';

  % CONTOUR DATA
  xx = -2.1:0.15:2.1;
  yy = xx;
  [XX,YY] = meshgrid(xx,yy);
  F = (A(1,1)*XX.^2+(A(1,2)+A(2,1))*XX.*YY+A(2,2)*YY.^2)/2 +...
    d(1)*XX + d(2)*YY + c;

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Adaptive Noise Cancellation','Chapter 10','');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(10,458,363,'shadow')

  % SLIDE BARS
  lr = 0.2;
  text(180,140,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(340,140,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(180,95,'0.1',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(340,95,'1.5',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[180 110 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',0.1,...
    'max',1.5,...
    'value',lr);

  mc = 0.0;
  text(180,70,'Momentum:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  mc_text = text(340,70,num2str(mc),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(180,25,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(340,25,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  mc_bar = uicontrol(...
    'units','points',...
    'position',[180 40 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''mc'')'],...
    'value',mc);

  % SIGNAL AXIS
  color_order = [nnred; nndkblue; nngreen; [1 0 1]];
  signal_axis = axes(...
    'units','points',...
    'position',[40 210 300 120],...
    'box','on', ...
    'color',nnltyell, ...
    'xcolor',nndkblue, ...
    'ycolor',nndkblue, ...
    'zcolor',nndkblue, ...
    'fontsize',10,...
    'nextplot','add',...
    'colororder',color_order,...
    'xlim',[0 max_t],...
    'ylim',[-2.1 2.1]);
  xlabel('Time');
  set(get(signal_axis,'xlabel'),'fontw','bold')
  ylabel('Amplitude');
  set(get(signal_axis,'ylabel'),'fontw','bold')
  title('Original (blue) and Estimated (red) Signals')
  set(get(signal_axis,'title'),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12)
  d_line = line(time,time*0,...
    'visible','off',...
    'erasemode','none',...
    'color',nnred);
  t_line = line(time,signal,...
    'erasemode','none',...
    'color',nnltyell);
  e_line = line(time,time*0,...
    'erasemode','none',...
    'color',nnltyell);
  dc_line = plot3([0 max_t],[0 0],[1 1],'--',...
    'color',nndkblue,...
    'erasemode','none');
  set(get(signal_axis,'xlabel'),'fontw','bold','color',nndkblue)
  set(get(signal_axis,'ylabel'),'fontw','bold','color',nndkblue)
  set(get(signal_axis,'zlabel'),'fontw','bold','color',nndkblue)
  view(2)

  % WEIGHT AXIS
  weight_axis = axes(...
    'units','points',...
    'position',[40 40 120 120],...
    'box','on', ...
    'color',nnltyell, ...
    'xcolor',nndkblue, ...
    'ycolor',nndkblue, ...
    'zcolor',nndkblue, ...
    'fontsize',10,...
    'nextplot','add',...
    'colororder',color_order,...
    'xlim',[-2.1 2.1],...
    'ylim',[-2.1 2.1]);
  xlabel('W(1,1)');
  set(get(weight_axis,'xlabel'),...
    'fontw','bold')
  ylabel('W(1,2)');
  set(get(weight_axis,'ylabel'),...
    'fontw','bold')
  title('Adaptive Weights')
  set(get(weight_axis,'title'),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12)
  [dummy,w_cont] = contour(xx,yy,F,10);
  for i=(w_cont')
    set(i,'erasemode','none');
  end
  w_pt = plot3(w(1),w(2),1,'.',...
    'color',nnred,...
    'erasemode','none',...
    'markersize',20);
  w_line = line(w(1),w(2),...
    'erasemode','none',...
    'color',nnred);
  set(get(weight_axis,'xlabel'),'fontw','bold','color',nndkblue)
  set(get(weight_axis,'ylabel'),'fontw','bold','color',nndkblue)
  set(get(weight_axis,'zlabel'),'fontw','bold','color',nndkblue)
  view(2)

  % RADIO BUTTONS
  show_s = uicontrol(...
    'units','points',...
    'position',[180 160 70 20],...
    'style','radiobutton',...
    'string','Signals',...
    'callback',[me '(''show_s'')'],...
    'background',nnltgray,...
    'value',1);
  show_e = uicontrol(...
    'units','points',...
    'position',[250 160 100 20],...
    'style','radiobutton',...
    'string','Difference',...
    'callback',[me '(''show_e'')'],...
    'background',nnltgray,...
    'value',0);

  % BUTTONS
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
  w_ptr = uicontrol(...
    'visible','off',...
    'userdata',w);
  w_cont_ptr = uicontrol(...
    'visible','off',...
    'userdata',w_cont);
  P_ptr = uicontrol(...
    'visible','off',...
    'userdata',P);
  T_ptr = uicontrol(...
    'visible','off',...
    'userdata',T);
  s_line_ptr = uicontrol(...
    'visible','off',...
    'userdata',[]);
  w_path_ptr = uicontrol(...
    'visible','off',...
    'userdata',[]);
  S_ptr = uicontrol(...
    'visible','off',...
    'userdata',signal);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text signal_axis weight_axis ...
       lr_text lr_bar mc_bar mc_text dc_line w_ptr w_cont_ptr w_pt ...
       P_ptr T_ptr show_s show_e w_line e_line t_line d_line S_ptr];
  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

  % UPDATE PLOTS
  cmd = 'update';

  % LOCK WINDOW
  set(fig,'nextplot','new','color',nnltgray)

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & (fig)
  nnsettxt(desc_text,...
    'Click on the bottom',...
    'contour plot to change.',...
    'initial weights.',...
    '',...
    'Use the sliders to',...
    'alter the learning rate',...
    'and momentum.',...
    '',...
    'The radio buttons',...
    'allow the display of',...
    'the original and',...
    'estimated signals',...
    'or their difference')

%==================================================================
% Respond to new learning rate.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr') & (fig)
  
  % CHANGE LR TEXT
  lr = get(lr_bar,'value');
  lr = round(lr*100)/100;
  set(lr_text,'string',num2str(lr))
  cmd = 'update';
  
%==================================================================
% Respond to new momentum constant.
%
% ME('mc')
%==================================================================

elseif strcmp(cmd,'mc') & (fig)
  
  % CHANGE MC TEXT
  mc = get(mc_bar,'value');
  mc = round(mc*100)/100;
  set(mc_text,'string',num2str(mc))

  % UPDATE PLOTS
  cmd = 'update';
  
%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig)

  % SEE IF POINT IS IN WEIGHT AXIS
  pt = get(weight_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  xlim = get(weight_axis,'xlim');
  ylim = get(weight_axis,'ylim');
  if (x >= -2) & (x <= 2) & (y >= -2) & (y <= 2)

    % HIDE INITIAL WEIGHTS
    set(w_pt,'color',nnltyell);
    
    % CREATE NEW INITIAL WEIGHTS
    set(w_pt,...
      'xdata',x,...
      'ydata',y,...
      'color',nnred)

    % STORE DATA
    set(w_ptr,'userdata',[x y])

    % UPDATE PLOTS
    cmd = 'update';
  end

%==================================================================
% Respond to request to show signals.
%
% ME('show_s')
%==================================================================

elseif strcmp(cmd,'show_s') & (fig)
  
  % TURN OFF OTHER RADIO BUTTON
  set(show_e,'value',0)
  
  % HIDE DIFFERENCE PLOT
  set(d_line,'color',nnltyell);
  set(d_line,'visible','off')
  set(dc_line,'color',nndkblue);

  % SHOW SIGNAL PLOTS
  set(t_line,...
    'color',nndkblue,...
    'visible','on')
  set(e_line,...
    'color',nnred,...
    'visible','on')

  % SHOW SIGNAL TITLE
  set(get(signal_axis,'title'),...
    'string','Original (blue) and Estimated (red) Signals')

%==================================================================
% Respond to request to show errors.
%
% ME('show_e')
%==================================================================

elseif strcmp(cmd,'show_e') & (fig)
  
  % TURN OFF OTHER RADIO BUTTON
  set(show_s,'value',0)

  % HIDE SIGNAL PLOTS
  set(t_line,'color',nnltyell);
  set(t_line,'visible','off')
  set(e_line,'color',nnltyell);
  set(e_line,'visible','off')
  set(dc_line,'color',nndkblue);

  % SHOW SIGNAL PLOTS
  set(d_line,...
    'color',nnred,...
    'visible','on')

  % SHOW DIFFERENCE TITLE
  set(get(signal_axis,'title'),...
    'string','Difference between Original and Estimated Signals')

%==================================================================
end

%==================================================================
% Respond to request to update displays.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update') & (fig)
  
  % GET DATA
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');
  S = get(S_ptr,'userdata');
  w = get(w_ptr,'userdata');
  lr = get(lr_bar,'value');
  mc = get(mc_bar,'value');
  w_cont = get(w_cont_ptr,'userdata');
  lr = round(lr*100)/100;
  mc = round(mc*100)/100;


  % GET READY TO ADAPT
  w0 = w;               % Initial weights
  q = size(P,2);        % Number of timesteps
  a = zeros(1,q);       % Network output over time
  e = zeros(1,q);       % Network error over time
  W = zeros(2,q);       % Network weights over time
  time = [1:q]/q*max_t; % Simulation time points
   
  % ADAPTING
  old_dw = [0 0];
  for i=1:q
    a(i) = w*P(:,i);
    e(i) = T(i) - a(i);
    dw = mc*old_dw + (1-mc)*lr*e(i)*P(:,i)';
    w = w + dw;
    W(:,i) = w';
    old_dw = dw;
  end
  
  % CLEAR SIGNAL AXIS
  axes(signal_axis)
  set(e_line,'color',nnltyell);
  set(t_line,'color',nnltyell);
  set(d_line,'color',nnltyell);
  set(dc_line,'color',nndkblue);
  drawnow

  % CLEAR WEIGHT AXIS
  axes(weight_axis)
  set(w_line,'color',nnltyell);
  for i=(w_cont')
    set(i,'edgecolor',get(i,'edgecolor'))
  end
  set(w_pt,'color',nnred)

  % NEW WEIGHTS
  axes(weight_axis)
  index = find((W(1,:) < -2) | (W(1,:) > 2) | (W(2,:) < -2) | (W(2,:) > 2));
  if (length(index))
    mode = 'normal';
  else
    mode = 'none';
  end
  set(w_line,...
    'erasemode',mode);
  set(w_line,...
    'xdata',[w0(1) W(1,:)],...
    'ydata',[w0(2) W(2,:)],...
    'color',nnred);

  % NEW SIGNALS
  axes(signal_axis)
  ylim = [-2 2];
  ymin = ylim(1);
  ymax = ylim(2);

  set(d_line,...
    'ydata',max(ymin,min(ymax,S-e)),...
    'color',nnred);
  set(t_line,...
    'color',nndkblue);
  set(e_line,...
    'ydata',max(ymin,min(ymax,e)),...
    'color',nnred);
end
