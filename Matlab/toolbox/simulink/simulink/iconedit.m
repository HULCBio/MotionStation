function cmd  = iconedit(graphname, blockname)
%ICONEDIT is a tool for designing block icons using MATLAB's ginput.
%
%   ICONEDIT without arguments prompts the user for a graph name
%   and a block name whose icon is to be changed. Points are
%   connected on the graph window which make up a new icon.
%
%   The following commands can be typed at the keyboard:
%       q - quit and change blocks icon
%       n - define a new unconnected point
%       d - delete the last point
%
%   ICONEDIT(GRAPH,BLOCK) allows the block diagram window and
%   the block name to passed in directly.
%
%   ICONEDIT uses the Simulink Mask utility.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $
%   Andrew Grace 11-12-90
%   Revised Ned Gulley 6-18-93

if nargin==0
  graphname=input('Name of block diagram: ','s');
end
if nargin<2
  blockname=input('Name of block: ','s');
end
if ~ishold,
  clf
end
plot([0,100,100,0,0], [0,0,100,100,0]);
axis([0 100 0 100]);
hold on
grid
title('Block Icon Editor')
xlabel('d=delete, q=quit, n=new pt')
button = ' ';
xp=[];
yp=[];
cmd = 'plot(0,0,100,100)';
xcmd = '[';
ycmd = '[';
  
while button ~= 'q'
  [x,y,button]=ginput(1);
  x = round(x);
  y = round(y);
  if (button == 'n' | button == 'q') & length(xp) > 1
    for (i=1:length(xp))
      xcmd= sprintf([xcmd, '%g,'], xp(i));
      ycmd= sprintf([ycmd, '%g,'], yp(i));
    end
    xcmd(length(xcmd)) = ']';
    ycmd(length(ycmd)) = ']';
    cmd(length(cmd))=',';
    cmd = [cmd, xcmd, ',' ycmd, ')'];
    xcmd = '['; xp =[];
    ycmd = '['; yp =[];
  elseif button == 'd'
    [mini, ind] = min( abs(xp -x+ sqrt(-1)*(yp-y) ));
    xp(ind)=[];
    yp(ind)=[];
    clf
    hold off
    plot([0,100,100,0,0], [0,0,100,100,0]);
    axis([0 100 0 100]);
    hold on
    grid
    eval(cmd);
    title('Block Icon Editor')
    xlabel('d=delete, q=quit, n=new')
    if length(xp)
      plot(xp,yp,'*','EraseMode','none')
      plot(xp,yp)
    end
  else
    plot(x,y, '*','EraseMode','none')
    xp = [x, xp];
    yp = [y, yp];
    plot(xp,yp,'EraseMode','none')
  end
end
hold off

set_param([graphname, '/',blockname], 'MaskDisplay', cmd);

% end iconedit
