function Y = cot(X)
%COT    Symbolic cotangent.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:06:52 $

[Y,stat] = maple('map','cot',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),stat] = maple('cot',X(k));
      if stat
         Y(k) = Inf;
      end
   end
end
