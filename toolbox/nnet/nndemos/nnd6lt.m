function nnd6lt(cmd,arg1,arg2)
%NND6LT Linear transformations demonstration.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

%==================================================================

% CONSTANTS
me = 'nnd6lt';

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
  left = H(3);                % left axis
  right = H(4);               % right axis
  trans_ptr = H(5);           % handles to tranformation vectors
  click_ptr = H(6);           % click down point
  track_ptr = H(7);           % current motion point
  eig_ptr = H(8);             % handles to eigenvalue vectors
  a_ptr = H(9);               % the transformation a
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
  fig = nndemof(me,'DESIGN','Linear Transformations','','Chapter 6');
  set(fig, ...
    'windowbuttondownfcn',nncallbk(me,'down'), ...
    'BackingStore','off',...
    'nextplot','add');
  H = get(fig,'userdata');
  fig_axis = H(1);
  desc_text = H(2);

  % ICON
  nndicon(6,458,363,'shadow')
  
  % LEFT AXIS
  left = nnsfo('a2','Original Vectors','','');
  set(left, ...
    'xlim',[-1.3 1.3], ...
    'ylim',[-1.3 1.3])
  set(left,'userdata',nndrawax(nndkblue,'none'));

  % RIGHT AXIS
  right = nnsfo('a3','Transformed Vectors','','');
  set(right,...
    'xlim',[-1.3 1.3], ...
    'ylim',[-1.3 1.3])
  set(right,'userdata',nndrawax(nndkblue,'none'));
  
  % CREATE BUTTONS
  set(nnsfo('b0','Clear'), ...
    'callback',nncallbk(me,'clear'))
  set(nnsfo('b4','Contents'), ...
    'callback','nndtoc')
  set(nnsfo('b5','Close'), ...
    'callback',nncallbk(me,'close'))

  % DATA POINTERS
  trans_ptr = nnsfo('data'); set(trans_ptr,'userdata',[]);
  click_ptr = nnsfo('data'); set(click_ptr,'userdata',[]);
  track_ptr = nnsfo('data'); set(track_ptr,'userdata',[]);
  eig_ptr = nnsfo('data'); set(eig_ptr,'userdata',[]);
  a_ptr = nnsfo('data'); set(a_ptr,'userdata',[]);
  
  % SAVE WINDOW DATA AND LOCK
  H = [fig_axis desc_text left right trans_ptr click_ptr ...
    track_ptr eig_ptr a_ptr];
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
    'PERFORM LINEAR TRANSFORMATIONS',...
    '',...
    'Click in the left graph to create a vector. Keep the button down and ',...
    'drag the mouse to create the transformed vector. Repeat for a second vector.',...
    '',...
    'These four vectors define a linear transformation. The eigenvectors of the',...
    'transformation will be shown in the right graph. If the eigenvectors are',...
    'complex they will not be shown.',...
    '',...
    'Click and drag on the right graph to see how other vectors are transformed.');

%==================================================================
% Display the tranformation.
%
% ME('instr')
%==================================================================

elseif strcmp(cmd,'trans') & (fig)
  a = get(a_ptr,'userdata');
  nnsettxt(desc_text,...
    'The matrix representation of the transformation is:',...
    '',...
    sprintf('    [ %5.2g  %5.2g  ]',a(1,1),a(1,2)), ...
    sprintf('    [ %5.2g  %5.2g  ]',a(2,1),a(2,2)), ...
    '',...
    'Click and drag on the right graph to see how other vectors are transformed.',...
    '',...
    'Click [Clear] to define a new transformation.');

%==================================================================
% Respond to mouse down.
%
% ME('down')
%==================================================================

elseif strcmp(cmd,'down') & (fig)

  set(fig,'nextplot','add')
  [in,x,y] = nnaxclik(left);
  if in
    feval(me,'leftdown',x,y);
  else
    [in,x,y] = nnaxclik(right);
    if in
      feval(me,'rightdown',x,y);
    end
  end
  set(fig,'nextplot','new')

%==================================================================
% Respond to mouse down in left axis.
%
% ME('leftdown')
%==================================================================

