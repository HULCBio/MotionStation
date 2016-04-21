function nnd15li(cmd,arg1,arg2,arg3)
%NND15LI Leaky integrator demonstration.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd15li';
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
  p_bar = H(4);
  p_text = H(5);
  e_bar = H(6);
  e_text = H(7);
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

  % CONSTANTS
  p = 1;
  e = 1;

  % NEW DEMO FIGURE
  fig = nndemof2(me,'DESIGN','Leaky Integrator','','Chapter 15');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(15,458,363,'shadow')

  % INPUT SLIDER BAR
  x = 40;
  y = 60;
  len = 140;
  text(x,y,'Input p:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  p_text = text(x+len,y,sprintf('%3.1f',p),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'10.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  p_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''input'')'],...
    'min',0,...
    'max',10,...
    'value',p);

  % TIME CONSTANT SLIDER BAR
  x = 210;
  y = 60;
  len = 140;
  text(x,y,'Time Constant:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  e_text = text(x+len,y,sprintf('%3.1f',e),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  text(x,y-38,'0.1',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','left')
  text(x+len,y-38,'5.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',12,...
    'horizontalalignment','right');
  e_bar = uicontrol(...
    'units','points',...
    'position',[x y-25 len 16],...
    'style','slider',...
    'backg',nnltgray,...
    'callback',[me '(''time'')'],...
    'min',0.1,...
    'max',5,...
    'value',e);

  % BIG AXES
  big_axis = nnsfo('a1','Response','Time','Output n');
  set(big_axis,...
    'position',[50 110 300 220],...
    'xlim',[-0.1 5.1],...
    'xtick',0:5,...
    'ylim',[-0.3 10.3],...
    'ytick',0:2:10)
  t = 0:0.1:5;
  y0 = p*(1-exp(-t/e));
  last = plot(t,y0,...
    'color',nnred,...
    'linewidth',2,...
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
       p_bar p_text e_bar e_text,...
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
    'to adjust the input',...
    'and time constant',...
    '(eps) to the leaky',...
    'integrator.',...
    '',...
    'Click [Clear] to',...
    'remove old',...
    'responses.',...
    'Click [Random] for',...
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
  min = get(p_bar,'min');
  max = get(p_bar,'max');
  p = rand*(max-min)+min;
  min = get(e_bar,'min');
  max = get(e_bar,'max');
  e = rand*(max-min)+min;
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(p_bar,'value',p);
  set(e_bar,'value',e);
  set(p_text,'string',sprintf('%3.1f',p))
  set(e_text,'string',sprintf('%3.1f',e))

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
  t = 0:0.1:5;
  y0 = p*(1-exp(-t/e));
  last = plot(t,y0,...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

%==================================================================
% Respond to input slider.
%
% ME('input')
%==================================================================

elseif strcmp(cmd,'input')
  
  % GET DATA
  p = get(p_bar,'value');
  e = get(e_bar,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(p_text,'string',sprintf('%3.1f',p))

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
  t = 0:0.1:5;
  y0 = p*(1-exp(-t/e));
  last = plot(t,y0,...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

%==================================================================
% Respond to time constant slider.
%
% ME('time')
%==================================================================

elseif strcmp(cmd,'time')
  
  % GET DATA
  p = get(p_bar,'value');
  e = get(e_bar,'value');
  old = get(old_ptr,'userdata');
  last = get(last_ptr,'userdata');

  % UPDATE BAR
  set(e_text,'string',sprintf('%3.1f',e))

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
  t = 0:0.1:5;
  y0 = p*(1-exp(-t/e));
  last = plot(t,y0,...
    'color',nnred,...
    'linewidth',2,...
    'erasemode','none');
  set(fig,'nextplot','new')

  % SAVE DATA
  set(old_ptr,'userdata',old);
  set(last_ptr,'userdata',last);

end
