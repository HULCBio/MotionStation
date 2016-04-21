function nnd13edr(cmd,arg1,arg2,arg3)
%NND13EDR Effects of decay rate demonstration.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd13edr';
Fs = 8192;

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
  lr_bar = H(4);
  lr_text = H(5);
  dr_bar = H(6);
  dr_text = H(7);
  old_ptr = H(8);
  last_ptr = H(9);
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

  % CHECK FOR TRANSFER FUNCTIONS
  if ~nnfexist(me), return, end

  % CONSTANTS
  lr = 1;
  dr = 0.1;

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Effects of Decay Rate','','Chapter 13');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(13,458,363,'shadow')

  % LR BAR BAR
  x = 40;
  y = 60;
  len = 140;
  text(x,y,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  lr_text = text(x+len,y,sprintf('%4.2f',lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  lr_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''lr'')'],...
    'min',0,...
    'max',1,...
    'value',lr);

  % DR BAR
  x = 210;
  y = 60;
  len = 140;
  text(x,y,'Decay Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  dr_text = text(x+len,y,sprintf('%4.2f',dr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  dr_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''dr'')'],...
    'min',0,...
    'max',1,...
    'value',dr);

  % BIG AXES
  big_axis = nnsfo('a1','Hebb Learning','Time','Weight');
  set(big_axis,...
    'position',[50 110 300 220],...
    'xlim',[-0.5 30.5],...
    'xtick',0:2:30,...
    'ylim',[-0.3 10.3],...
    'ytick',0:2:10)

  w = 0;
  wtot = [w];
  for i=1:30,
    a = feval('hardlim',1*(rem(i,2)==0)+w*1-0.5);
    w = w+lr*a*1-dr*w;
    wtot=[wtot w];
  end
  last = plot(0:30,wtot,'o',...
    'color',nnred,...
    'markersize',5,...
    'erasemode','none');

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[410 165 60 20],...
    'string','Clear',...
    'callback',[me '(''clear'')'])
  uicontrol(...
    'units','points',...
    'position',[410 130 60 20],...
    'string','Random',...
    'callback',[me '(''random'')'])
  uicontrol(...
    'units','points',...
    'position',[410 95 60 20],...
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
       lr_bar lr_text dr_bar dr_text,...
       old_ptr, last_ptr];

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
    'Use the slider bars',...
    'to adjust learning',...
    'and decay rates.',...
    '',...
    'Click [Clear] to',...
    'remove old responses.',...
    'Click [Random] to get',...
    'random parameters.')
    
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
  drawnow
  set(last,'color',nnred)
  drawnow
  delete(old);

  % NEW LINE

  % SAVE DATA
  set(old_ptr,'userdata',[]);

%==================================================================
% Respond to random button
%
% ME('random')
%==================================================================

elseif strcmp(cmd,'random')
  
  % GET DATA
  lr = rand;
  dr = rand;
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(lr_bar,'value',lr);
  set(dr_bar,'value',dr);
  set(lr_text,'string',sprintf('%4.2f',lr))
  set(dr_text,'string',sprintf('%4.2f',dr))

  % MAKE LAST LINE OLD
  set(last,'color',nndkgray);
  old = [old; last];
  if length(old) > 3
    gone = old(1);
    old(1) = [];
  else
    gone = [];
  end
  set(old,'color',nnltgray)
  set(gone,'color',nnltyell);
  drawnow
  delete(gone);

  % NEW LINE
  set(fig,'nextplot','add')
  axes(big_axis)
  w = 0;
  wtot = [w];
  for i=1:30,
    a = feval('hardlim',1*(rem(i,2)==0)+w*1-0.5);
    w = w+lr*a*1-dr*w;
    wtot=[wtot w];
  end
  ind = find(wtot > 10);
  if length(ind)
     ind = ind(1);
   wtot = wtot(1:(ind-1));
  end
  last = plot(0:(length(wtot)-1),wtot,'o',...
    'color',nnred,...
    'markersize',5,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

%==================================================================
% Respond to lr bar.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr')
  
  % GET DATA
  lr = get(lr_bar,'value');
  dr = get(dr_bar,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(lr_text,'string',sprintf('%4.2f',lr))

  % MAKE LAST LINE OLD
  set(last,'color',nndkgray);
  old = [old; last];
  if length(old) > 3
    gone = old(1);
    old(1) = [];
  else
    gone = [];
  end
  set(old,'color',nnltgray)
  set(gone,'color',nnltyell);
  drawnow
  delete(gone);

  % NEW LINE
  set(fig,'nextplot','add')
  axes(big_axis)
  w = 0;
  wtot = [w];
  for i=1:30,
    a = feval('hardlim',1*(rem(i,2)==0)+w*1-0.5);
    w = w+lr*a*1-dr*w;
    wtot=[wtot w];
  end
  ind = find(wtot > 10);
  if length(ind)
     ind = ind(1);
   wtot = wtot(1:(ind-1));
  end
  last = plot(0:(length(wtot)-1),wtot,'o',...
    'color',nnred,...
    'markersize',5,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

%==================================================================
% Respond to decay rate bar.
%
% ME('dr')
%==================================================================

elseif strcmp(cmd,'dr')
  
  % GET DATA
  lr = get(lr_bar,'value');
  dr = get(dr_bar,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(dr_text,'string',sprintf('%4.2f',dr))

  % MAKE LAST LINE OLD
  set(last,'color',nndkgray);
  old = [old; last];
  if length(old) > 3
    gone = old(1);
    old(1) = [];
  else
    gone = [];
  end
  set(gone,'color',nnltyell);
  set(old,'color',nnltgray)
  drawnow
  delete(gone);

  % NEW LINE
  set(fig,'nextplot','add')
  axes(big_axis)
  w = 0;
  wtot = [w];
  for i=1:30,
    a = feval('hardlim',1*(rem(i,2)==0)+w*1-0.5);
    w = w+lr*a*1-dr*w;
    wtot=[wtot w];
  end
  ind = find(wtot > 10);
  if length(ind)
     ind = ind(1);
   wtot = wtot(1:(ind-1));
  end
  last = plot(0:(length(wtot)-1),wtot,'o',...
    'color',nnred,...
    'markersize',5,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

end
