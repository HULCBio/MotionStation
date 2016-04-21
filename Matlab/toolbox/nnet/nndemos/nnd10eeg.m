function nnd10eeg(cmd,arg1,arg2,arg3)
% NND10EEG Electroencephalogram noise cancellation demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd10eeg';
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
  lr_text = H(4);             % text displaying value of learning rate
  lr_bar = H(5);              % learning rate slider
  delay_bar = H(6);           % text displaying value of momentum constant
  delay_text = H(7);          % momentum constant slider
  dc_line = H(8);             % dc line in signal axis
  w_ptr = H(9);               % Pointer to current weights
  P_ptr = H(10);              % Pointer to network input data
  T_ptr = H(11);              % Pointer to network target data
  show_s = H(12);             % "Show signals" radio button
  show_e = H(13);             % "Show error" radio button
  e_line = H(14);             % Estimated signal line in signal axis
  t_line = H(15);             % Target line in signal axis
  d_line = H(16);             % Difference line in signal axis
  S_ptr = H(17);              % Original signal
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
  delays = 10;
  max_delays = 20;
  N = 3.33;                   % Samples per cycle
  f = 60;                     % Frequency of noise
  s = N*f;                    % Samples per second
  ts = round(s*max_t+1);      % Number of samples

  A1 = 1.0;                   % Gain on noise signal #1
  theta1 = pi/2;              % Phase shift of noise signal #1
  A2 = 0.75;                  % Gain on noise signal #2
  theta2 = pi/2.5;            % Phase shift of noise signal #2

  load('eegdata')
  k = 0.00001;                % Signal amplitude
  signal = k*eegdata(1:ts);   % Signal

  i = 1:ts;
  noise1 = 1.20*sin(2*pi*(i-1)/N);
  noise2 = 0.60*sin(4*pi*(i-1)/N);
  noise = noise1 + noise2;

  filtered_noise1 = A1*1.20*sin(2*pi*(i-1)/N + theta1);
  filtered_noise2 = A2*0.60*sin(4*pi*(i-1)/N + theta2);
  filtered_noise = filtered_noise1 + filtered_noise2;

  noisy_signal = signal + filtered_noise;

  w = [0 -2];
  time = [1:ts]/ts*max_t;     % Simulation time points

  % THE FUNCTION
  P = [];
  len_noise = length(noise);
  for i=1:(max_delays+1)
    P = [P; zeros(1,i-1) noise(1:(len_noise-i+1))];
  end
  T = noisy_signal(1:ts);

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','EEG Noise Cancellation','','Chapter 10');
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
  lr = 0.02;
  lr_min = 0;
  lr_max = 0.2;
  text(30,140,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(340,140,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(30,95,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(340,95,'0.2',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[30 110 310 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',lr_min,...
    'max',lr_max,...
    'value',lr);

  text(30,70,'Delays:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  delay_text = text(340,70,num2str(delays),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(30,25,'0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(340,25,'20',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  delay_bar = uicontrol(...
    'units','points',...
    'position',[30 40 310 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''delays'')'],...
    'value',delays,...
    'min',0,...
    'max',20);

  % SIGNAL AXIS
  color_order = [nnred; nndkblue; nngreen; [1 0 1]];
  signal_axis = axes(...
    'units','points',...
    'position',[48 210 300 120],...
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

  % RADIO BUTTONS
  show_s = uicontrol(...
    'units','points',...
    'position',[100 155 70 20],...
    'style','radiobutton',...
    'string','Signals',...
    'callback',[me '(''show_s'')'],...
    'background',nnltgray,...
    'value',1);
  show_e = uicontrol(...
    'units','points',...
    'position',[230 155 100 20],...
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
  P_ptr = uicontrol(...
    'visible','off',...
    'userdata',P);
  T_ptr = uicontrol(...
    'visible','off',...
    'userdata',T);
  s_line_ptr = uicontrol(...
    'visible','off',...
    'userdata',[]);
  S_ptr = uicontrol(...
    'visible','off',...
    'userdata',signal);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text signal_axis ...
       lr_text lr_bar delay_bar delay_text dc_line w_ptr ...
       P_ptr T_ptr show_s show_e e_line t_line d_line S_ptr];
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
    'An EEG signal has', ...
    'been contaminated', ...
    'with noise.',...
    '',...
    'An adaptive linear', ...
    'network is used to', ...
    'remove the noise.', ...
    '',...
    'Use the sliders to set', ...
    'the learning rate and', ...
    'the number of delays.',...
    '',...
    'Use the radio buttons',...
    'to select the original',...
    'and estimated signals,',...
    'or their difference.')

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
% Respond to new delays.
%
% ME('delays')
%==================================================================

elseif strcmp(cmd,'delays') & (fig)
  
  % CHANGE MC TEXT
  delays = get(delay_bar,'value');
  set(delay_text,'string',num2str(round(delays)))

  % UPDATE PLOTS
  cmd = 'update';
  
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
  delays = round(get(delay_bar,'value'));
  lr = round(lr*100)/100;

  % NUMBER OF DELAYS
  R = delays + 1;
  P = P(1:R,:);

  % GET READY TO ADAPT
  w = zeros(1,R);       % Initial weights
  q = size(P,2);        % Number of timesteps
  a = zeros(1,q);       % Network output over time
  e = zeros(1,q);       % Network error over time
  time = [1:q]/q*max_t; % Simulation time points
   
  % ADAPTING
  for i=1:q
    p = P(:,i);
    a(i) = w*p;
    e(i) = T(i) - a(i);
    dw = lr*e(i)*p';
    w = w + dw;
    W(:,i) = w';
  end
  
  % CLEAR SIGNAL AXIS
  axes(signal_axis)
  set(e_line,'color',nnltyell);
  set(t_line,'color',nnltyell);
  set(d_line,'color',nnltyell);
  set(dc_line,'color',nndkblue);
  drawnow

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
