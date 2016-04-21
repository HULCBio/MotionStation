function nnd11fa(cmd,arg1)
% NND11FA Function approximation demonstration.
% This demonstration requires the Neural Network Toolbox.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.8 $
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd11fa';
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
  s1_bar = H(3);              % lr slider bar
  s1_text = H(4);             % lr text
  fa_axis = H(5);             % function approximation axis
  fa_ptr = H(6);              % function approximation plot handles
  i_bar = H(7);               % Difficulty slider bar
  i_text = H(8);              % Difficuly text
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

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Function Approximation','','Chapter 11');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(11,458,363,'shadow')

  % HIDDEN NEURONS SLIDER BAR
  s1 = 4;
  x = 20;
  y = 115;
  len = 320;
  text(x,y,'Number of Hidden Neurons S1:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  s1_text = text(x+len,y,num2str(s1),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'1',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'9',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  s1_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''s1'')'],...
    'min',1,...
    'max',9,...
    'value',s1);

  % PROBLEM DIFFICULTY SLIDER BAR
  i = 1;
  x = 20;
  y = 55;
  len = 320;
  text(x,y,'Difficulty Index:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  i_text = text(x+len,y,num2str(i),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'1',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'9',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  i_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''i'')'],...
    'min',1,...
    'max',9,...
    'value',i);

  % FUNCTION APPROXIMATION
  i = 1;
  P = -2:(.4/i):2;
  T = 1 + sin(pi*P/4);

  fa_axis = nnsfo('a2','Function Approximation','Input','Target','');
  set(fa_axis,...
    'position',[50 160 270 170],...
    'ylim',[0 2])
  fa_plot =  plot(P,T,'color',nnred,'linewidth',3);

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[400 145 60 20],...
    'string','Train',...
    'callback',[me '(''train'')'])
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
  fa_ptr = uicontrol('visible','off','userdata',fa_plot);

  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text s1_bar s1_text fa_axis fa_ptr i_bar i_text];
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
    'Click the [Train]',...
    'button to train the',...
    'logsig-linear',...
    'network on the',...
    'function at left.',...
    '',...
    'Use the slide bars',...
    'to choose the',...
    'number of neurons',...
    'in the hidden layer',...
    'and the difficulty',...
    'of the function.')
    

%==================================================================
% Respond to hidden neuron slider.
%
% ME('i')
%==================================================================

elseif strcmp(cmd,'s1')
  
  i = get(i_bar,'value');
  s1 = get(s1_bar,'value');
  s1 = round(s1);
  set(s1_text,'string',sprintf('%g',s1))

  set(fig,'nextplot','add')
  delete(get(fa_axis,'children'))
  P = -2:(.4/i):2;
  T = 1 + sin(i*pi*P/4);
  axes(fa_axis)
  plot(P,T,'color',nnred,'linewidth',3);
  set(get(fa_axis,'ylabel'),...
    'string','Target')
  set(fig,'nextplot','new')

%==================================================================
% Respond to difficulty index slider.
%
% ME('s1')
%==================================================================

elseif strcmp(cmd,'i')
  
  i = get(i_bar,'value');
  i = round(i);
  set(i_text,'string',sprintf('%g',i))
  
  set(fig,'nextplot','add')
  delete(get(fa_axis,'children'))
  P = -2:(.4/i):2;
  T = 1 + sin(i*pi*P/4);
  axes(fa_axis)
  plot(P,T,'color',nnred,'linewidth',3);
  set(get(fa_axis,'ylabel'),...
    'string','Target')
  set(fig,'nextplot','new')

%==================================================================
% Respond to train button.
%
% ME('train')
%==================================================================

elseif strcmp(cmd,'train') & (fig) & (nargin == 1)

  set(fig,'nextplot','add')
  
  set(fig,'pointer','watch')
  
  i = round(get(i_bar,'value'));

  P = -2:(.4/i):2;
  T = 1 + sin(i*pi*P/4);
  [R,Q] = size(P);
  P2 = P;
  [R,Q2] = size(P2);

  S1 = round(get(s1_bar,'value'));
  R = 1;
  S2 = 1;

  W10 = rands(S1,1);
  B10 = rands(S1,1);
  W20 = rands(1,S1);
  B20 = rands(1,1);
  
  err_goal = 0.005;
  max_epoch = 200;
  mingrad=0.001;
  mu_initial=.01;
  v=10;
  maxmu=1e10;

  axes(fa_axis)
  set(get(fa_axis,'children'),'erasemode','normal');
  delete(get(fa_axis,'children'))
  A = W20*logsig(W10*P2+B10*ones(1,Q2))+B20*ones(1,Q2);
  Target = plot(P,T,'-','color',nnred,'linewidth',3,'erasemode','none');

  AA = A;
  ind = find((AA < 0) | (AA > 2));
  if length(ind)
    AA(ind) = AA(ind)+NaN;
  end
  Attempt = plot(P2,AA,'-','color',nndkblue,'linewidth',2,'erasemode','none');
  drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%% BEGINNING OF MARTIN'S CODE

