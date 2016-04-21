function nnd12vl(cmd,arg1)
%NND12VL Variable learning rate backpropagation demonstration.
%
%  This demonstration requires the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd12vl';
max_t = 0.5;
w_max = 10;
p_max = 2;
circle_size = 6;
mc = 0.8;
inc = 1.05;
dec = 0.7;
er = 1.04;
lr = 14;

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
  lr_bar = H(3);              % learning rate slider bar
  lr_text = H(4);             % learning rate text
  inc_bar = H(5);             % learning rate increase slider bar
  inc_text = H(6);            % learning rate increase text
  dec_bar = H(7);             % learning rate decrease slider bar
  dec_text = H(8);            % learning rate decrease text
  cont_axis = H(9);           % error contour axis
  cont_ptr = H(10);           % pointer to error contour handles
  variables = H(11:14);       % variable name texts
  radios = H(15:17);          % radio buttons
  option_ptr = H(18);         % index of active radio
  path_ptr = H(19);           % pointer to training path handles
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
  W1 = [10; 10];
  b1 = [-5;5];
  W2 = [1 1];
  b2 = [-1];
  P = -2:0.1:2;
  [R,Q] = size(P);
  A1 = logsig(W1*P+b1*ones(1,Q));
  T = logsig(W2*A1+b2*ones(1,Q));

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Variable LR Backpropagation','','Chapter 12');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(12,458,363,'shadow')

  % NETWORK POSITIONS
  x1 = 40;     % input
  x2 = x1+90;  % 1st layer sum
  x3 = x2+40;  % 1st layer transfer function
  x4 = x3+100; % 2nd layer sum
  x5 = x4+40;  % 2nd layer transfer function
  x6 = x5+50;  % output
  y1 = 330;    % top neuron
  y2 = y1-35;  % input & output neuron
  y3 = y1-70;  % bottom neuron
  sz = 15;     % size of icons
  wx = 55;     % weight vertical offset (from 1st layer)
  wy = 40;     % weight horizontal offset (from middle)

  % NETWORK INPUT
  nndtext(x1-10,y2,'p');
  plot([x2-sz x1 x2-sz],[y1 y2 y3],'linewidth',2,'color',nnred);

  % TOP NEURON
  plot([x2 x2 x3],[y1-sz*2 y1 y1],'linewidth',2,'color',nnred);
  nndsicon('sum',x2,y1,sz)
  nndsicon('logsig',x3,y1,sz)
  var1 = nndtext(x2-wx,y2+wy,'W1(1,1)');
  set(var1,'color',[1 1 1])
  nndtext(x2+2,y1-sz*2-13,'1');
  var2 = nndtext(x2+10,y1-sz*2,'b1(1)','left');

  % BOTTOM NEURON
  plot([x2 x2 x3],[y3-sz*2 y3 y3],'linewidth',2,'color',nnred);
  nndsicon('sum',x2,y3,sz)
  nndsicon('logsig',x3,y3,sz)
  nndtext(x2-wx,y2-wy,'W1(2,1)');
  nndtext(x2+2,y3-sz*2-13,'1');
  var3 = nndtext(x2+10,y3-sz*2,'b1(2)','left');

  % OUTPUT NEURON
  plot([x3+sz x4-10 x3+sz],[y1 y2 y3],'linewidth',2,'color',nnred);
  plot([x4 x4 x6],[y2-sz*2 y2 y2],'linewidth',2,'color',nnred);
  plot([x6-10 x6 x6-10],[y2-7 y2 y2+7],'linewidth',2,'color',nnred);
  nndsicon('sum',x4,y2,sz)
  nndsicon('logsig',x5,y2,sz);
  var4 = nndtext(x3+wx,y2+wy,'W2(1,1)');
  set(var4,'color',[1 1 1])
  nndtext(x3+wx,y2-wy,'W2(1,2)');
  nndtext(x4+2,y2-sz*2-13,'1');
  nndtext(x4+10,y2-sz*2,'b2','left');
  nndtext(x5+sz+5,y2+8,'a2','left');

  % LEARNING RATE SLIDER BAR
  x = 20;
  y = 170;
  text(x,y,'Initial Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(x+160,y,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+160,y-38,'20.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',0,...
    'max',20,...
    'value',lr);

  % INCREASE RATIO SLIDER BAR
  x = 20;
  y = 110;
  text(x,y,'Increase Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  inc_text = text(x+160,y,num2str(inc),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'1.00',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+160,y-38,'1.20',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  inc_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''inc'')'],...
    'min',1,...
    'max',1.2,...
    'value',inc);

  % DECREASE RATIO SLIDER BAR
  x = 20;
  y = 50;
  text(x,y,'Decrease Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  dec_text = text(x+160,y,num2str(dec),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.50',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+160,y-38,'1.00',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  dec_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''dec'')'],...
    'min',0.5,...
    'max',1.0,...
    'value',dec);

  % RADIO BUTTONS
  option = 1;
  radio1 = uicontrol(...
    'units','points',...
    'position',[20 180 130 20],...
    'style','radio',...
    'string','W1(1,1), W2(1,1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',1)'],...
    'value',1);
  radio2 = uicontrol(...
    'units','points',...
    'position',[155 180 115 20],...
    'style','radio',...
    'string','W1(1,1), b1(1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',2)']);
  radio3 = uicontrol(...
    'units','points',...
    'position',[270 180 105 20],...
    'style','radio',...
    'string','b1(1), b1(2)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',3)']);

  % ERROR SURFACE
  load nndbp1

  cont_axis = nnsfo('a2','',v1,v2,'');
  set(cont_axis, ...
    'units','points',...
    'position',[230 40 130 130],...
    'color',nnltyell,...
    'xlim',range1,...
    'ylim',range2,...
    'colororder',[0 0 0])
  [dummy,cont_h] = contour(x2,y2,E2,levels);
  set(cont_h,'erasemode','none');
  plot3(range1([1 2 2 1 1]),range2([1 1 2 2 1]),1000*ones(1,5),...
    'color',nndkblue);
  cont_h2 = plot(optx,opty,'+','color',nnred);
  cont_h = [cont_h; cont_h2];
  view(2)

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
  dummy = 0;
  cont_ptr = uicontrol('visible','off','userdata',cont_h);
  option_ptr = uicontrol('visible','off','userdata',option);
  path_ptr = uicontrol('visible','off','userdata',[]);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text lr_bar lr_text inc_bar inc_text ...
       dec_bar dec_text cont_axis cont_ptr ...
       var1 var2 var3 var4 radio1 radio2 radio3 option_ptr path_ptr];
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
    'Use the radio buttons',...
    'to select the network',...
    'parameters to train',...
    'with backpropagation.',...
    '',...
    'The corresponding',...
    'contour plot is',...
    'shown below.',...
    '',...
    'Click in the contour',...
    'graph to start the',...
    'variable learning',...
    'rate backpropagation',...
    'learning algorithm.')
    
