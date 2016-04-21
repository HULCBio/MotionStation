function z = sinint(x)
%SININT Sine integral function.
%   SININT(x) = int(sin(t)/t,t,0,x).
%
%   See also COSINT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:06:43 $

[z,stat] = maple('map','sinint',x);

if stat
   % Singularities
   z = x;
   for k = 1:prod(size(x))
      [z(k),stat] = maple('sinint',x(k));
      if stat
         z(k) = Inf;
      end
   end
end
