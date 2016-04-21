function Y = acsch(X)
%ACSCH  Symbolic inverse hyperbolic cosecant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:09:57 $

[Y,stat] = maple('map','acsch',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('acsch',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