%==================================================================
% Respond to radio buttons.
%
% ME('radio',i)
%==================================================================

elseif strcmp(cmd,'radio') & (fig) & (nargin == 2)

  % GET DATA
  option = get(option_ptr,'userdata');
  
  % ALTER TRAINABLE PARAMETERS
  if (arg1 ~= option)

    % HIGHLIGHT NEW RADIO BUTTON
    set(radios(option),'value',0)
    set(radios(arg1),'value',1)
    option = arg1;

    % CLEAR AXES
    delete(get(cont_axis,'children'))

    % CONSTANTS
    W1 = [10; 10];
    b1 = [-5;5];
    W2 = [1 1];
    b2 = [-1];
    P = -2:0.1:2;
    [R,Q] = size(P);
    A1 = logsig(W1*P+b1*ones(1,Q));
    T = logsig(W2*A1+b2*ones(1,Q));

    % ERROR SURFACE & VARIABLE NAMES
    if option == 1
      load nndbp1
      set(variables([1 4]),'color',[1 1 1])
      set(variables([2 3]),'color',nndkblue)
    elseif option == 2
      load nndbp2
      set(variables([1 2]),'color',[1 1 1])
      set(variables([3 4]),'color',nndkblue)
    else
      load nndbp3
      set(variables([2 3]),'color',[1 1 1])
      set(variables([1 4]),'color',nndkblue)
    end

    set(fig,'nextplot','add')
    axes(cont_axis)
    set(get(cont_axis,'xlabel'),'string',v1)
    set(get(cont_axis,'ylabel'),'string',v2)
    set(cont_axis,'xlim',range1,'ylim',range2)
    [dummy,cont_h] = contour(x2,y2,E2,levels);
    set(cont_h,'erasemode','none');
    plot3(range1([1 2 2 1 1]),range2([1 1 2 2 1]),1000*ones(1,5),...
      'color',nndkblue);
    cont_h2 = plot(optx,opty,'+','color',nnred);
    cont_h = [cont_h; cont_h2];
    view(2)

    % STORE DATA
    set(cont_ptr,'userdata',cont_h);
    set(path_ptr,'userdata',[]);
    set(option_ptr,'userdata',option);
  end

%==================================================================
% Respond to learning rate slider.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr')
  
  lr = get(lr_bar,'value');
  set(lr_text,'string',sprintf('%4.1f',round(lr*10)*0.1))

%==================================================================
% Respond to learning rate increase slider.
%
% ME('inc')
%==================================================================

elseif strcmp(cmd,'inc')
  
  inc = get(inc_bar,'value');
  set(inc_text,'string',sprintf('%4.2f',round(inc*100)*0.01))

%==================================================================
% Respond to learning rate decrease slider.
%
% ME('dec')
%==================================================================

