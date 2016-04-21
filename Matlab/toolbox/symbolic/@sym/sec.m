function Y = sec(X)
%SEC    Symbolic secant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:12:21 $

[Y,stat] = maple('map','sec',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),s] = maple('sec',X(k));
      if s
         Y(k) = Inf;
      end
   end
end
