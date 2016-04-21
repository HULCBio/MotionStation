function z = cosint(x)
%COSINT Cosine integral function.
%  COSINT(x) = Gamma + log(x) + int((cos(t)-1)/t,t,0,x)
%  where Gamma is Euler's constant, .57721566490153286060651209...
%  Euler's constant can be evaluated with vpa('eulergamma').
%
%   See also SININT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:12:06 $

[z,stat] = maple('map','cosint',x);

if stat
   % Singularities
   z = x;
   for k = 1:prod(size(x))
      [z(k),stat] = maple('cosint',x(k));
      if stat
         z(k) = Inf;
      end
   end
end
