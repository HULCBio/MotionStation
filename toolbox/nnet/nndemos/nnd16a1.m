function nnd16a1(cmd,arg1,arg2,arg3)
%NND16A1 ART1 algorithm demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd16a1';
p_x = 5; % pattern horizontal size
p_y = 5; % pattern vertical size
psi = 2;
rho = 0.6;
lr = 1;

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
  pattern = H(3:10);          % pattern axes 1-3
  P_ptr = H(11);              % handle to pattern matrix P
  w12_ptr = H(12);            % handle to weight matrix W12
  w21_ptr = H(13);            % handle to weight matrix W21
  edges1 = H(14:17);          % Edges around patterns
  edges2 = H(18:21);          % Edges around prototypes
  rho_text = H(22);
  rho_bar = H(23);
  blip_ptr = H(24);
  bloop_ptr = H(25);
  blip = get(blip_ptr,'userdata');
  bloop = get(bloop_ptr,'userdata');
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

  % STANDARD DEMO FIGURE
  fig = nndemof2(me,'DESIGN','ART1 Algorithm','','Chapter 16');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(16,458,363,'shadow')
  
  % RHO BAR
  x = 30;
  y = 60;
  len = 325;
  text(x,y,'Vigilance (rho):',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  rho_text = text(x+len,y,sprintf('%3.1f',rho),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  rho_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''rho'')'],...
    'min',0,...
    'max',1,...
    'value',rho);

  % ORIGONAL PATTERNS

  p1 = [0 1 0 1 0;
        1 0 0 0 1;
        0 0 0 0 0;
        1 0 0 0 1;
        0 1 0 1 0];

  p2 = [1 1 1 1 1;
        1 1 1 1 1;
        1 1 1 1 1;
        1 0 0 0 1;
        0 1 0 1 0];

  p3 = [0 1 0 1 0;
        1 0 0 0 1;
        0 0 0 0 0;
        1 1 1 1 1;
        1 1 1 1 1];

  p4 = [0 1 1 1 0;
        1 0 1 0 1;
        1 1 1 1 1;
        1 1 1 1 1;
        1 1 1 1 1];

  s1 = p_x*p_y;
  s2 = 4;

  P = 1-[p1(:) p2(:) p3(:) p4(:)];
  w21 = ones(s1,s2);
  w12 = zeros(s2,s1);
  for k=1:s2
    w12(k,:) = psi*w21(:,k)'/(psi+sum(w21(:,k))-1);
  end

  % PATTERN EDGES AND BUTTONS
  pattern = zeros(1,8);
  ltyell = nnltyell;
  for k=1:8
    if k <= 4
      xpos = 20+88*(k-1);
      ypos = 260;
      pos = [xpos ypos 75 75];
      pp = reshape(P(:,k),p_y,p_x);
      present(k) = uicontrol(...
        'units','points',...
        'pos',[xpos+75/2-30 ypos-30 60 20],...
        'string','Present',...
        'callback',[me '(''present'',' num2str(k) ')']);
      edges1(k) = plot(xpos-3+81*[0 1 1 0 0],ypos-3+81*[0 0 1 1 0],...
        'color',nnltgray,...
        'erasemode','none');

    else
      xpos = 20+88*(k-5);
      ypos = 90;
      pos = [xpos ypos 75 75];
      pp = reshape(w21(:,k-4),p_y,p_x);
      edges2(k-4) = plot(xpos-3+81*[0 1 1 0 0],ypos-3+81*[0 0 1 1 0],...
        'color',nnltgray,...
        'erasemode','none');

    end
  end

  % PATTERN AXES
  pattern = zeros(1,8);
  ltyell = nnltyell;
  for k=1:8
    if k <= 4
      title = sprintf('Pattern %g',k);
      xpos = 20+88*(k-1);
      ypos = 260;
      pos = [xpos ypos 75 75];
      pp = reshape(P(:,k),p_y,p_x);
      color = nngreen;

    else
      title = sprintf('Prototype %g',k-4);
      xpos = 20+88*(k-5);
      ypos = 90;
      pos = [xpos ypos 75 75];
      pp = reshape(w21(:,k-4),p_y,p_x);
      color = nnred;

    end
    pattern(k) = nnsfo('a2',title,'','');
    set(pattern(k), ...
      'units','points',...
      'position',pos,...
      'color',nnltyell,...
      'xlim',[0 p_x], ...
      'ylim',[0 p_y],...
      'ydir','reverse')
    axis('off')
    pattern_h = zeros(p_y,p_x);
    box_x = [0 1 1 0 0];
    box_y = [0 0 1 1 0];
    for i=1:p_x, for j=1:p_y
      if pp(j,i) > 0
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
  
  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 140 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[410 110 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 80 60 20],...
    'string','Close',...
    'callback','delete(gcf)')

  % DATA POINTERS
  P_ptr = uicontrol('visible','off','userdata',P);
  w12_ptr = uicontrol('visible','off','userdata',w12);
  w21_ptr = uicontrol('visible','off','userdata',w21);
  blip_ptr = uicontrol('visible','off','userdata',nndsnd(6));
  bloop_ptr = uicontrol('visible','off','userdata',nndsnd(7));

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text pattern P_ptr w12_ptr w21_ptr,...
       edges1 edges2 rho_text rho_bar blip_ptr bloop_ptr];
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
    'Click on the green',...
    'grids to define',...
    'patterns. Click on',...
    'the buttons to',...
    'present them.',...
    '',...
    'The ART1 network''s',...
    'prototype patterns',...
    'are shown below.',...
    '',...
    'Use the slider bar',...
    'to set the ART1',...
    'vigilance.')

