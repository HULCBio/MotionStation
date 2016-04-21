function Y = log10(X)
%LOG10  Symbolic matrix element-wise common logarithm.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:50 $

[Y,stat] = maple('map','log10',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('log10',X(k));
      if stat
         Y(k) = -Inf;
      end
   end
end
