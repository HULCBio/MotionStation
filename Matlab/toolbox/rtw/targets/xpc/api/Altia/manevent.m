function [x,y] = manevent
% MANEVENT Manual switch helper function

% Author(s): D. Orofino, L.Dean
% Copyright 1990-2002 The MathWorks, Inc.
% $Revision: 1.2 $ $Date: 2002/03/25 04:28:52 $

% NOTE: The Manual Switch block's open function sets
%       action='1'.  Otherwise, it is '0'.

blk = gcb;
sw  = get_param(blk,'sw');

x = [0 NaN 100 NaN 20 50 50 80 NaN 40 50 60];
down_y = [0 NaN 100 NaN 90 90 10 10 NaN 60 40 60];
up_y = [0 NaN 100 NaN 10 10 90 90 NaN 40 60 40];

% Only toggle switch if OpenFcn got us here:
if strcmp(get_param(blk,'action'),'1'),
  set_param(blk,'action','0');
  if sw=='1', 
     sw='0'; 
     y = up_y;
  else 
     sw='1'; 
     y = down_y;
  end
  set_param(blk,'sw',sw);
else
   if sw=='1'
      y=down_y;
   else
      y=up_y;
   end
end
set_param([blk '/Constant'],'Value',sw);

% [EOF] manevent.m

