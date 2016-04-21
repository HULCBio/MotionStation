function Y = log(X)
%LOG    Symbolic matrix element-wise natural logarithm.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 03:07:43 $

[Y,stat] = maple('map','log',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('log',X(k));
      if stat
         Y(k) = -Inf;
      end
   end
end
