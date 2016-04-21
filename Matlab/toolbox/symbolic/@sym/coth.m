function Y = coth(X)
%COTH   Symbolic hyperbolic cotangent.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:11:00 $

[Y,stat] = maple('map','coth',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('coth',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
