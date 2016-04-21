function yy = linterp(x,y,xx)
%LINTERP Linear interpolation.
%
% YY = LINTERP(X,Y,XX) does a linear interpolation for the given
%      data:
%
%           y: given Y-Axis data
%           x: given X-Axis data
%          xx: points on X-Axis to be interpolated
%
%      output:
%
%          yy: interpolated values at points "xx"

% R. Y. Chiang & M. G. Safonov 9/18/1988
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------

nx = max(size(x));
nxx = max(size(xx));
if xx(1) < x(1)
   error('You must have min(x) <= min(xx)..')
end
if xx(nxx) > x(nx)
   error('You must have max(xx) <= max(x)..')
end
%
j = 2;
for i = 1:nxx
   while x(j) < xx(i)
         j = j+1;
   end
   alfa = (xx(i)-x(j-1))/(x(j)-x(j-1));
   yy(i) = y(j-1)+alfa*(y(j)-y(j-1));
end
%
% ------ End of INTERP.M % RYC/MGS %