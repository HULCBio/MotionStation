function Y = tan(X)
%TAN    Symbolic tangent function.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:11:33 $

[Y,stat] = maple('map','tan',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('tan',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
