function Y = gamma(X)
%GAMMA  Symbolic gamma function.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:10:15 $

[Y,stat] = maple('map','gamma',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('gamma',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
