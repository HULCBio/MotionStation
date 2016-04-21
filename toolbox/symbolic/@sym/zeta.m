function Z = zeta(n,X)
%ZETA   Symbolic Riemann zeta function.
%   ZETA(z) = sum(1/k^z,k,1,inf).
%   ZETA(n,z) = n-th derivative of ZETA(z)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/16 22:23:21 $

if nargin == 1
   X = n;
   n = sym(0);
else
   X = sym(X);
   n = sym(n);
end

if all(size(n) == 1)
   [Z,stat] = maple('map2','zeta',n,X);
elseif all(size(X) == 1)
   [Z,stat] = maple('map','zeta',n,X);
else
   error('symbolic:sym:zeta:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(n) == 1)
      n = n(ones(size(X)));
   else
      X = X(ones(size(n)));
   end
   Z = X;
   for k = 1:prod(size(Z));
      [Z(k),stat] = maple('zeta',n(k),X(k));
      if stat
         Z(k) = inf;
      end
   end
end
