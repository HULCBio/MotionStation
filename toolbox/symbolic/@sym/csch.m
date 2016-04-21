function Y = csch(X)
%CSCH   Symbolic hyperbolic cosecant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:07:40 $

[Y,stat] = maple('map','csch',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('csch',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
