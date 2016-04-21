function I = besseli(nu,Z)
%BESSELI Symbolic Bessel function, I(nu,z).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:05 $

nu = sym(nu);
Z = sym(Z);

if all(size(nu) == 1)
   [I,stat] = maple('map2','besseli',nu,Z);
elseif all(size(Z) == 1)
   [I,stat] = maple('map','besseli',nu,Z);
else
   error('symbolic:sym:besseli:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(nu) == 1)
      nu = nu(ones(size(Z)));
   else
      Z = Z(ones(size(nu)));
   end
   I = Z;
   for k = 1:prod(size(Z));
      [I(k),stat] = maple('besseli',nu(k),Z(k));
      if stat
         I(k) = inf;
      end
   end
end
