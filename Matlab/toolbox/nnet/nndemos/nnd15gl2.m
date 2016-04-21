function nnd15gl2(cmd,arg1,arg2,arg3)
%NND15GL2 Grossberg layer 2 demonstration.

% $Revision: 1.7 $ $Date: 2002/04/14 21:23:33 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.

%==================================================================

% GLOBALS
global p;
global tf;
global W2;

% CONSTANTS
Fs = 8192;
W1p = eye(2);
W1n = ones(2)-eye(2);

% DEFAULTS
if nargin == 0, cmd = ''; else cmd = lower(cmd); end

% FIND WINDOW IF IT EXISTS
fig = nndfgflg(mfilename);
if length(get(fig,'children')) == 0, fig = 0; end

% GET WINDOW DATA IF IT EXISTS
if fig
  H = get(fig,'userdata');
  fig_axis = H(1);         % window axis
  desc_text = H(2);        % handle to first line of text sequence
  big_axis = H(3);         % Big axis
  pp_bar = H(4);
  pp_text = H(5);
  pn_bar = H(6);
  pn_text = H(7);
  edit_w11 = H(8);
  edit_w12 = H(9);
  edit_w21 = H(10);
  edit_w22 = H(11);
  tf_menu = H(12);
  old_ptr = H(13);
  last_ptr = H(14);
  big_lines = H(15);
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
    feval(mfilename,'init')
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
  tf = 2;
  W2 = [0.9 0.45; 0.45 0.9];

  % NEW DEMO FIGURE
  fig = nndemof2(mfilename,'DESIGN','Grossberg Layer 2','','Chapter 15');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(mfilename,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(15,458,363,'shadow')

  % FIRST INPUT SLIDER BAR
  x = 40;
  y = 150;
  len = 140;
  text(x,y,'Input a1(1):',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  pp_text = text(x+len,y,sprintf('%3.1f',pp),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  pp_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[mfilename '(''pp'')'],...
    'min',0,...
    'max',10,...
    'value',pp);

  % SECOND INPUT SLIDER BAR
  x = 40;
  y = 96;
  len = 140;
  text(x,y,'Input: a1(2)',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  pn_text = text(x+len,y,sprintf('%3.1f',pn),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-36,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-36,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  pn_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[mfilename '(''pn'')'],...
    'min',0,...
    'max',10,...
    'value',pn);

  % WEIGHTS
  x = 250;
  y = 75;
  bracket_x = [1 0 0 1]*10;
  bracket_y = [0 0 1 1]*10;
  text(x-5,y+35,'W2=','fontsize',20,...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right')
  plot(bracket_x+x,bracket_y*7+y,...
    'color',nndkblue,...
    'linewidth',3);
  plot(-bracket_x+x+100,bracket_y*7+y,'color',nndkblue,'linewidth',3);
  edit_w11 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+40 35 20],...
    'string',num2str(W2(1,1)),...
    'callback',nncallbk(mfilename,'w11'));
  edit_w12 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+55 y+40 35 20],...
    'string',num2str(W2(1,2)),...
    'callback',nncallbk(mfilename,'w12'));
  edit_w21 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+10 y+10 35 20],...
    'string',num2str(W2(2,1)),...
    'callback',nncallbk(mfilename,'w21'));
  edit_w22 = uicontrol(...
    'units','points',...
    'style','edit',...
    'position',[x+55 y+10 35 20],...
    'string',num2str(W2(2,2)),...
    'callback',nncallbk(mfilename,'w22'));

  % TRANSFER FUNCTION
  x = 180;
  y = 25;
  text(x-5,y+10,'Transfer Function:',...
    'fontweight','bold',...
    'color',nndkblue,...
    'horiz','right');
  tf_menu = uicontrol(...
    'units','points',...
    'position',[x y 140 20],...
    'style','popup',...
    'string','purelin|(10n^2)/(1+n^2)|10n^2|1-exp(-n)',...
    'value',tf);

  % BIG AXES
  big_axis = nnsfo('a1','Response','Time','Net Inputs n2(1) & n2(2)');
  set(big_axis,...
    'position',[50 190 300 140],...
    'xlim',[-0.01 0.51],...
    'xtick',0:0.1:0.5,...
    'ylim',[-0.1 1.1],...
    'ytick',0:0.25:1)
  big_lines = plot([0.25 0.25 NaN -0.01 0.51],[-0.1 1.1 NaN 0 0],'--',...
    'color',nndkblue);

  % PLOT RESPONSE
  p = [pp; pn];
  [T1,Y1] = ode45('nndlay2',[0 0.25],[0;0]);
  p = [0; 0];
  [T2,Y2] = ode45('nndlay2',[0.25 0.5],Y1(size(Y1,1),:)');
  T = [T1' T2'];
  Y = [Y1' Y2'];

  set(fig,'nextplot','add')
  last1 = plot(T,Y(1,:),...
    'color',nnred,...
    'linewidth',2);
  last2 = plot(T,Y(2,:),...
    'color',nngreen,...
    'linewidth',2);
  last = [last1; last2];

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 165 60 20],...
    'string','Update',...
    'callback',[mfilename '(''update'')'])
  uicontrol(...
    'units','points',...
    'position',[410 130 60 20],...
    'string','Clear',...
    'callback',[mfilename '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[410 95 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[410 60 60 20],...
    'string','Close',...
    'callback',[mfilename '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  old_ptr = uicontrol('visible','off','userdata',[]);
  last_ptr = uicontrol('visible','off','userdata',last);

  H = [fig_axis, ...
       desc_text,...
       big_axis, ...
       pp_bar pp_text pn_bar pn_text, ...
       edit_w11 edit_w12 edit_w21 edit_w22 tf_menu,...
       old_ptr, last_ptr, ...
       big_lines];

  set(fig,'userdata',H,'nextplot','new')

  % INSTRUCTION TEXT
  feval(mfilename,'instr');

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
    'Use the slider bars',...
    'to adjust the inputs,',...
    'weights and transfer',...
    'function.',...
    '',...
    'Output n2(1) is',...
    'in red, output n2(2)',...
    'is shown as green.',...
    '',...
    'Click [Clear] to',...
    'remove old',...
    'responses.')
    
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
  delete(old);

  % SAVE DATA
  set(old_ptr,'userdata',[]);

%==================================================================
% Respond to excitatory input slider.
%
% ME('pp')
%==================================================================

elseif strcmp(cmd,'pp')
  
  % GET DATA
  pp = get(pp_bar,'value');

  % UPDATE BAR
  set(pp_text,'string',sprintf('%3.1f',pp))

%==================================================================
% Respond to inhibitory input slider.
%
% ME('pn')
%==================================================================

elseif strcmp(cmd,'pn')
  
  % GET DATA
  pn = get(pn_bar,'value');

  % UPDATE BAR
  set(pn_text,'string',sprintf('%3.1f',pn))

%==================================================================
% Respond to weight value change.
%
% ME('w11')
%==================================================================

elseif strcmp(cmd,'w11')
  
  % GET DATA
  w11 = str2num(get(edit_w11,'string'));

  % UPDATE BAR
  set(edit_w11,'string',sprintf('%3.2f',w11))

%==================================================================
% Respond to weight value change.
%
% ME('w12')
%==================================================================

elseif strcmp(cmd,'w12')
  
  % GET DATA
  w12 = str2num(get(edit_w12,'string'));

  % UPDATE BAR
  set(edit_w12,'string',sprintf('%3.2f',w12))

%==================================================================
% Respond to weight value change.
%
% ME('w21')
%==================================================================

elseif strcmp(cmd,'w21')
  
  % GET DATA
  w21 = str2num(get(edit_w21,'string'));

  % UPDATE BAR
  set(edit_w21,'string',sprintf('%3.2f',w21))

%==================================================================
% Respond to weight value change.
%
% ME('w22')
%==================================================================

elseif strcmp(cmd,'w22')
  
  % GET DATA
  w22 = str2num(get(edit_w22,'string'));

  % UPDATE BAR
  set(edit_w22,'string',sprintf('%3.2f',w22))

end

%==================================================================
% Respond to time constant slider.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update')

  % GET DATA
  pp = get(pp_bar,'value');
  pn = get(pn_bar,'value');
  W2 = [str2num(get(edit_w11,'string')),...
        str2num(get(edit_w12,'string'));
        str2num(get(edit_w21,'string')),...
        str2num(get(edit_w22,'string'))];
  tf = get(tf_menu,'value');
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
  p = [pp; pn];
  [T1,Y1] = ode45('nndlay2',[0 0.25],[0;0]);
  p = [0; 0];
  [T2,Y2] = ode45('nndlay2',[0.25 0.5],Y1(size(Y1,1),:)');
  T = [T1' T2'];
  Y = [Y1' Y2'];

  set(fig,'nextplot','add')
  axes(big_axis)
  last1 = plot(T,Y(1,:),...
    'color',nnred,...
    'linewidth',2);
  last2 = plot(T,Y(2,:),...
    'color',nngreen,...
    'linewidth',2);
  last = [last1; last2];
  set(fig,'nextplot','new')

  set(big_lines,'color',nndkblue);
  drawnow

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

end

