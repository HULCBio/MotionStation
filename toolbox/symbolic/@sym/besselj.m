function J = besselj(nu,Z)
%BESSELJ Symbolic Bessel function, J(nu,z).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:06 $

nu = sym(nu);
Z = sym(Z);

if all(size(nu) == 1)
   [J,stat] = maple('map2','besselj',nu,Z);
elseif all(size(Z) == 1)
   [J,stat] = maple('map','besselj',nu,Z);
else
   error('symbolic:sym:besselj:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(nu) == 1)
      nu = nu(ones(size(Z)));
   else
      Z = Z(ones(size(nu)));
   end
   J = Z;
   for k = 1:prod(size(Z));
      [J(k),stat] = maple('besselj',nu(k),Z(k));
      if stat
         J(k) = inf;
      end
   end
end
