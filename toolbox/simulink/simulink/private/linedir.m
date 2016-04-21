function direct = linedir(layout)
%LINEDIR finds the direction of a line segment
%   layout = [x1,y1; x2.y2;...]
%   direct = 0>, 1v, 2<, 3^ 
%   direct = -1 if it is not a straight line

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

if layout(1, 2) == layout(2, 2)
   %horizontal
   if layout(1, 1) < layout(2, 1)
      direct = 0;
   else
      direct = 2;
   end;
elseif layout(1, 1) == layout(2, 1)
   %verticle
   if layout(1, 2) < layout(2, 2)
      direct = 1;
   else
      direct = 3;
   end;
else
   % in the case of not a straight line
   direct = -1;
end
