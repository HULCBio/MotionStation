function nnd10lc(cmd,arg1,arg2,arg3)
% NND10LC Linear pattern classification demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd10lc';
p_size = 4; % pattern size
Fs = 8192;
epochs = 200;

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
  pattern = H(3:9);           % pattern axes 1-4
  P_ptr = H(10);              % handle to pattern matrix P
  w_ptr = H(11);              % handle to weight matrix W
  select = H(12:17);          % select radio buttons
  indicator = H(18);          % Indicator line in meter
  center = H(19);             % Center dot in meter
  b_ptr = H(20);              % handle to bias
  a_ptr = H(21);              % handle to output
  T_ptr = H(22);              % handle to targets
  error_line = H(23);         % error plot line
  p_ptr = H(24);              % handle to test pattern
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


  % STANDARD DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Linear Classification','','Chapter 10');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(10,458,363,'shadow')
  
  % ORIGONAL PATTERNS
  p1 = [1 0 0 0 ...
        1 1 1 1 ...
        1 0 0 0 ...
        0 0 0 0]';
  p2 = [0 0 0 0 ...
        1 0 0 0 ...
        1 1 1 1 ...
        1 0 0 0]';
  p3 = [1 1 1 1 ...
        1 0 1 1 ...
        1 0 1 1 ...
        0 0 0 0]';
  p4 = [0 0 0 0 ...
        1 1 1 1 ...
        1 0 1 1 ...
        1 0 1 1]';
  p5 = [1 1 1 1 ...
        1 1 0 0 ...
        1 0 0 0 ...
        0 0 0 0]';
  p6 = [0 0 0 0 ...
        1 1 1 1 ...
        1 1 0 0 ...
        1 0 0 0]';
  P = [p1 p2 p3 p4 p5 p6]*2-1;
  T = [60 60 0 0 -60 -60];
  [pr,pc] = size(P);
  wb = T/[P; ones(1,pc)];
  w = wb(:,1:pr);
  b = wb(:,pr+1);
  a = w*P(:,1)+b;
  sse = [1.4400e+04 ...
   1.4581e+04 1.5121e+04 1.5467e+04 1.5516e+04 1.5533e+04 ...
   1.5532e+04 1.4380e+04 1.4010e+04 2.0766e+04 1.9903e+04 ...
   1.9919e+04 1.5286e+04 1.5277e+04 1.7370e+04 1.4812e+04 ...
   1.8118e+04 1.7924e+04 1.7761e+04 1.1825e+04 9.4692e+03 ...
   1.0589e+04 7.7866e+03 9.9613e+03 6.9971e+03 5.4178e+03 ...
   6.4192e+03 6.4583e+03 6.7804e+03 7.1363e+03 3.8992e+03 ...
   4.3256e+03 4.3157e+03 4.2625e+03 5.5122e+03 5.4804e+03 ...
   4.5945e+03 4.5873e+03 4.5429e+03 4.4476e+03 4.5129e+03 ...
   4.4779e+03 4.4793e+03 4.4792e+03 4.4804e+03 4.4903e+03 ...
   5.0727e+03 5.0595e+03 5.0641e+03 4.9563e+03 5.0667e+03 ...
   5.0027e+03 5.2156e+03 5.2000e+03 5.2003e+03 5.1947e+03 ...
   3.9786e+03 4.0718e+03 3.9435e+03 2.5307e+03 2.2100e+03 ...
   2.3543e+03 2.2551e+03 2.0019e+03 1.8434e+03 1.8404e+03 ...
   1.0147e+03 9.9245e+02 9.4840e+02 9.5925e+02 4.2599e+02 ...
   6.4822e+02 3.4411e+02 3.4204e+02 3.4082e+02 4.5210e+02 ...
   4.4908e+02 3.4455e+02 3.3122e+02 3.3564e+02 3.2990e+02 ...
   3.2960e+02 3.2961e+02 2.3638e+02 1.9889e+02 2.1589e+02 ...
   1.8150e+02 1.7973e+02 1.7798e+02 1.7795e+02 1.6998e+02 ...
   1.7812e+02 1.7659e+02 1.7667e+02 1.7646e+02 1.7646e+02 ...
   1.7646e+02 1.7086e+02 2.3212e+02 2.2593e+02 2.2605e+02 ...
   2.0026e+02 2.0190e+02 2.0179e+02 2.4986e+02 1.2558e+02 ...
   1.3519e+02 8.7681e+01 8.2263e+01 1.0406e+02 9.2880e+01 ...
   9.8600e+01 4.3382e+01 4.3026e+01 4.3147e+01 4.3151e+01 ...
   4.3151e+01 4.3151e+01 6.3179e+01 5.5896e+01 4.2868e+01 ...
   4.1298e+01 4.1318e+01 2.7662e+01 3.3552e+01 2.0195e+01 ...
   2.0655e+01 2.2891e+01 2.1872e+01 2.0355e+01 1.9390e+01 ...
   1.4952e+01 1.4637e+01 1.4095e+01 1.4651e+01 1.4430e+01 ...
   1.4195e+01 9.4246e+00 1.0900e+01 1.0705e+01 9.9305e+00 ...
   6.3680e+00 6.3964e+00 7.1167e+00 6.7919e+00 8.2954e+00 ...
   8.3167e+00 8.2262e+00 8.3991e+00 8.1387e+00 8.2878e+00 ...
   8.2735e+00 8.2884e+00 8.2889e+00 4.7487e+00 4.6140e+00 ...
   3.4841e+00 3.3306e+00 1.9692e+00 1.9845e+00 2.1071e+00 ...
   1.8270e+00 1.8307e+00 2.0476e+00 2.1692e+00 1.8717e+00 ...
   1.8127e+00 1.6247e+00 1.7082e+00 1.6707e+00 1.5044e+00 ...
   8.7026e-01 8.9067e-01 1.3600e+00 1.3215e+00 1.5141e+00 ...
   6.6989e-01 7.1518e-01 6.9309e-01 5.7921e-01 6.3529e-01 ...
   6.6030e-01 6.8906e-01 6.0431e-01 6.6011e-01 6.8202e-01 ...
   6.8156e-01 6.8157e-01 6.7932e-01 3.4134e-01 4.3134e-01 ...
   3.7053e-01 2.0218e-01 2.3996e-01 2.4591e-01 3.0038e-01 ...
   3.0035e-01 1.5643e-01 1.5926e-01 1.7331e-01 1.3831e-01];
  if (epochs <= 200)
    sse = sse(1:(epochs+1));
  else
    sse = zeros(1,epochs+1);
  end

  % PATTERN AXES
  pattern = zeros(1,6);
  select = zeros(1,6);
  box_x = [0 1 1 0 0];
  box_y = [0 0 1 1 0];
  ltyell = nnltyell;
  for k=1:7
    if (k<7)
      pp = reshape(P(:,k),p_size,p_size);
      title = sprintf('Target = %g',T(k));
      if rem(k,2)==0, title = ''; end
      color = nngreen;
      x = 25+fix((k-1)/2)*85;
      y = 275-rem(k-1,2)*95;

      select(k) = uicontrol(...
        'units','points',...
        'position',[x+20 y-25 20 20],...
        'string','->',...
        'callback',sprintf('%s(''select'',%g)',me,k),...
        'background',nnltgray,...
        'value',(k==1));

    elseif (k == 7)
      pp = reshape(P(:,1),p_size,p_size);
      title = 'Test Input';
      color = nnred;
      x = 280;
      y = 180;
    end
    
    pattern(k) = nnsfo('a2',title,'','');
    set(pattern(k), ...
      'units','points',...
      'position',[x y 60 60],...
      'color',nnltyell,...
      'xlim',[0 p_size], ...
      'ylim',[0 p_size],...
      'ydir','reverse')
    axis('off')
    pattern_h = zeros(p_size,p_size);
    for i=1:p_size, for j=1:p_size
      if (pp(j,i) == 1)
        pattern_h(i,j) = fill(box_x+i-1,box_y+j-1,color,...
          'edgecolor',nndkblue,...
          'erasemode','none');
      else
        pattern_h(i,j) = fill(box_x+i-1,box_y+j-1,ltyell,...
          'edgecolor',nndkblue,...
          'erasemode','none');
      end
    end, end
    set(pattern(k),'userdata',pattern_h);
  end
  
  % ERROR AXIS
  error_axis = nnsfo('a2','Errors','Training Cycle','Sum Squared Error');
  set(error_axis, ...
    'units','points',...
    'position',[225 210 140 120],...
    'position',[50 30 140 70*1.4],...
    'color',nnltyell,...
    'xlim',[0 epochs],...
    'yscale','log')

  % ERROR LINE
  error_line = plot(0:epochs,sse,...
    'color',nnred);
  
  % METER
  deg = pi/180;
  angle = [0:2:180]*deg;
  meter_x = cos(angle);
  meter_y = sin(angle);
  meter_axis = nnsfo('a2','Test Output','Widrow-Hoff Meter','');
  set(meter_axis, ...
    'units','points',...
    'position',[225 30 140 70*1.4],...
    'color',nnltyell,...
    'xlim',[-1 1],...
    'ylim',[-0.1 1.3])
  axis('off')
  set(get(gca,'xlabel'),'visible','on')
  fill3([1 meter_x -1],[-0.1 meter_y -0.1],[0 0*meter_x 0]-1,nnltyell,...
    'edgecolor',nndkblue);
  for i=1:91
    line(meter_x(i)*[1 0.95],meter_y(i)*[1 0.95],'color',nndkblue);
  end
  for i=1:15:91
    line(meter_x(i)*[1 0.9],meter_y(i)*[1 0.9],'color',nndkblue);
  end
  for i=-60:30:60
    angle = (90-i)*deg;
    text(cos(angle)*1.2,sin(angle)*1.2,num2str(i),...
      'fontsize',10,...
      'color',nndkblue,...
      'horizontal','center')
  end
  view(2)

  % CENTER
  pt = 2/140;
  center = plot(2*pt,-pt,'.',...
    'color',nndkblue,...
    'markersize',16,...
    'erasemode','none');

  % INDICATOR
  angle = (90-a)*deg;
  indicator = line(cos(angle)*[0.07 0.85],sin(angle)*[0.07 0.85],...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');

  % BUTTONS
  drawnow;
  if (exist('hintonwb'))
    uicontrol(...
      'units','points',...
      'position',[280 300 60 20],...
      'string','Weights',...
      'callback',[me '(''weight'')'])
  end
  uicontrol(...
    'units','points',...
    'position',[410 146 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
  uicontrol(...
    'units','points',...
    'position',[410 110 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 110-36 60 20],...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA POINTERS
  P_ptr = uicontrol('visible','off'); set(P_ptr,'userdata',P);
  w_ptr = uicontrol('visible','off'); set(w_ptr,'userdata',w);
  b_ptr = uicontrol('visible','off'); set(b_ptr,'userdata',b);
  a_ptr = uicontrol('visible','off'); set(a_ptr,'userdata',a);
  T_ptr = uicontrol('visible','off'); set(T_ptr,'userdata',T);
  p_ptr = uicontrol('visible','off'); set(p_ptr,'userdata',P(:,1));
  
  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text pattern P_ptr w_ptr select indicator center ...
    b_ptr a_ptr T_ptr error_line p_ptr];
  set(fig,'userdata',H,'nextplot','new','color',nnltgray)

  % INSTRUCTION TEXT
  feval(me,'instr');

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & (fig)
  nnsettxt(desc_text,...
    'Edit the RED grids',...
    'and watch the output',...
    'meter respond to the',...
    'new inputs.',...
    '',...
    'Edit the GREEN grid',...
    'and then click [Train]',...
    'to study a different',...
    'problem.',...
    '',...
    'Use GREEN patterns',...
    'as inputs by clicking',...
    'the arrow buttons.')

%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  q = 0;
  for i=1:7
    pt = get(pattern(i),'currentpoint');
    x = pt(1);
    y = pt(3);
    if (x > 0) & (x < p_size) & (y > 0) & (y < p_size)
      q = i;
      break;
    end
  end

  if (q)
    % GET DATA
    x = floor(x)+1;
    y = floor(y)+1;
    ltyell = nnltyell;
    green = nngreen;
    red = nnred;
    squares = get(pattern(i),'userdata');
  
    % TOGGLE SQUARE
    ind = (x-1)*p_size+y;
    if (q<7)
      P = get(P_ptr,'userdata');
      P(ind,q) = -P(ind,q);
      if (P(ind,q) == 1)
        set(squares(x,y),'facecolor',green);
      else
        set(squares(x,y),'facecolor',ltyell);
      end
      set(P_ptr,'userdata',P);
    else
      p = get(p_ptr,'userdata');
      p(ind) = -p(ind);
      if (p(ind) == 1)
        set(squares(x,y),'facecolor',red);
      else
        set(squares(x,y),'facecolor',ltyell);
      end
      set(p_ptr,'userdata',p);
      cmd = 'meter';
    end
  end

%==================================================================
% Select pattern.
%
% ME('select',i)
%==================================================================

elseif strcmp(cmd,'select') & (fig) & (nargin == 2)

  % GET DATA
  i = arg1;
  P = get(P_ptr,'userdata');
  p = get(p_ptr,'userdata');
  w = get(w_ptr,'userdata');
  b = get(b_ptr,'userdata');
  old_a = get(a_ptr,'userdata');
  ltyell = nnltyell;
  red = nnred;
  dkblue = nndkblue;


  % UPDATE TEST INPUT
  p = P(:,i);
  squares = get(pattern(7),'userdata');
  for x=1:p_size,for y=1:p_size
    ind = (x-1)*p_size+y;
    if (p(ind) == 1)
      set(squares(x,y),'facecolor',red);
    else
      set(squares(x,y),'facecolor',ltyell);
    end
  end,end
  set(p_ptr,'userdata',p);
  cmd = 'meter';

%==================================================================
% Show weights.
%
% ME('weight')
%==================================================================

elseif strcmp(cmd,'weight') & (fig)

  % GET DATA
  w = get(w_ptr,'userdata');
  b = get(b_ptr,'userdata');

  f = figure;
  feval('hintonwb',w,b);
  axis('equal');
  set(f,'name','Linear Classifier Bias & Weights')
end

%==================================================================
% Train network.
%
% ME('train')
%==================================================================

if strcmp(cmd,'train') & (fig)

  % CONSTANTS
  lr = 0.03;
  me = 100;

  % GET DATA
  P = get(P_ptr,'userdata');
  T = get(T_ptr,'userdata');

  % TRAINING
  w = zeros(1,16);
  b = 0;
  sse = zeros(epochs+1,1);
  sse(1) = sum(sum((T-w*P-b).^2));
  for i=1:epochs
    q = fix(rand*6)+1;
    p = P(:,q);
    t = T(:,q);
    a = w*p+b;
    e = t-a;
    w = w + 2*lr*e*p';
    b = b + 2*lr*e;
    
    sse(i+1) = sum(sum((T-w*P-b).^2));
  end

  % NEW ERRORS
  set(error_line,'color',nnltyell);
  set(error_line,...
    'ydata',sse,...
    'color',nnred,'erasemode','normal')
  
  % SAVE DATA
  set(w_ptr,'userdata',w);
  set(b_ptr,'userdata',b);
  cmd = 'meter';

end

%==================================================================
% Update the meter.
%
% ME('meter')
%==================================================================

if strcmp(cmd,'meter') & (fig)

  % GET DATA
  p = get(p_ptr,'userdata');
  old_a = get(a_ptr,'userdata');
  w = get(w_ptr,'userdata');
  b = get(b_ptr,'userdata');
  dkblue = nndkblue;
  red = nnred;
  ltyell = nnltyell;

  % UPDATE METER
  old_angle = (90-old_a);
  a = w*p+b;
  new_angle = (90-a);

  if (abs(old_a-a) > 0.5)
    angles = [old_angle:5*sign(new_angle-old_angle):new_angle, new_angle];
    sounds = (180-angles)/180*2000+400;
    angles = min(pi,max(0,angles*pi/180));
    for i=1:length(angles)
      angle = angles(i);

      if (angle == pi | angle == 0)
        color = dkblue;
      else
        color = red;
      end

      t1 = clock;
      set(indicator, ...
        'color',ltyell)
      set(indicator, ...
        'color',color,...
        'xdata',cos(angle)*[0.07 0.85],...
        'ydata',sin(angle)*[0.07 0.85])
      drawnow
      time = [0:(1/Fs):0.015];
      w = time*2*pi;
      nnsound([0 0 0 0 sin(w*sounds(i)) 0 0 0 0],Fs);
      while etime(clock,t1) < 0.015,end
    end
  end

  % STORE DATA
  set(a_ptr,'userdata',a);
end

%==================================================================
