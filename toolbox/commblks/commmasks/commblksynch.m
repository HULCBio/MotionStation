function [s,x,y] = commblksynch(action)
% COMMBLKSYNCH Communications Blockset synchronization library mask helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.7 $ $Date: 2002/03/24 02:02:07 $

if nargin==0, action = 'icon'; end

switch action
case 'icon'
   
	t = 0:100; 
	x1 = 20*cos(.02*pi*t); y1 = 20*sin(.02*pi*t);
	x2 = [0 0]; y2 = [0 17];
	x3 = [0 7]; y3 = [0 7];
	xa = [x1 NaN x2 NaN x3]; ya = [y1 NaN y2 NaN y3];
	xarrow = [37 67 71 71 59 63 33 29 29 41 37]; 
	yarrow = [67 37 41 29 29 33 63 59 71 71 67];
	x = [xa+25 NaN xa+75 NaN xarrow]; 
	y = [ya+75 NaN ya+25 NaN yarrow];
   s = '';
   
case 'patch'
   
   x = [37 67 71 71 59 63 33 29 29 41 37]; 
	y = [67 37 41 29 29 33 63 59 71 71 67];
   s = '';
   
end;
