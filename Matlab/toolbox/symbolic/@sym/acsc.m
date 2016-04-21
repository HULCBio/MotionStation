function Y = acsc(X)
%ACSC   Symbolic inverse cosecant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:09:51 $

[Y,stat] = maple('map','acsc',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('acsc',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
