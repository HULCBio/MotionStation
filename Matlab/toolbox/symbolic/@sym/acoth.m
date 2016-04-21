function Y = acoth(X)
%ACOTH  Symbolic inverse hyperbolic cotangent.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:11:57 $

[Y,stat] = maple('map','acoth',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('acoth',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
