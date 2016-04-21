function K = besselk(nu,Z)
%BESSELK Symbolic Bessel function, K(nu,z).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:07 $

nu = sym(nu);
Z = sym(Z);

if all(size(nu) == 1)
   [K,stat] = maple('map2','besselk',nu,Z);
elseif all(size(Z) == 1)
   [K,stat] = maple('map','besselk',nu,Z);
else
   error('symbolic:sym:besselk:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(nu) == 1)
      nu = nu(ones(size(Z)));
   else
      Z = Z(ones(size(nu)));
   end
   K = Z;
   for k = 1:prod(size(Z));
      [K(k),stat] = maple('besselk',nu(k),Z(k));
      if stat
         K(k) = inf;
      end
   end
end
