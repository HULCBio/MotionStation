function nnd13gis(cmd,arg1,arg2,arg3)
%NND13GIS Graphical instar demonstration.
%
%  This demonstration requires either the MININNET functions
%  on the NND disk or the Neural Network Toolbox.

% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

% CONSTANTS
me = 'nnd13gis';
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
  w_axis = H(3);           % Weight axis
  w_cross = H(4);          % Weight cross
  p_axis = H(5);           % Input axis
  p_cross = H(6);          % Input cross
  W_ptr = H(7);            % Weights
  WV_ptr = H(8);           % Weight axis handles
  P_ptr = H(9);            % Inputs
  PV_ptr = H(10);          % Input axis handles
  lr_bar = H(11);          % Learning rate slider bar
  lr_text = H(12);         % Learning rate text
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

  % NEW DEMO FIGURE
  fig = nndemof(me,'DESIGN','Graphical Instar','','Chapter 13');

  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(13,458,363,'shadow')

  % LEARNING RATE SLIDER BAR
  lr = 0.5;
  x = 35;
  y = 48;
  len = 355;
  text(x,y-2,'Learning Rate:',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  lr_text = text(x+len,y-2,num2str(lr),...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','right');
  text(x,y-34,'0.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
    'horizontalalignment','left')
  text(x+len,y-34,'1.0',...
    'color',nndkblue,...
    'fontw','bold',...
    'fontsize',10,...
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

  % WEIGHT AXES
  w_axis = nnsfo('a1','Click to Change Weight','','');
  set(w_axis,...
    'position',[35 140 170 170],...
    'xlim',[-1.1 1.1],...
    'ylim',[-1.1 1.1],...
    'xtick',[-1:0.5:1],...
    'ytick',[-1:0.5:1],...
    'xticklabel',[],...
    'yticklabel',[])
  angle = [0:5:360]*pi/180;
  angle2 = fliplr(angle);
  w_cross = plot([-1 1 NaN 0 0],[0 0 NaN -1 1],'--',...
    'color',nndkblue,...
    'erasemode','none');
  view(2);
  W = [1 0.5];
  WV = nndrwvec(W(1),W(2),2,0.1,nngreen,'','none');

  % INPUT AXES
  p_axis = nnsfo('a1','Click to Change Input','','');
  set(p_axis,...
    'position',[220 140 170 170],...
    'xlim',[-1.1 1.1],...
    'ylim',[-1.1 1.1],...
    'xtick',[-1:0.5:1],...
    'ytick',[-1:0.5:1],...
    'xticklabel',[],...
    'yticklabel',[])
  angle = [0:5:360]*pi/180;
  angle2 = fliplr(angle);
  p_cross = plot([-1 1 NaN 0 0],[0 0 NaN -1 1],'--',...
    'color',nndkblue,...
    'erasemode','none');
  view(2);
  P = [0.5; 1];

  W2 = W + (lr*1*ones(1,2)).*(P'-W);

  PV = [nndrwvec(W(1),W(2),2,0.1,nngreen,'','none');
        nndrwvec(P(1),P(2),2,0.1,nnred,'','none');
        nndrwvec([W(1) P(1)],[W(2) P(2)],1,0,nndkblue,'','none');
        nndrwvec([W(1) W2(1)],[W(2) W2(2)],2,0.1,nndkblue,'','none')];

  % BUTTONS
  uicontrol(...
    'units','points',...
    'position',[420 290 60 20],...
    'string','Update',...
    'callback',[me '(''updatew'')'])
  uicontrol(...
    'units','points',...
    'position',[420 245 60 20],...
    'string','Contents',...
    'callback','nndtoc')
  uicontrol(...
    'units','points',...
    'position',[420 200 60 20],...
    'string','Close',...
    'callback',[me '(''close'')'])

  % SAVE WINDOW DATA AND LOCK
  W_ptr = uicontrol('visible','off','userdata',W);
  WV_ptr = uicontrol('visible','off','userdata',WV);
  P_ptr = uicontrol('visible','off','userdata',P);
  PV_ptr = uicontrol('visible','off','userdata',PV);

  H = [fig_axis, ...
       desc_text,...
       w_axis, w_cross p_axis p_cross,...
       W_ptr WV_ptr, P_ptr, PV_ptr, ...
       lr_bar lr_text];

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
    'Click on the left graph to change the green weight vector, and the right graph',...
    'to change the red input vector.  Set the learning rate below.',...
    '',...
    'The change in the weight vector is shown with a blue arrow.',...
    'Make the change by clicking [Update].')
    
%==================================================================
% Button down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig) & (nargin == 1)
  
  % FIND CLICK POSITION
  axes(w_axis)
  pt = get(w_axis,'currentpoint');
  x = pt(1);
  y = pt(3);

  if (abs(x) <= 1.1) & (abs(y) <= 1.1)

    x = x / max(1,abs(x));
    y = y / max(1,abs(y));
    W = [x y];
    set(W_ptr,'userdata',W);
    cmd = 'update';
  
  else
    axes(p_axis)
    pt = get(p_axis,'currentpoint');
    x = pt(1);
    y = pt(3);

    if (abs(x) <= 1.1) & (abs(y) <= 1.1)

      % CLIP
      x = x / max(1,abs(x));
      y = y / max(1,abs(y));
      P = [x; y];
      set(P_ptr,'userdata',P);
      cmd = 'update';
    end
  end


%==================================================================
% Respond to learning rate slider.
%
% ME('lr')
%==================================================================

elseif strcmp(cmd,'lr')
  
  lr = get(lr_bar,'value');
  set(lr_text,'string',sprintf('%5.2f',round(lr*10)*0.1))
  cmd = 'update';

%==================================================================
% Respond to [Update] click.
%
% ME('updatew')
%==================================================================

elseif strcmp(cmd,'updatew')
  
  P = get(P_ptr,'userdata');
  W = get(W_ptr,'userdata');
  lr = get(lr_bar,'value');
  W2 = W + (lr*1*ones(1,2)).*(P'-W);
  set(W_ptr,'userdata',W2);

  cmd = 'update';
end

%==================================================================
% Update drawn vectors.
%
% ME('update')
%==================================================================

if strcmp(cmd,'update')

  % GET DATA
  PV = get(PV_ptr,'userdata');
  P = get(P_ptr,'userdata');
  WV = get(WV_ptr,'userdata');
  W = get(W_ptr,'userdata');
  lr = get(lr_bar,'value');
  set(fig,'nextplot','add')

  % MOVE WEIGHTS
  axes(w_axis);
  set(WV,'color',nnltyell);
  drawnow
  delete(WV);
  WV = nndrwvec(W(1),W(2),2,0.1,nngreen,'','none');
  set(w_cross,'color',nndkblue)

  axes(p_axis)
  set(PV,'color',nnltyell)
  drawnow
  delete(PV);

  W2 = W + (lr*1*ones(1,2)).*(P'-W);

  PV = [nndrwvec(W(1),W(2),2,0.1,nngreen,'','none');
          nndrwvec(P(1),P(2),2,0.1,nnred,'','none');
          nndrwvec([W(1) P(1)],[W(2) P(2)],1,0,nndkblue,'','none');
          nndrwvec([W(1) W2(1)],[W(2) W2(2)],2,0.1,nndkblue,'','none')];
  set(p_cross,'color',nndkblue)

  % SET DATA
  set(fig,'nextplot','new')
  set(PV_ptr,'userdata',PV);
  set(WV_ptr,'userdata',WV);
end