elseif strcmp(cmd,'dec')
  
  dec = get(dec_bar,'value');
  set(dec_text,'string',sprintf('%4.2f',round(dec*100)*0.01))

%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)

  pt = get(cont_axis,'currentpoint');

  x = pt(1);
  y = pt(3);
  xlim = get(cont_axis,'xlim');
  ylim = get(cont_axis,'ylim');

  if (x > xlim(1) & x < xlim(2) & y > ylim(1) & y < ylim(2))

    % GET DATA
    option = get(option_ptr,'userdata');
    path = get(path_ptr,'userdata');
    cont_h = get(cont_ptr,'userdata');

    % REMOVE PREVIOUS PATH
    set(fig,'nextplot','add')
    delete(path);

    % INITIAL VALUES
    W1 = [10; 10];
    b1 = [-5;5];
    W2 = [1 1];
    b2 = [-1];
    P = -2:0.1:2;
    [R,Q] = size(P);
    A1 = logsig(W1*P+b1*ones(1,Q));
    T = logsig(W2*A1+b2*ones(1,Q));

    % PLOT START POINT
    dkblue = nndkblue;
    red = nnred;
    axes(cont_axis);
    path = [...
      plot(x,y,'o','color',dkblue,'markersize',8,'erasemode','none');
      plot(x,y,'o','color',[1 1 1],'markersize',10,'erasemode','none');
      plot(x,y,'o','color',dkblue,'markersize',12,'erasemode','none')];
    drawnow;

    % PLOT PATH
    set(fig,'pointer','watch')

    % INITIALIZE TRAINING
    if option == 1
      W1(1,1) = x;
      W2(1,1) = y;
    elseif option == 2
      W1(1,1) = x;
      b1(1) = y;
    else
      b1(1) = x;
      b1(2) = y;
    end
    ep = 100;
    lr = get(lr_bar,'value');
    inc = get(inc_bar,'value');
    dec = get(dec_bar,'value');

    A1 = logsig(W1*P+b1*ones(1,Q));
    A2 = logsig(W2*A1+b2*ones(1,Q));
    E = T-A2;

    % BACKPROPAGATION PHASE
    D2 = A2.*(1-A2).*E;
    D1 = A1.*(1-A1).*(W2'*D2);
    SSE = sumsqr(E);

    dW1 = 0;
    db1 = 0;
    dW2 = 0;
    db2 = 0;

    xx = [x zeros(1,ep)];
    yy = [y zeros(1,ep)];

    MC = mc;

    for i=2:(ep+1)

      % LEARNING PHASE
      dW1 = MC*dW1 + (1-MC)*D1*P'*lr;
      db1 = MC*db1 + (1-MC)*D1*ones(Q,1)*lr;
      dW2 = MC*dW2 + (1-MC)*D2*A1'*lr;
      db2 = MC*db2 + (1-MC)*D2*ones(Q,1)*lr;
      MC = mc;
      new_W1 = W1; new_b1 = b1;
      new_W2 = W2; new_b2 = b2;
      if (option == 1)
        newx = W1(1,1) + dW1(1,1); new_W1(1,1) = newx;
        newy = W2(1,1) + dW2(1,1); new_W2(1,1) = newy;
      elseif(option == 2)
        newx = W1(1,1) + dW1(1,1); new_W1(1,1) = newx;
        newy = b1(1)   + db1(1);   new_b1(1) = newy;
      else
        newx = b1(1) + db1(1);   new_b1(1) = newx;
        newy = b1(2) + db1(2);   new_b1(2) = newy;
      end

      % PRESENTATION PHASE
      new_A1 = logsig(new_W1*P+new_b1*ones(1,Q));
      new_A2 = logsig(new_W2*A1+new_b2*ones(1,Q));
      new_E = T-new_A2;
      new_SSE = sumsqr(new_E);

      % MOMENTUM & ADAPTIVE LEARNING RATE PHASE
      if new_SSE > SSE*er
        lr = lr * dec;
        MC = 0;
      else
        if new_SSE < SSE
          lr = lr * inc;
        end
        W1 = new_W1; b1 = new_b1; A1 = new_A1;
        W2 = new_W2; b2 = new_b2; A2 = new_A2;
        x = newx;
        y = newy;
        E = new_E; SSE = new_SSE;
    
        % BACKPROPAGATION PHASE
        D2 = A2.*(1-A2).*E;
        D1 = A1.*(1-A1).*(W2'*D2);
      end

      % TRAINING RECORD
      xx(i) = x;
      yy(i) = y;
    end

    % CONTOUR PLOT
    path = [path; plot(xx,yy,'color',nnred); plot(xx,yy,'o','color',nnred,'markersize',6)];
    set(fig,'nextplot','new')
    
    % SAVE DATA
    set(path_ptr,'userdata',path);
    set(fig,'pointer','arrow')

  end
end

