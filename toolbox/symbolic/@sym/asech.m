function Y = asech(X)
%ASECH  Symbolic inverse hyperbolic secant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:07:10 $

[Y,stat] = maple('map','asech',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('asech',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
