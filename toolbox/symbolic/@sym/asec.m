function Y = asec(X)
%ASEC   Symbolic inverse secant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:11:21 $

[Y,stat] = maple('map','asec',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('asec',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