elseif strcmp(cmd,'leftdown') & (fig) & (nargin == 3)

  trans = get(trans_ptr,'userdata');
  number = min(size(trans));

  if (number < 2)
    axes(left)
    set(fig,'windowbuttonmotionfcn',nncallbk(me,'leftmotion'));
    set(fig,'windowbuttonupfcn',nncallbk(me,'leftup'));
  
    % GET DATA
    x = arg1;
    y = arg2;

    % DRAW CLICK AND TRACK LINES
    click_h = nndrwvec(x,y,2,0.1,nndkblue,'','none');
    track_h = plot([x x],[y y],'erasemode','xor','linewidth',2);

    % STORE DATA
    set(click_ptr,'userdata',[x y click_h]);
    set(track_ptr,'userdata',[x y track_h]);
  end

%==================================================================
% Respond to mouse motion in left axis.
%
% ME('leftmotion')
%==================================================================

elseif strcmp(cmd,'leftmotion') & (fig)
  axes(left)
  [in,x,y] = nnaxclik(left);
  
  % GET DATA
  click_data = get(click_ptr,'userdata');
  track_data = get(track_ptr,'userdata');

  % MOVE TRACK LINE
  if in
    set(track_data(3),'xdata',[click_data(1) x],'ydata',[click_data(2) y]);
  else
    set(track_data(3),'xdata',[NaN],'ydata',[NaN]);
  end

  % STORE DATA
  set(track_ptr,'userdata',[x y track_data(3)])

%==================================================================
% Respond to mouse up in left axis.
%
% ME('leftup')
%==================================================================

elseif strcmp(cmd,'leftup') & (fig)
  axes(left)
  set(fig,'windowbuttonmotionfcn','',...
     'windowbuttonupfcn','',...
     'nextplot','add')

  % GET DATA
  ltyell = nnltyell;
  dkblue = nndkblue;
  red = nnred;
  click_data = get(click_ptr,'userdata');
  track_data = get(track_ptr,'userdata');
  trans_data = get(trans_ptr,'userdata');
  eig_data = get(eig_ptr,'userdata');
  number = min(size(trans_data));

  % REMOVE TRACK LINE
  set(track_data(3),'erasemode','none','color',ltyell);
  delete(track_data(3));

  if nnaxclik(left,track_data(1),track_data(2))
    
    % REFRESH NEXT OLDEST
    if number == 1
      set(trans_data(7),'color',nnltgray);
      set(trans_data(6),'color',red);
      set(trans_data(3),'color',dkblue);
    end

    % CREATE NEW TRANSFORMATION
    line_h = plot([click_data(1) track_data(1)],[click_data(2) track_data(2)],...
      'color',nnltgray,...
      'linewidth',2,...
      'erasemode','none');
    track_data(3) = nndrwvec(track_data(1),track_data(2),2,0.1,nnred,'','none');
    set(click_data(3),'color',nndkblue)
    trans_data = [trans_data [click_data'; track_data'; line_h]];

    % CALCULATE TRANSFORMATION A
    axes(right)
    if number >= 1
      b = trans_data([1 8; 2 9]);
      c = trans_data([4 11; 5 12]);
      a = c/b;
      set(a_ptr,'userdata',a);
      feval(me,'trans');
      [v,d] = eig(a);

      % PLOT EIGENVECTORS
      if all(isreal(v))
        eig_h1 = nndrwvec(v(1,1),v(2,1),2,0.1,nngreen,'','none');
        eig_h2 = nndrwvec(v(1,2),v(2,2),2,0.1,nngreen,'','none');
        eig_data = [eig_h1; eig_h2];
      else
        eig_data = text(0,0.8,'Complex Eigenvectors',...
          'horiz','center',...
          'color',nnred,...
          'fontweight','bold',...
          'erasemode','none');
      end
    else
      a = [];
      eig_data = [];
    end

    % STORE DATA
    set(trans_ptr,'userdata',trans_data);
    set(eig_ptr,'userdata',eig_data);

  % DISCARD TRANSFORMATION
  else
    set(click_data(3),...
      'erasemode','none',...
      'color',ltyell);
    delete(click_data(3));
  end
  
  % REDRAW AXES
  set(get(left,'userdata'),'color',nndkblue);
  set(get(right,'userdata'),'color',nndkblue);
  set(fig,'nextplot','new')

