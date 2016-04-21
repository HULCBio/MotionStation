function nnd17ds(cmd,arg1)
%NND17DS Dynamical system demonstration.

% $Revision: 1.8 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd17ds';
Tfinal = 40;
m = 1;
l = 9.8;
g = 9.81;
c = 1.96;
deg = pi/180;
ang_max = 15;
vel_max = 2.5;
vel_max2 = 3;
ball_a = 8*deg*[-1 -1 1 1];
ball_r = [0.8 1 1 0.8];
start_x = [-1 0 1 0]*0.4;
start_y = [0 -1 0 1]*0.2;

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
  cont_axis = H(3);           % state contour axis
  pend_axis = H(4);           % pendulum axis
  pend = H(5);                % pendulum
  ball = H(6);                % ball at end of pendulum
  cont_ptr = H(7);            % pointer to contour lines
  angle_ptr = H(8);           % pointer to angle
  start = H(9);               % start state
  velocity_ptr = H(10);       % pointer to velocity
  bars = H(11);               % vertical bars in contour plot
  energy_axis = H(12);        % energy plot axis
  line_ptr = H(13);           % pointer to line handles
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

  % CONSTANTS
  if nnstuded
    ang = -ang_max:.2:ang_max;
    vel = -vel_max2:.2:vel_max2;
  else
    ang = -ang_max:.2:ang_max;
    vel = -vel_max2:.025:vel_max2;
  end
  [Ang,Vel] = meshgrid(ang,vel);
  Energy = -g*cos(Ang) + 0.5*m*(Vel .* Vel);
  Energy = 0.5*m*(l^2)*(Vel .^ 2) + m*g*l*(1 - cos(Ang));

  angle= 2.1;
  velocity= -1.45;

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Dynamic System','','Chapter 17');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(17,458,363,'shadow')

  % CONTOUR AXIS
  cont_axis = nnsfo('a1','Energy Contour','Angle (radians)','Velocity (rad/sec)');
  set(cont_axis, ...
    'units','points',...
    'position',[50 40 310 130],...
    'color',nnltyell,...
    'xlim',[-1 1]*ang_max,...
    'ylim',[-1 1]*vel_max2,...
    'colororder',[nngreen; nndkblue])
  [dummy,cont_h] = contour(Ang,Vel,Energy,[100 191.3 300 400 500]);
  set(cont_h,'erasemode','none')
  view(2)

  start = fill3(angle+start_x,velocity+start_y,ones(size(start_x)),nnred,...
    'edgecolor',nndkblue,...
    'linewidth',1,...
    'erasemode','none');

  bars = plot([-1 -1 1 1 -1]*pi,[-1 1 1 -1 -1]*vel_max,...
    'color',nndkblue,...
    'linestyle','--',...
    'erasemode','none');

  % ENERGY AXIS
  energy_axis = nnsfo('a1','','','');
  set(energy_axis,...
    'units','points',...
    'position',[240 215 120 120],...
    'color',nnltyell,...
    'xlim',[0 Tfinal],...
    'ylim',[0 500],...
    'xtick',[0 10 20 30 40])
  xlabel('Time (sec)');
  ylabel('Energy');
  title('Pendulum Energy')

  % PENDULUM AXIS
  pend_axis = nnsfo('a1','','','');
  set(pend_axis, ...
    'units','points',...
    'position',[40 205 140 140],...
    'color','none',...
    'xlim',[-1 1]*1.3,...
    'ylim',[-1 1]*1.3)
  axis('off')
  view(2)

  circle_a = (0:2.5:355)*deg;
  circle_x = cos(circle_a)*1.15;
  circle_y = sin(circle_a)*1.15;
  fill3(circle_x,circle_y,-ones(size(circle_y)),nnltyell,...
    'edgecolor',nndkblue,...
    'erasemode','none');
  for a = (0:15:355)*deg
    plot(cos(a)*[1.1 1.15],-sin(a)*[1.1 1.15],'color',nndkblue,...
      'erasemode','none')
  end

  text(0*1.3,-1*1.3,'0 radians',...
    'fontsize',10,...
    'color',nndkblue,...
    'erasemode','none',...
    'horiz','center')
  text(1*1.3,0*1.3,'1/2 pi',...
    'fontsize',10,...
    'color',nndkblue,...
    'erasemode','none',...
    'horiz','left')
  text(0*1.3,1*1.3,'pi radians',...
    'fontsize',10,...
    'color',nndkblue,...
    'erasemode','none',...
    'horiz','center')
  text(-1*1.3,0*1.3,'3/2 pi',...
    'fontsize',10,...
    'color',nndkblue,...
    'erasemode','none',...
    'horiz','right')

  % PENDULUM
  pend = plot(sin(angle)*[0 0.8],-cos(angle)*[0 0.8],...
    'linewidth',2,...
    'color',nndkblue,...
    'erasemode','none');
  ball = fill(sin(angle+ball_a).*ball_r,-cos(angle+ball_a).*ball_r,nnred,...
    'edgecolor',nndkblue,...
    'linewidth',2,...
    'erasemode','none');

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[400 180 60 20],...
    'string','Go',...
    'callback',[me '(''go'')'])
  uicontrol(...
    'units','points',...
    'position',[400 145 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
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
  cont_ptr = uicontrol('visible','off','userdata',cont_h);
  angle_ptr = uicontrol('visible','off','userdata',angle);
  velocity_ptr = uicontrol('visible','off','userdata',velocity);
  line_ptr = uicontrol('visible','off','userdata',[]);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text cont_axis pend_axis pend ball cont_ptr...
    angle_ptr start velocity_ptr bars energy_axis line_ptr];
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
    'Drag the pendulum or',...
    'click on the contour',...
    'to set the initial',...
    'state.',...
    '',...
    'Click [Go] to simulate',...
    'and clear to erase',...
    'previous simulations.')
    
