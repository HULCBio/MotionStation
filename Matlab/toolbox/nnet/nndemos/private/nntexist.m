function e = nntexist(d)
% NNTEXIST Neural Network Design utility function.

% $Revision: 1.6 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% First Version, 8-31-95.

%==================================================================

e = exist('learnp');

if (~e)

  % FIND WINDOW IF IT EXISTS
  fig = nndfgflg('Warning');
  if (fig)
    delete(fig)
  end

  % NEW FIG
  fig = figure('visible','off');

  % GET SCREEN SIZE
  su = get(0,'units');
  set(0,'units','points');
  ss = get(0,'ScreenSize');
  set(0,'units',su);
  left = ss(1);
  bottom = ss(2);
  width = ss(3);
  height = ss(4);

  % CENTER FIGURE ON SCREEN
  x = 300;
  y = 140;
  pos = [(width-x)/2+left, (height-y)/2+bottom, x y];

  set(fig,...
    'units','points',...
    'position',pos, ...
    'resize','off', ...
    'color',nnltgray,...
    'inverthardcopy','off', ...
    'nextplot','add',...
    'visible','off',...
    'name','Warning',...
    'numbertitle','off');
  
  % FIGURE AXIS
  fig_axis = nnsfo('a0');

  % BORDER LINE
  plot([0 0 300 300 0],[0 139 139 0 0],'color',nnblack)

  % TITLE
  text(35,120,'Neural Network', ...
    'color',nnblack, ...
    'fontname','times', ...
    'fontsize',16, ...
    'fontangle','italic', ...
    'fontweight','bold');
  text(35,100,'Design',...
    'color',nnblack, ...
    'fontname','times', ...
    'fontsize',20, ...
    'fontweight','bold');

  % TOP LINE
  nndrwlin([0 215],[85 85],4,nndkblue);

  % NOTE
  text(35,65,['Demo "' upper(d) '" requires'],...
    'color',nndkblue, ...
    'fontname','helvetica', ...
    'fontsize',14);

  text(35,47,'the Neural Network Toolbox.',...
    'color',nndkblue, ...
    'fontname','helvetica', ...
    'fontsize',14);
  
  uicontrol(...
    'units','points',...
    'position',[120 10 60 20],...
    'string','OK',...
    'callback','close')

  set(fig,'color',nnltgray','nextplot','new')

  % BEEP
  s = nndsnd(6);
  set(fig,'visible','on');
  nnsound(s,8192);
  drawnow
  nnsound(s,8192);
end
