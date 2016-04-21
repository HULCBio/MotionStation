function Y = csc(X)
%CSC    Symbolic cosecant.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:11:03 $

[Y,stat] = maple('map','csc',X);

if stat
   % Singularities
   Y = X;
   for k = 1:prod(size(X))
      [Y(k),s] = maple('csc',X(k));
      if s
         Y(k) = Inf;
      end
   end
end
