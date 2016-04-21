function nnd12cg(cmd,arg1)
%NND12CG Conjugate gradient backpropagation demonstration.
%
%  This demonstration requires the Neural Network Toolbox.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================


% CONSTANTS
me = 'nnd12cg';
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
  cont_axis = H(3);           % error contour axis
  cont_ptr = H(4);            % pointer to error contour handles
  radios = H(5:7);          % radio buttons
  option_ptr = H(8);         % index of active radio
  path_ptr = H(9);           % pointer to training path handles
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
  fig = nndemof2(me,'DESIGN','Conjugate Gradient Backprop','','Chapter 12');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(12,458,363,'shadow')

  % RADIO BUTTONS
  option = 1;
  radio1 = uicontrol(...
    'units','points',...
    'position',[20 335 130 20],...
    'style','radio',...
    'string','W1(1,1), W2(1,1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',1)'],...
    'value',1);
  radio2 = uicontrol(...
    'units','points',...
    'position',[155 335 115 20],...
    'style','radio',...
    'string','W1(1,1), b1(1)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',2)']);
  radio3 = uicontrol(...
    'units','points',...
    'position',[270 335 105 20],...
    'style','radio',...
    'string','b1(1), b1(2)',...
    'back',nnltgray,...
    'callback',[me '(''radio'',3)']);

  % ERROR SURFACE
  load nndbp1

  cont_axis = nnsfo('a2','',v1,v2,'');
  set(cont_axis, ...
    'units','points',...
    'position',[50 40 280 280],...
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
  cont_ptr = uicontrol('visible','off','userdata',cont_h);
  option_ptr = uicontrol('visible','off','userdata',option);
  path_ptr = uicontrol('visible','off','userdata',[]);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text cont_axis cont_ptr ...
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
    'conjugate gradient',...
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
    set(path,'erasemode','normal');
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
    Lx = x;
    Ly = y;
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

    A1 = logsig(W1*P+b1*ones(1,Q));
    A2 = logsig(W2*A1+b2*ones(1,Q));
    E = T-A2;
    fa=sumsqr(E);

    D2 = A2.*(1-A2).*E;
    D1 = A1.*(1-A1).*(W2'*D2);
    gW1 = D1*P';
    gb1 = D1*ones(Q,1);
    gW2 = D2*A1';
    gb2 = D2*ones(Q,1);

    if (option == 1)
      nrmo = gW1(1,1)^2 + gW2(1,1)^2;
    elseif(option == 2)
      nrmo = gW1(1,1)^2 + gb1(1)^2;
    else
      nrmo = gb1(1)^2 + gb1(2)^2;
    end

    % NORM OF GRADIENT
    nrmrt=sqrt(nrmo);

    % INITIALIZE DIRECTION
    dW1old=gW1;db1old=gb1;dW2old=gW2;db2old=gb2;
    dW1=gW1/nrmrt;db1=gb1/nrmrt;dW2=gW2/nrmrt;db2=gb2/nrmrt;

    % ASSIGN PARAMETERS
    tau=0.618;
    tau1=1-tau;
    scaletol=20;
    delta=0.32;
    delta1=.03;
    tol=delta1/scaletol;
    scale=2.0;
    bmax=26;
    n=2;                 %number of steps before reset


    % MAIN LOOP
    max_epoch = 15;
    xx = [x zeros(1,max_epoch)];
    yy = [y zeros(1,max_epoch)];
    for i=2:(max_epoch+1)
    
      % INITIALIZE A
      a=0;
      aold=0;
      b=delta;
      faold=fa;

      % CALCULATE INITIAL SSE 
      W1t = W1; b1t = b1;
      W2t = W2; b2t = b2;
      if (option == 1)
        newx = W1(1,1) + b*dW1(1,1); W1t(1,1) = newx;
        newy = W2(1,1) + b*dW2(1,1); W2t(1,1) = newy;
      elseif(option == 2)
        newx = W1(1,1) + b*dW1(1,1); W1t(1,1) = newx;
        newy = b1(1)   + b*db1(1);   b1t(1) = newy;
      else
        newx = b1(1) + b*db1(1);   b1t(1) = newx;
        newy = b1(2) + b*db1(2);   b1t(2) = newy;
      end
    
      fb = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
    
      % FIND INITIAL INTERVAL WHERE SSE MINIMUM OCCURS
      while (fa>fb)&(b<bmax)
        aold=a;
        faold=fa;
        fa=fb;
        a=b;
        b=scale*b;
        if (option == 1)
          newx = W1(1,1) + b*dW1(1,1); W1t(1,1) = newx;
          newy = W2(1,1) + b*dW2(1,1); W2t(1,1) = newy;
        elseif(option == 2)
          newx = W1(1,1) + b*dW1(1,1); W1t(1,1) = newx;
          newy = b1(1)   + b*db1(1);   b1t(1) = newy;
        else
          newx = b1(1) + b*db1(1);   b1t(1) = newx;
          newy = b1(2) + b*db1(2);   b1t(2) = newy;
        end
        fb = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
      end
      a=aold;
      fa=faold;
    
      % SHOW INITIAL INTERVAL
      if (option == 1)
        newx = W1(1,1) + a*dW1(1,1);
        newy = W2(1,1) + a*dW2(1,1);
      elseif(option == 2)
        newx = W1(1,1) + a*dW1(1,1);
        newy = b1(1)   + a*db1(1);
      else
        newx = b1(1) + a*db1(1);
        newy = b1(2) + a*db1(2);
      end
    
      if (option == 1)
        newx = W1(1,1) + b*dW1(1,1);
        newy = W2(1,1) + b*dW2(1,1);
      elseif(option == 2)
        newx = W1(1,1) + b*dW1(1,1);
        newy = b1(1)   + b*db1(1);
      else
        newx = b1(1) + b*db1(1);
        newy = b1(2) + b*db1(2);
      end
    
      % INITIALIZE C AND D
      c=a+tau1*(b-a);
      if (option == 1)
        newx = W1(1,1) + c*dW1(1,1); W1t(1,1) = newx;
        newy = W2(1,1) + c*dW2(1,1); W2t(1,1) = newy;
      elseif(option == 2)
        newx = W1(1,1) + c*dW1(1,1); W1t(1,1) = newx;
        newy = b1(1)   + c*db1(1);   b1t(1) = newy;
      else
        newx = b1(1) + c*db1(1);   b1t(1) = newx;
        newy = b1(2) + c*db1(2);   b1t(2) = newy;
      end
      fc = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
      d=b-tau1*(b-a);
      if (option == 1)
        newx = W1(1,1) + d*dW1(1,1); W1t(1,1) = newx;
        newy = W2(1,1) + d*dW2(1,1); W2t(1,1) = newy;
      elseif(option == 2)
        newx = W1(1,1) + d*dW1(1,1); W1t(1,1) = newx;
        newy = b1(1)   + d*db1(1);   b1t(1) = newy;
      else
        newx = b1(1) + d*db1(1);   b1t(1) = newx;
        newy = b1(2) + d*db1(2);   b1t(2) = newy;
      end
      fd = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
    
      % MINIMIZE ALONG A LINE
      k=0;
      while (b-a)>tol 
        if ( (fc<fd)&(fb>=min([fa fc fd])) ) | fa<min([fb fc fd])
          b=d; d=c; fb=fd;
          c=a+tau1*(b-a);
          fd=fc;
          if (option == 1)
            newx = W1(1,1) + c*dW1(1,1); W1t(1,1) = newx;
            newy = W2(1,1) + c*dW2(1,1); W2t(1,1) = newy;
          elseif(option == 2)
            newx = W1(1,1) + c*dW1(1,1); W1t(1,1) = newx;
            newy = b1(1)   + c*db1(1);   b1t(1) = newy;
          else
            newx = b1(1) + c*db1(1);   b1t(1) = newx;
            newy = b1(2) + c*db1(2);   b1t(2) = newy;
          end
          fc = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
    
        else
          a=c; c=d; fa=fc;
          d=b-tau1*(b-a);
          fc=fd;
          if (option == 1)
            newx = W1(1,1) + d*dW1(1,1); W1t(1,1) = newx;
            newy = W2(1,1) + d*dW2(1,1); W2t(1,1) = newy;
          elseif(option == 2)
            newx = W1(1,1) + d*dW1(1,1); W1t(1,1) = newx;
            newy = b1(1)   + d*db1(1);   b1t(1) = newy;
          else
            newx = b1(1) + d*db1(1);   b1t(1) = newx;
            newy = b1(2) + d*db1(2);   b1t(2) = newy;
          end
          fd = sumsqr(T - logsig(W2t*logsig(W1t*P+b1t*ones(1,Q))+b2t*ones(1,Q)));
        end
      end

      % UPDATE VARIABLES
      if (option == 1)
        newx = W1(1,1) + a*dW1(1,1); W1(1,1) = newx;
        newy = W2(1,1) + a*dW2(1,1); W2(1,1) = newy;
      elseif(option == 2)
        newx = W1(1,1) + a*dW1(1,1); W1(1,1) = newx;
        newy = b1(1)   + a*db1(1);   b1(1) = newy;
      else
        newx = b1(1) + a*db1(1);   b1(1) = newx;
        newy = b1(2) + a*db1(2);   b1(2) = newy;
      end
      xx(i) = newx;
      yy(i) = newy;
    
      % CALCULATE GRADIENT
      A1 = logsig(W1*P+b1*ones(1,Q));
      A2 = logsig(W2*A1+b2*ones(1,Q));
      E = T-A2;
      D2 = A2.*(1-A2).*E;
      D1 = A1.*(1-A1).*(W2'*D2);
      gW1 = D1*P';
      gb1 = D1*ones(Q,1);
      gW2 = D2*A1';
      gb2 = D2*ones(Q,1);
    
      % NORM SQUARE OF GRADIENT
      if (option == 1)
        nrmn = gW1(1,1)^2 + gW2(1,1)^2;
      elseif(option == 2)
        nrmn = gW1(1,1)^2 + gb1(1)^2;
      else
        nrmn = gb1(1)^2 + gb1(2)^2;
      end

      % CALCULATE DIRECTION
      if rem(i,n)==0
        Z=0;
      else
        Z=nrmn/nrmo;
      end

      % CALCULATE NEW DIRECTIONS
      dW1new = gW1 + dW1old*Z; db1new = gb1 + db1old*Z;
      dW2new = gW2 + dW2old*Z; db2new = gb2 + db2old*Z;

      % SAVE NEW DIRECTIONS
      dW1old = dW1new; db1old = db1new;
      dW2old = dW2new; db2old = db2new;
      nrmo=nrmn;

      %NORMALIZE DIRECTIONS
      if (option == 1)
        nrm = sqrt(dW1new(1,1)^2 + dW2new(1,1)^2);
      elseif(option == 2)
        nrm = sqrt(dW1new(1,1)^2 + db1new(1)^2);
      else
        nrm = sqrt(db1new(1)^2 + db1new(2)^2);
      end
      dW1=dW1new/nrm;db1=db1new/nrm;dW2=dW2new/nrm;db2=db2new/nrm;
    end

    % CONTOUR PLOT
    path = [path; plot(xx,yy,'color',nnred); plot(xx,yy,'o','color',nnred,'markersize',6)];
    set(fig,'nextplot','new')
    
    % SAVE DATA
    set(path_ptr,'userdata',path);
    set(fig,'pointer','arrow')

  end
end

    
