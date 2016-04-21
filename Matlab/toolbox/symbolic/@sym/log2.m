function Y = log2(X)
%LOG2   Symbolic matrix element-wise base-2 logarithm.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:51 $

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

Y = Y/log(sym(2));
