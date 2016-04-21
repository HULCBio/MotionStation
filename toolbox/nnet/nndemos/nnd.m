function nnd(cmd)
% NND Neural Network Design graphical user interface.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.8 $
% First Version, 8-31-95.

% BRING UP FIGURE IF IT EXISTS

me = 'nnd';
fig = nndfgflg(me);
if length(get(fig,'children')) == 0, fig = 0; end
if nargin == 0, cmd = ''; end

% CREATE FIGURE ========================================================

if strcmp(cmd,'') & (fig)
  figure(fig)

elseif strcmp(cmd,'') & (~fig)

  % START WITH STANDARD TITLE FIGURE

  fig = nntitlef(me,'DESIGN','','','','');

  t = text(80,62,'To Order the Neural Network Design book, call International Thomson');
  set(t,'fontweight','bold')
  t = text(80,46,'Publishing Customer Service, phone 1-800-347-7707');
  set(t,'fontweight','bold')

  % UNLOCK
  set(fig,'nextplot','add')

  % ICONS
  nndicon(2,130,230,'shadow')
  nndicon(3,170,130,'shadow')
  nndicon(4,210,230,'shadow')
  nndicon(7,250,130,'shadow')
  nndicon(10,290,230,'shadow')
  nndicon(11,330,130,'shadow')
  nndicon(14,370,230,'shadow')
  
  % BUTTONS
  drawnow % Let everthing else appear before buttons
  set(nnsfo('b7','Table of Contents'), ...
    'callback','nndtoc',...
    'pos',[80 10 130 20])
  set(nnsfo('b10','Close'),...
    'pos',[360 10 60 20]);
  
  % LOCK FIGURE AND RETURN
  set(fig,'nextplot','new')

  nnchkfs;
end


