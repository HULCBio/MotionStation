function nnd15aw(cmd,arg1,arg2,arg3)
%NND15AW Adaptive weights demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% GLOBALS
global n1_1;
global n1_2;
global lr;

% CONSTANTS
me = 'nnd15aw';
Fs = 8192;
W1p = eye(2);
W1n = ones(2)-eye(2);

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end

% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  fig_axis = H(1);         % window axis
  desc_text = H(2);        % handle to first line of text sequence
  big_axis = H(3);         % Big axis
  edit_n11 = H(4);
  edit_n12 = H(5);
  edit_n21 = H(6);
  edit_n22 = H(7);
  lr_menu = H(8);
  old_ptr = H(9);
  last_ptr = H(10);
  big_lines = H(11);
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
  pp = 1;
  pn = 0;
  lr = 1;
  n1_1 = [0.9; 0.45];
  n1_2 = [0.45; 0.9];       

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Adaptive Weights','','Chapter 15');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(15,458,363,'shadow')

  % NET INPUT #1
  x = 110;
  y = 60;
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  text(x-5,y+35,'1st n1=','fontsize',20,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right')
  plot(bracket_x+x,bracket_y*7+y,...
    'color',nndkblue,...
    'linewidth',3);
  plot(-bracket_x+x+55,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  edit_n11 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+40 35 20],...
    'string',num2str(n1_1(1)),...
    'callback',nncallbk(me,'n11'));
  edit_n21 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+10 35 20],...
    'string',num2str(n1_1(2)),...
    'callback',nncallbk(me,'n21'));

  % NET INPUT #2
  x = 290;
  y = 60;
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  text(x-5,y+35,'2nd n1=','fontsize',20,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right')
  plot(bracket_x+x,bracket_y*7+y,...
    'color',nndkblue,...
    'linewidth',3);
  plot(-bracket_x+x+55,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  edit_n12 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+40 35 20],...
    'string',num2str(n1_2(1)),...
    'callback',nncallbk(me,'n12'));
  edit_n22 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+10 35 20],...
    'string',num2str(n1_2(2)),...
    'callback',nncallbk(me,'n22'));

  % LEARNING RULE
  x = 210;
  y = 20;
  text(x-5,y+10,'Learning Rule:',...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right');
  lr_menu = uicontrol(...
    'units','points',...
    'position',[x y 80 20],...
    'style','popup',...
    'string','Instar|Hebb',...
    'value',lr);

  % BIG AXES
  big_axis = nnsfo('a1','Learning','Time','Weights W2');
  set(big_axis,...
    'position',[50 170 300 170],...
    'xlim',[-0.09 2.09],...
    'xtick',0:0.5:2,...
    'ylim',[-0.3 1.1],...
    'ytick',0:0.25:1)
  xx = [1 1 NaN];
  xx = [0:0.2:2]'*xx;
  yy = [-0.3 1.1 NaN];
  yy = yy(ones(length(xx),1),:);
  xx = xx';
  yy = yy';
  xx = xx(:);
  yy = yy(:);
  big_lines = plot(xx,yy,'--',...
    'color',nndkblue,...
    'erasemode','none');
  for t=0.1:0.2:2
    if (rem(fix(t/0.2),2)==0)
      str = '1st';
    else
      str = '2nd';
    end
    text(t,-0.2,str,...
      'color',nndkblue,...
      'horiz','center',...
      'fontsize',9,...
      'erasemode','none')
  end

  % PLOT RESPONSE
  options = odeset('RelTol',1e-4);
  [T,Y] = ode45('nndadapt',[0 2],zeros(1,4),options);
  T = T';
  Y = Y';

  set(fig,'nextplot','add')
  last1 = plot(T,Y(1,:),...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');
  last2 = plot(T,Y(3,:),'--',...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');
  last3 = plot(T,Y(2,:),...
    'color',nngreen,...
    'linewidth',2,...
    'erasemode','none');
  last4 = plot(T,Y(4,:),'--',...
    'color',nngreen,...
    'linewidth',2,...
    'erasemode','none');
  last = [last1; last2; last3; last4];

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 150 60 20],...
    'string','Update',...
    'callback',[me '(''update'')'])
  uicontrol(...
    'units','points',...
    'position',[410 120 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[410 90 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 60 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  old_ptr = uicontrol('visible','off','userdata',[]);
  last_ptr = uicontrol('visible','off','userdata',last);

  H = [fig_axis, ...
       desc_text,...
       big_axis, ...
       edit_n11 edit_n12 edit_n21 edit_n22 lr_menu,...
       old_ptr, last_ptr, ...
       big_lines];

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(me,'instr');

  % LOCK WINDOW
  set(fig,...
   'nextplot','new',...
   'color',nnltgray);

  nnchkfs;

%==================================================================
% Display the instructions.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'instr') & (fig)
  nnsettxt(desc_text,...
    'Edit the two input',...
    'vectors and press,',...
    '[Update] to see the',...
    'network learn them.',...
    '',...
    'W2(1,1) - solid red',...
    'W2(1,2) - broken red',...
    '',...
    'W2(2,1) - solid green',...
    'W2(2,2) - broken green',...
    '',...
    'Click [Clear] to',...
    'remove old responses.')
    
%==================================================================
% Clear input vectors.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig) & (nargin == 1)
  
  % GET DATA
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % REMOVE OLD
  set(old,'color',nnltyell);
  set(last([1 3]),'color',nnred)
  set(last([2 4]),'color',nngreen)
  set(big_lines,'color',nndkblue);
  drawnow
  delete(old);

  % NEW LINE

  % SAVE DATA
  set(old_ptr,'userdata',[]);

%==================================================================
% Respond to input change.
%
% ME('wn11')
%==================================================================

elseif strcmp(cmd,'n11')
  
  % GET DATA
  n11 = str2num(get(edit_n11,'string'));

  % UPDATE BAR
  set(edit_n11,'string',sprintf('%3.2f',n11))

%==================================================================
% Respond to input change.
%
% ME('w12')
%==================================================================

elseif strcmp(cmd,'n12')
  
  % GET DATA
  n12 = str2num(get(edit_n12,'string'));

  % UPDATE BAR
  set(edit_n12,'string',sprintf('%3.2f',n12))

%==================================================================
% Respond to input change.
%
% ME('n21')
%==================================================================

elseif strcmp(cmd,'n21')
  
  % GET DATA
  n21 = str2num(get(edit_n21,'string'));

  % UPDATE BAR
  set(edit_n21,'string',sprintf('%3.2f',n21))

%==================================================================
% Respond to input change.
%
% ME('n22')
%==================================================================

elseif strcmp(cmd,'n22')
  
  % GET DATA
  n22 = str2num(get(edit_n22,'string'));

  % UPDATE BAR
  set(edit_n22,'string',sprintf('%3.2f',n22))

end

%==================================================================
% Update figure.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update')

  % GET DATA
  n1_1 = [str2num(get(edit_n11,'string'));
          str2num(get(edit_n21,'string'))];
  n1_2 = [str2num(get(edit_n12,'string'));
          str2num(get(edit_n22,'string'))];
  lr = get(lr_menu,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % MAKE LAST LINE OLD
  set(last,'color',nndkgray);
  old = [old last];
  if size(old,2) > 1
    gone = old(:,1);
    old(:,1) = [];
  else
    gone = [];
  end
  set(gone,'color',nnltyell);
  set(old,'color',nnltgray)
  set(big_lines,'color',nndkblue);
  drawnow
  delete(gone);

  % PLOT RESPONSE
  options = odeset('RelTol',1e-4);
  [T,Y] = ode45('nndadapt',[0 2],zeros(1,4),options);
  T = T';
  Y = Y';

  set(fig,'nextplot','add')
  axes(big_axis)

  ind = find(Y(1,:) < -0.3 | Y(1,:) > 1.1);
  if length(ind) == 0
    ind = length(T);
  else
    ind = ind(1)-1;
  end
  last1 = plot(T(1:ind),Y(1,1:ind),...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');

  ind = find(Y(3,:) < -0.3 | Y(3,:) > 1.1);
  if length(ind) == 0
    ind = length(T);
  else
    ind = ind(1)-1;
  end
  last2 = plot(T(1:ind),Y(3,1:ind),'--',...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');

  ind = find(Y(2,:) < -0.3 | Y(2,:) > 1.1);
  if length(ind) == 0
    ind = length(T);
  else
    ind = ind(1)-1;
  end
  last3 = plot(T(1:ind),Y(2,1:ind),...
    'color',nngreen,...
    'linewidth',2,...
    'erasemode','none');

  ind = find(Y(4,:) < -0.3 | Y(4,:) > 1.1);
  if length(ind) == 0
    ind = length(T);
  else
    ind = ind(1)-1;
  end
  last4 = plot(T(1:ind),Y(4,1:ind),'--',...
    'color',nngreen,...
    'linewidth',2,...
    'erasemode','none');
  last = [last1; last2; last3; last4];
  set(fig,'nextplot','new')

  set(big_lines,'color',nndkblue);
  drawnow

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

end

