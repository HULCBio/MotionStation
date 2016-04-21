function [x,y] = cmplxicn(side,v,o,method)
% CMPLXICN  Complex Icon function for SIMULINK Complex blocks.
%	[X,Y] = CMPLXICN(SIDE,V,ORIENTATION) returns vectors which can be
%	used in a plot command inside a block mask to indicate
%	a complex input or output.  SIDE == 0 indicates an
%	input, and SIDE == 1 indicates an output.  V is a position
%	from 0 (bottom) to 100 (top) specifying the vertical
%	spacing of the indicator.  V defaults to 50.
%	ORIENTATION is the orientation of the block: 0 ==> left-to-right,
%	1 ==> top-to-bottom, 2 ==> right-to-left, 3 ==> bottom-to-top

%	T. Krauss, 12-5-94
%	Copyright 1996-2002 The MathWorks, Inc.
%	$Revision: 1.12 $  $Date: 2002/03/24 01:59:22 $

if nargin < 4
	method = 4;  
end
if nargin < 3
	o = 'right';
end
if nargin < 2
	v = 50;
end
if isempty(v)
	v = 50;
end

if method == 1   % double semi-cicles
	t=0:(2*pi/20):pi; 
	x=sin(t); 
	y=cos(t); 
	x=100*[.05*x .1*x]; 
	y=100*[.1*y .2*y];
	if side
		x = 100-x;
	end
	y = y+v;

elseif method == 2  % > sign
	x=[0 10 0]; y = [-10 0 10];
	if side
		x = 90+x;
	end
	y = y+v;

elseif method == 3  %  bars
	x=[1 1 1 3 3]+1; 
	y=[-10 10 5 5 -5];
	if side
		x = 101-x;
	end
	y = y+v;

elseif method == 4  %  *'s
	x = [4 16 10 4 16 10 10 10];
	y = [56 48 52 48 56 52 60 44] - 52;
	if side
		x = 100-x;
	end
	y = y+v;
end

switch lower(o)
  case 'down'
  %if o == 1        % top-to-bottom
	xx = x;  x = y;  y = xx;   % swap x and y 
	y = 100 - y;
  case 'left'
  %elseif o == 2    % right-to-left
	x = 100 - x;
  case 'up'
  %elseif o == 3    % bottom-to-top
	xx = x;  x = y;  y = xx;   % swap x and y 
	x = 100 - x;
end
