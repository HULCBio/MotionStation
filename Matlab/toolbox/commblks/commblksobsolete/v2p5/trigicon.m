function [x,y] = trigicon(side,v,o, met)
% TRIGICON  Trigger Icon function for SIMULINK Triggered blocks.
%	[X,Y] = TRIGICON(SIDE,V,ORIENTATION) returns vectors which can be
%	used in a plot command inside a block mask to indicate
%	a triggered input or output.  SIDE == 0 indicates an
%	input, and SIDE == 1 indicates an output.  V is a position
%	from 0 (bottom) to 100 (top) specifying the vertical
%	spacing of the indicator.  V defaults to 50.
%	ORIENTATION is the orientation of the block: 0 ==> left-to-right,
%	1 ==> top-to-bottom, 2 ==> right-to-left, 3 ==> bottom-to-top
%   ORIENTATION == 1, enable/disable
%   ORIENTATION == 2, raising edge trigger.

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.1.6.1 $

if nargin < 4
    met = 1;
end;
if nargin < 3
	o = 'right';
end
if nargin < 2
	v = 50;
end
if isempty(v)
	v = 50;
end
if nargin < 1
    side == 0;
end;
if side == 1;
    %o = rem(o+2, 4);
    switch lower(o)
      case 'right'
        o = 'left';
      case 'left'
        o = 'right';
      case 'up'
	o = 'down';
      case 'down'
        o = 'up'
    end;
    v = 100-v;
end;

if met == 1
    x = [5 10 10 15 15 20];
    y = [5 5  10 10  5  5];
    y_d = -7.5;
    x_d = -10;
elseif met == 2
    x = [5 10 10 8 10 12 10 10 15];
    y = [5 5  12 8 12 8  12 15 15];
    y_d = -10;
    x_d = -5;
end;

switch lower(o)
  case 'right'
    % if o == 0
    y = y + v + y_d;
  case 'down'
    % elseif o == 1        % top-to-bottom
    v = 100-v;
    x = x + v + x_d;
    y = y + (100 + 2*y_d);
  case 'left'
    % elseif o == 2    % right-to-left
    if met == 1
        x = 100 - x;
    elseif met == 2
        x = x + 80;
    end;
    y = y + v + y_d;
  case 'up'
    % elseif o == 3    % bottom-to-top
    v = 100 -v;
    x = x + v + x_d;
end
%plot(0,0,100,100,x,y);