%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  % CHECK PENDULUM AXIS
  pt = get(pend_axis,'currentpoint');
  x = pt(1);
  y = pt(3);

  if (sqrt(x^2 + y^2) < 1.2)
    set(fig,...
      'WindowButtonMotionFcn',[me '(''drag_pend'')'],...
      'WindowButtonUpFcn',[me '(''drop_pend'')'])
    set(ball,'facecolor',nngreen);
    set(start,'facecolor',nngreen);
    feval(me,'drag_pend')
  else

  % CHECK CONTOUR AXIS
  pt = get(cont_axis,'currentpoint');
  x = pt(1);
  y = pt(3);

  if (abs(x) < ang_max & abs(y) < vel_max2)
    feval(me,'move_start')
  end

  end

%==================================================================
% Drag pendulum.
%
% ME('drag_pend')
%==================================================================

elseif strcmp(cmd,'drag_pend') & (fig)

  pt = get(pend_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  ltyell = nnltyell;

  angle = atan2(x,-y);
  set(pend,'color',ltyell)
  set(ball,'facecolor',ltyell,'edgecolor',ltyell)
  set(pend,...
    'xdata',sin(angle)*[0 0.8],...
    'ydata',-cos(angle)*[0 0.8],...
    'color',nndkblue)
  set(ball,...
    'xdata',sin(angle+ball_a).*ball_r,...
    'ydata',-cos(angle+ball_a).*ball_r,...
    'facecolor',nngreen,...
    'edgecolor',nndkblue);
    
%==================================================================
% Drop pendulum.
%
% ME('drop_pend')
%==================================================================

elseif strcmp(cmd,'drop_pend') & (fig)

  pt = get(pend_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  velocity = get(velocity_ptr,'userdata');
  ltyell = nnltyell;
  cont_h = get(cont_ptr,'userdata');

  % MOVE PENDULUM
  angle = atan2(x,-y);
  set(pend,'color',ltyell)
  set(ball,'facecolor',ltyell,'edgecolor',nnltyell)
  set(pend,...
    'xdata',sin(angle)*[0 0.8],...
    'ydata',-cos(angle)*[0 0.8],...
    'color',nndkblue)
  set(ball,...
    'xdata',sin(angle+ball_a).*ball_r,...
    'ydata',-cos(angle+ball_a).*ball_r,...
    'facecolor',nnred,...
    'edgecolor',nndkblue);

  % STOP DRAGGIN
  set(fig,...
    'WindowButtonMotionFcn','',...
    'WindowButtonUpFcn','')
  
  % MOVE START STATE
  set(start,'facecolor',ltyell,'edgecolor',ltyell);
  set(start,'xdata',angle+start_x,'ydata',velocity+start_y);
  set(cont_h,'visible','off')
  set(cont_h,'visible','on')
  set(bars,'color',nndkblue)
  set(start,'facecolor',nnred,'edgecolor',nndkblue)

  % SAVE DATA
  set(angle_ptr,'userdata',angle);

%==================================================================
% Move start state.
%
% ME('move_start')
%==================================================================

elseif strcmp(cmd,'move_start') & (fig)

  pt = get(cont_axis,'currentpoint');
  x = pt(1);
  y = pt(3);
  ltyell = nnltyell;
  cont_h = get(cont_ptr,'userdata');

  % NEW STATE
  angle = max(-pi,min(pi,x));
  velocity = max(-vel_max,min(vel_max,y));

  % MOVE START STATE
  set(start,'facecolor',nngreen);
  nnpause(0.2)
  set(start,'facecolor',ltyell,'edgecolor',ltyell);
  set(start,'xdata',angle+start_x,'ydata',velocity+start_y);
  set(cont_h,'visible','off')
  set(cont_h,'visible','on')
  set(bars,'color',nndkblue)
  set(start,'facecolor',nngreen,'edgecolor',nndkblue)
  nnpause(0.2)
  set(start,'facecolor',nnred);

  % MOVE PENDULUM
  set(pend,'color',nnltyell)
  set(ball,'facecolor',nnltyell,'edgecolor',nnltyell)
  set(pend,...
    'xdata',sin(angle)*[0 0.8],...
    'ydata',-cos(angle)*[0 0.8],...
    'color',nndkblue)
  set(ball,...
    'xdata',sin(angle+ball_a).*ball_r,...
    'ydata',-cos(angle+ball_a).*ball_r,...
    'facecolor',nnred,...
    'edgecolor',nndkblue);

  % SAVE DATA
  set(angle_ptr,'userdata',angle);
  set(velocity_ptr,'userdata',velocity);

%==================================================================
% Go.
%
% ME('go')
%==================================================================

elseif strcmp(cmd,'go') & (fig)
  
  % GET DATA
  cont_h = get(cont_ptr,'userdata');
  angle = get(angle_ptr,'userdata');
  velocity = get(velocity_ptr,'userdata');
  energy = 0.5*m*(l^2)*(velocity^2) + m*g*l*(1 - cos(angle));

  Y0 = [angle; velocity];
  options = odeset('RelTol',1e-6);
  [T,Y] = ode45('nndpend',[0 Tfinal], Y0,options);
  angles = Y(:,1)';
  velocities = Y(:,2)';
  energies = 0.5*m*(l^2)*(velocities .^ 2) + m*g*l*(1 - cos(angles));

  % SIMULATE SYSTEM
  set(fig,'nextplot','add')

  last_velocity = velocity;
  last_angle = angle;
  last_time = T(1);
  last_energy = energies(1);
  num_angles = length(angles);
  new_lines1 = zeros(1,num_angles);
  new_lines2 = zeros(1,num_angles);
  tstart = cputime;
  for i=1:length(T)
  
    % PAUSE
  tnext = cputime;
  tlapse = tnext-tstart;
    while tlapse < T(i)
      tnext = cputime;
    tlapse = tnext-tstart;
  end

    angle = angles(i);
    velocity = velocities(i);
    time = T(i);
    energy = energies(i);

    % MOVE PENDULUM
    set(pend,'color',nnltyell)
    set(ball,'facecolor',nnltyell,'edgecolor',nnltyell)
    set(pend,...
      'xdata',sin(angle)*[0 0.8],...
      'ydata',-cos(angle)*[0 0.8],...
      'color',nndkblue)
    set(ball,...
      'xdata',sin(angle+ball_a).*ball_r,...
      'ydata',-cos(angle+ball_a).*ball_r,...
      'facecolor',nnred,...
      'edgecolor',nndkblue);

    % PLOT STATE
    new_lines1(i) = plot([last_angle angle],[last_velocity velocity],...
      'erasemode','none',...
      'color',nnred,'parent',cont_axis);

    % PLOT ENERGY
    new_lines2(i) = plot([last_time time],[last_energy energy],...
      'erasemode','none',...
      'color',nnred,'parent',energy_axis);
    drawnow;

    last_velocity = velocity;
    last_angle = angle;
    last_time = time;
    last_energy = energy;
  end

  set(fig,'nextplot','new')

  % SAVE DATA
  lines = get(line_ptr,'userdata');
  lines = [lines new_lines1(2:num_angles) new_lines2(2:num_angles)];
  set(line_ptr,'userdata',lines);
  set(angle_ptr,'userdata',angle);
  set(velocity_ptr,'userdata',velocity);
  
%==================================================================
% Clear.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig)
  
  % CLEAR LINES
  lines = get(line_ptr,'userdata');
  set(lines,'erasemode','normal')
  delete(lines);
  set(line_ptr,'userdata',[])

  % GET DATA
  ltyell = nnltyell;
  cont_h = get(cont_ptr,'userdata');
  angle = get(angle_ptr,'userdata');
  velocity = get(velocity_ptr,'userdata');

  % MOVE START STATE
  set(start,'facecolor',ltyell,'edgecolor',ltyell);
  set(start,...
    'xdata',angle+start_x,...
    'ydata',velocity+start_y,...
    'facecolor',nnred,...
    'edgecolor',nndkblue);
  set(cont_h,'visible','off')
  set(cont_h,'visible','on')
  set(bars,'color',nndkblue)
end