% DEFINE SIZES
RS = S1*R; RS1 = RS+1; RSS = RS + S1; RSS1 = RSS + 1;
RSS2 = RSS + S1*S2; RSS3 = RSS2 + 1; RSS4 = RSS2 + S2;

%%%%%%%%%%%%%%%%%%%%%%%%%%

W1=W10;B1=B10;W2=W20;B2=B20;
dW1=W10;dB1=B10;dW2=W20;dB2=B20;

%%%%%%%%%%%%%%%%%%%%%%%%%%

mu=mu_initial;
ii=eye(RSS4);
meu=zeros(max_epoch,1);
mer=meu;grad=meu;
A1 = logsig(W1*P+B1*ones(1,Q));
A2 = W2*A1+B2*ones(1,Q);
E1 = T-A2;
f1=sumsqr(E1);
flops(0);

% MAIN LOOP

t1=clock;
for k=1:max_epoch,
  mu=mu/v;
  mer(k)=f1;
  meu(k)=mu;
  tst=1;

% FIND JACOBIAN
  A1 = kron(A1,ones(1,S2));
  D2 = nnmdlin(A2);
  D1 = nnmdlog(A1,D2,W2);
  jac1 = nnlmarq(kron(P,ones(1,S2)),D1);
  jac2 = nnlmarq(A1,D2);
  jac=[jac1,D1',jac2,D2'];

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
    dW1(:)=dw(1:RS);
    dB1=dw(RS1:RSS);
    dW2(:)=dw(RSS1:RSS2);
    dB2=dw(RSS3:RSS4);
    W1n=W1+dW1;B1n=B1+dB1;W2n=W2+dW2;
    B2n=B2+dB2;
    A1 = logsig(W1n*P+B1n*ones(1,Q));
    A2 = W2n*A1+B2n*ones(1,Q);
    E2 = T-A2;
    f2=sumsqr(E2);  
    if f2>=f1,
      mu=mu*v;

%  TEST FOR MAXIMUM mu
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


%  TEST IF THE ERROR REACHES THE ERROR GOAL
  if f2<=err_goal,
    f1=f2;
    W1=W1n;B1=B1n;W2=W2n;B2=B2n;
    mer=[mer(1:k);f2];
    meu=[meu(1:k);mu];
    grad=grad(1:k);
    disp('Training has stopped. Goal achieved.')
    break; 
  end

  if(mu>maxmu),
    break;
  end

  W1=W1n;B1=B1n;W2=W2n;B2=B2n;E1=E2;
  f1=f2;

  %%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING ALTERED BY MARK
  if (R==1)&(S2==1),
    A = W2*logsig(W1*P2+B1*ones(1,Q2))+B2*ones(1,Q2);
    set(Attempt,'color',nnltyell);
    set(Attempt,'visible','off');
    set(Target,'color',nnred);

    AA = A;
    ind = find((AA < 0) | (AA > 2));
    if length(ind)
      AA(ind) = AA(ind)+NaN;
    end
    set(Attempt,'ydata',AA);
    set(Attempt,'color',nndkblue,'visible','on');
    drawnow
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%% END OF MARTIN'S CODE

    A = W2*logsig(W1*P2+B1*ones(1,Q2))+B2*ones(1,Q2);
    set(Attempt,'color',nnltyell);
    set(Attempt,'visible','off');
    set(Target,'color',nnred);

    AA = A;
    ind = find((AA < 0) | (AA > 2));
    if length(ind)
      AA(ind) = AA(ind)+NaN;
    end
    set(Attempt,'ydata',AA);
    set(Attempt,'color',nndkblue,'visible','on');
    drawnow

  set(fig,'nextplot','new')
  
  if (k==max_epoch),
    disp('Training has stopped.')
    disp('Maximum number of epochs was reached.')
    fprintf('epochs = %g.\n',k);
    fprintf('Final error = %g.\n',f2);
  end

  set(fig,'pointer','arrow')

end

