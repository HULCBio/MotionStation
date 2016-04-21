function nnd12m(cmd,arg1)
%NND12M Marquardt backpropagation demonstration.
%
%  This demonstration requires the Neural Network Toolbox.

% $Revision: 1.8 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd12m';
max_t = 0.5;
w_max = 10;
p_max = 2;
circle_size = 6;

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
  mu_bar = H(3);              % mu slider bar
  mu_text = H(4);             % mu text
  nu_bar = H(5);              % nu slider bar
  nu_text = H(6);             % nu text
  cont_axis = H(7);           % error contour axis
  cont_ptr = H(8);            % pointer to error contour handles
  radios = H(9:11);          % radio buttons
  option_ptr = H(12);         % index of active radio
  path_ptr = H(13);           % pointer to training path handles
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
  fig = nndemof2(me,'DESIGN','Marquardt Backpropagation','','Chapter 12');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(12,458,363,'shadow')

  % MU SLIDER BAR
  mu = 0.01;
  x = 20;
  y = 60;
  text(x,y,'Initial MU:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  mu_text = text(x+160,y,num2str(mu),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.01',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+160,y-38,'0.10',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  mu_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''mu'')'],...
    'min',0.01,...
    'max',0.10,...
    'value',mu);

  % NU SLIDER BAR
  nu = 5;
  x = 200;
  y = 60;
  text(x,y,'Constant NU:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  nu_text = text(x+160,y,num2str(nu),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+160,y-38,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  nu_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 160 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''nu'')'],...
    'min',1,...
    'max',10,...
    'value',nu);

  % RADIO BUTTONS
  option = 1;
  radio1 = uicontrol(...
    'units','points',...
    'position',[20 80 130 20],...
    'style','radio',...
    'string','W1(1,1), W2(1,1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',1)'],...
    'value',1);
  radio2 = uicontrol(...
    'units','points',...
    'position',[155 80 115 20],...
    'style','radio',...
    'string','W1(1,1), b1(1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',2)']);
  radio3 = uicontrol(...
    'units','points',...
    'position',[270 80 105 20],...
    'style','radio',...
    'string','b1(1), b1(2)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',3)']);

  % ERROR SURFACE
  load nndbp1

  cont_axis = nnsfo('a2','',v1,v2,'');
  set(cont_axis, ...
    'units','points',...
    'position',[90 140 200 200],...
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
  H = [fig_axis desc_text mu_bar mu_text nu_bar nu_text cont_axis cont_ptr ...
       radio1 radio2 radio3 option_ptr path_ptr];
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
    'shown to the left.',...
    '',...
    'Click in the contour',...
    'graph to start the',...
    'Marquardt backprop',...
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
    elseif option == 2
      load nndbp2
    else
      load nndbp3
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
% Respond to mu slider.
%
% ME('mu')
%==================================================================

elseif strcmp(cmd,'mu')
  
  mu = get(mu_bar,'value');
  set(mu_text,'string',sprintf('%4.2f',round(mu*100)*0.01))

%==================================================================
% Respond to nu slider.
%
% ME('nu')
%==================================================================

elseif strcmp(cmd,'nu')
  
  nu = get(nu_bar,'value');
  set(nu_text,'string',sprintf('%4.1f',round(nu*10)*0.1))

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
    drawnow

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
    mu_initial = get(mu_bar,'value');
    v = get(nu_bar,'value');

    A1 = logsig(W1*P+b1*ones(1,Q));
    A2 = logsig(W2*A1+b2*ones(1,Q));
    E1 = T-A2;
    f1 = sumsqr(E1);

    % DEFINE SIZES
    [R,Q] = size(P); 
    [S2,Q] = size(T);
    S1 = 2;
    RS = S1*R; RS1 = RS+1; RSS = RS + S1; RSS1 = RSS + 1;
    RSS2 = RSS + S1*S2; RSS3 = RSS2 + 1; RSS4 = RSS2 + S2;

    % ASSIGN PARAMETERS
    disp_freq = 1;
    max_epoch = 11;
    err_goal = 0.0000001;
    maxmu=1e10;
    mingrad=.000002;
    mu=mu_initial;
    ii=eye(2);
    meu=zeros(max_epoch,1);
    mer=meu;grad=meu;

    xx = [x zeros(1,max_epoch)];
    yy = [y zeros(1,max_epoch)];

    % MAIN LOOP
    for k=2:(max_epoch+1)
    
      % INITIALIZE A
      mu=mu/v;
      mer(k)=f1;
      meu(k)=mu;
      tst=1;
      
      % FIND JACOBIAN
      A1 = kron(A1,ones(1,S2));
      D2 = nnmdlog(A2);
      D1 = nnmdlog(A1,D2,W2);
      jac1 = nnlmarq(kron(P,ones(1,S2)),D1);
      jac2 = nnlmarq(A1,D2);
      jac=[jac1,D1',jac2,D2'];

      % PULL OUT APPROPRIATE TERMS
      if (option == 1)
        jac = [jac(:,1) jac(:,5)];
      elseif(option == 2)
        jac = [jac(:,1) jac(:,3)];
      else
        jac = [jac(:,3) jac(:,4)];
      end
    
      % CHECK THE MAGNITUDE OF THE GRADIENT
      E1=E1(:);
      je=jac'*E1;
      grad(k)=norm(je);
      if grad(k)<mingrad,
        mer=mer(1:k);
        meu=meu(1:k);
        grad=grad(1:k);
        disp('Training has stopped.')
        disp('Local minumum reached. Gradient is close to zero.')
        fprintf('Magnitude of gradient = %g.\n',grad(k));
        break
      end
    
      % INNER LOOP, INCREASE mu UNTIL THE ERRORS ARE REDUCED
      jj=jac'*jac;
      while tst>0,
        dw=-(jj+ii*mu)\je;
    
        W1n=W1;b1n=b1;W2n=W2;b2n=b2;
    
        % UPDATE VARIABLES
        if (option == 1)
          newx = W1(1,1) + dw(1); W1n(1,1) = newx;
          newy = W2(1,1) + dw(2); W2n(1,1) = newy;
        elseif(option == 2)
          newx = W1(1,1) + dw(1); W1n(1,1) = newx;
          newy = b1(1)   + dw(2);   b1n(1) = newy;
        else
          newx = b1(1) + dw(1);   b1n(1) = newx;
          newy = b1(2) + dw(2);   b1n(2) = newy;
        end
    
        A1 = logsig(W1n*P+b1n*ones(1,Q));
        A2 = logsig(W2n*A1+b2n*ones(1,Q));
        E2 = T-A2;
        f2=sumsqr(E2);  
        if f2>=f1,
          mu=mu*v;
    
          % TEST FOR MAXIMUM mu
          if (mu > maxmu),
            mer=mer(1:k);
            meu=[meu(1:k);mu];
            grad=grad(1:k);
            disp('Maximum mu exceeded.')
            fprintf('mu = %g.\n',mu);
            fprintf('Maximum allowable mu = %g.\n',maxmu);
            break;
          end
        else
          tst=0;
        end
      end
    
      % TEST IF THE ERROR REACHES THE ERROR GOAL
      if f2<=err_goal,
        f1=f2;
        W1=W1n;b1=b1n;W2=W2n;b2=b2n;
        mer=[mer(1:k);f2];
        meu=[meu(1:k);mu];
        grad=grad(1:k);
        disp('Training has stopped. Goal achieved.')
        break;
      end

      if(mu>maxmu),
        disp('Maximum mu exceeded.')
        fprintf('mu = %g.\n',mu);
        fprintf('Maximum allowable mu = %g.\n',maxmu);
        break;
      end

      W1=W1n;b1=b1n;W2=W2n;b2=b2n;E1=E2;f1=f2;

      % DISPLAY PROGRESS
      if rem(k,disp_freq) == 0
        xx(k) = newx;
        yy(k) = newy;
      end
    end

    % CONTOUR PLOT
    ind = find(xx == 0);
    if length(ind)
      ind = ind(1);
      xx = xx(1:(ind-1));
      yy = yy(1:(ind-1));
    end
    path = [path; plot(xx,yy,'color',nnred,'linewidth',1)];
    path = [path; plot(xx,yy,'o','color',nnred,'markersize',6)];
    set(fig,'nextplot','new')
    
    % SAVE DATA
    set(path_ptr,'userdata',path);
    set(fig,'pointer','arrow')

  end
end