%==================================================================
% Respond to mouse down in right axis.
%
% ME('rightdown')
%==================================================================

elseif strcmp(cmd,'rightdown') & (fig) & (nargin == 3)
  axes(right)

  % GET DATA
  eig_data = get(eig_ptr,'userdata');
  a = get(a_ptr,'userdata');

  if size(a) > 0
    set(fig,...
      'windowbuttonmotionfcn',nncallbk(me,'rightmotion'),...
      'windowbuttonupfcn',nncallbk(me,'rightup'));

    x = arg1;
    y = arg2;
    new_pt = a*[x;y];
    nx = new_pt(1);
    ny = new_pt(2);

    % DRAW CLICK AND TRACK LINES
    click_h1 = plot([x nx],[y ny],...
      'color',nnltgray,...
      'linewidth',2,...
      'erasemode','xor');
    click_h2 = nndrwvec(x,y,2,0.1,nndkblue,'','xor');
    click_h3 = nndrwvec(nx,ny,2,0.1,nngreen,'','xor');

    % SAVE DATA
    set(click_ptr,'userdata',[click_h1, click_h2, click_h3]);
  end

%==================================================================
% Respond to mouse up in motion axis.
%
% ME('rightmotion')
%==================================================================

elseif strcmp(cmd,'rightmotion') & (fig)
  axes(right)
  set(fig,'nextplot','add')

  % GET DATA
  ltyell = nnltyell;
  click_data = get(click_ptr,'userdata');
  a = get(a_ptr,'userdata');

  % HIDE LINES
  delete(click_data);

  % MOVE LINES
  [in,x,y] = nnaxclik(right);
  if in
    new_pt = a*[x;y];
    nx = new_pt(1);
    ny = new_pt(2);
    click_h1 = plot([x nx],[y ny],...
      'color',nnltgray,...
      'linewidth',2,...
      'erasemode','xor');
    click_h2 = nndrwvec(x,y,2,0.1,nndkblue,'','xor');
    click_h3 = nndrwvec(nx,ny,2,0.1,nngreen,'','xor');
    click_data = [click_h1, click_h2, click_h3];
  else
    click_data = [];
  end

  % SAVE DATA
  set(click_ptr,'userdata',click_data);

  % REDRAW AXIS
  set(get(right,'userdata'),'color',nndkblue);
  set(fig,'nextplot','new')

%==================================================================
% Respond to mouse up in right axis.
%
% ME('rightup')
%==================================================================

elseif strcmp(cmd,'rightup') & (fig)
  axes(right)
  set(fig,...
    'windowbuttonmotionfcn','',...
    'windowbuttonupfcn','')

  % GET DATA
  ltyell = nnltyell;
  click_data = get(click_ptr,'userdata');

  % REMOVE LINES
  set(click_data(1),'color',ltyell)
  set(click_data(2),'color',ltyell)
  set(click_data(3),'color',ltyell)
  delete(click_data);

  % REDRAW AXIS
  set(get(right,'userdata'),'color',nndkblue);

%==================================================================
% Clear window.
%
% ME('clear')
%==================================================================

elseif strcmp(cmd,'clear') & (fig)
  
  % GET DATA
  ltyell = nnltyell;
  trans_data = get(trans_ptr,'userdata');
  eig_data = get(eig_ptr,'userdata');
  
  number = min(size(trans_data));
  for i=1:number
    set(trans_data(3),'color',ltyell)
    set(trans_data(6),'color',ltyell)
    set(trans_data(7),'color',ltyell)
    delete(trans_data([3 6 7]));
    trans_data(:,1) = [];
  end
  for i=1:length(eig_data)
    set(eig_data(i),'color',ltyell)
    delete(eig_data(i));
  end

  % STORE DATA
  set(trans_ptr,'userdata',[]);
  set(eig_ptr,'userdata',[]);
  set(a_ptr,'userdata',[]);

  % REDRAW AXES
  set(get(left,'userdata'),'color',nndkblue);
  set(get(right,'userdata'),'color',nndkblue);

  feval(me,'instr');

%==================================================================
end