%==================================================================
% Show weights.
%
% ME('weights')
%==================================================================

elseif strcmp(cmd,'weights') & (fig) & (nargin == 1)

  % GET DATA
  w = get(w_ptr,'userdata');

  f = figure;
  feval('hintonw',w);
  axis('equal');
  set(f,'name','Network Weights')

%==================================================================
% Respond to rho bar.
%
% ME('rho')
%==================================================================

elseif strcmp(cmd,'rho')
  
  % GET DATA
  rho = get(rho_bar,'value');
  rho = round(rho*10)/10;

  % UPDATE BAR
  set(rho_text,'string',sprintf('%3.1f',rho))

%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  set(fig,'nextplot','add')
  for i=1:4
    [in,x,y] = nnaxclik(pattern(i));

    if in
      set(edges1,'color',nnltgray);
      set(edges2,'color',nnltgray);

      % GET DATA
      x = floor(x)+1;
      y = floor(y)+1;
      green = nngreen;
      ltyell = nnltyell;
      P = get(P_ptr,'userdata');
      squares = get(pattern(i),'userdata');

      % TOGGLE SQUARE
      ind = (x-1)*p_y+y;
      P(ind,i) = 1-P(ind,i);
      if P(ind,i) > 0
        set(squares(x,y),'facecolor',green);
      else
        set(squares(x,y),'facecolor',ltyell);
      end

      % STORE DATA
      set(P_ptr,'userdata',P);

      break;
    end

  end
  set(fig,'nextplot','new')

%==================================================================
% Respond to presentation button.
%
% ME('present',i)
%==================================================================

elseif strcmp(cmd,'present') & (fig) & (nargin == 2)

  P = get(P_ptr,'userdata');
  w12 = get(w12_ptr,'userdata');
  w21 = get(w21_ptr,'userdata');
  rho = get(rho_bar,'value');
  rho = round(rho*10)/10;
  i = arg1;

  set(edges1,'color',nnltgray);
  set(edges1(i),'color',nndkblue);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MARTIN'S CODE

    [s2,s1] = size(w12);
    ind_x = [];
    res_flag = 0;
    while(res_flag==0)

      %  STEP 1, PRESENT INPUT PATTERN

      p = P(:,i);
      a1 = p;

      % STEP 2, LAYER 2 RESPONSE

      n1 = w12*a1;
      n1(ind_x) = -inf*ones(size(ind_x));
      [mxn1,k] = max(n1);
      a2 = zeros(s2,1);
      a2(k) = 1;

      % STEP 3, COMPUTE EPECTATION FROM L2 TO L1

      expect = w21(:,k);

      % STEP 4, ADJUST LAYER 1 OUTPUT TO INCLUDE EXPECTATION

      a1 = p&expect;

      % STEP 5, ORIENTING SUBSYSTEM, CHECK FOR RESONANCE

      if ((sum(a1)/sum(p))<rho)
        a0 = 1;
      else
        a0 = 0;
      end

      % STEP 6, CHECK FOR RESONANCE, INHIBIT CURRENT RESPONSE IF NOT

      if (a0)
        ind_x = [ind_x; k];
        
        time = clock;
        set(edges2,'color',nnltgray);
        set(edges2(k),'color',nndkblue);
        nnsound(blip);
        while (etime(clock,time) < 0.5); end

        % IF ALL PROTOTYPES ARE USED, ADD A NEW ONE

        if(length(ind_x)==s2)
          if (s2==4)
            error('More than four prototypes needed')
          else
            w21 = [w21 ones(s1,1)];
            w12 = [w12; psi*ones(1,s1)/(psi+s1-1)];
            s2 = s2+1;
          end
        end
      else

        % RESONANCE

        res_flag = 1;

        % STEP 7, UPDATE ROW k OF w12

        w12(k,:) = psi*a1'/(psi+sum(a1)-1);

        % STEP 8, UPDATE COLUMN k OF w21

        w21(:,k) = a1;

      end % if a0

    end % while res_flag

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  set(edges2,'color',nnltgray);
  set(edges2(k),'color',nndkblue);
  nnsound(bloop);
  nnpause(0.3)

  for k=1:4
    squares = get(pattern(k+4),'userdata');
    for x=1:p_x
      for y=1:p_y

        % TOGGLE SQUARE
        ind = (x-1)*p_y+y;
        if w21(ind,k) > 0
          set(squares(x,y),'facecolor',nnred);
        else
          set(squares(x,y),'facecolor',nnltyell);
        end
      end
    end
  end

  set(w12_ptr,'userdata',w12);
  set(w21_ptr,'userdata',w21);

%==================================================================
% Respond to clear button.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig)

  set(edges1,'color',nnltgray);
  set(edges2,'color',nnltgray);

  s1 = p_x*p_y;
  s2 = 4;

  w21 = ones(s1,s2);
  w12 = zeros(s2,s1);
  for k=1:s2
    w12(k,:) = psi*w21(:,k)'/(psi+sum(w21(:,k))-1);
  end

  for k=1:4
    squares = get(pattern(k+4),'userdata');
    for x=1:p_x
      for y=1:p_y

        % TOGGLE SQUARE
        ind = (x-1)*p_y+y;
        if w21(ind,k) > 0
          set(squares(x,y),'facecolor',nnred);
        else
          set(squares(x,y),'facecolor',nnltyell);
        end
      end
    end
  end

  set(w12_ptr,'userdata',w12);
  set(w21_ptr,'userdata',w21);

%==================================================================
end
