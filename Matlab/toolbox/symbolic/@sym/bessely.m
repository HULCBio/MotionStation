function Y = bessely(nu,Z)
%BESSELY Symbolic Bessel function, Y(nu,z).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:08 $

nu = sym(nu);
Z = sym(Z);

if all(size(nu) == 1)
   [Y,stat] = maple('map2','bessely',nu,Z);
elseif all(size(Z) == 1)
   [Y,stat] = maple('map','bessely',nu,Z);
else
   error('symbolic:sym:bessely:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(nu) == 1)
      nu = nu(ones(size(Z)));
   else
      Z = Z(ones(size(nu)));
   end
   Y = Z;
   for k = 1:prod(size(Z));
      [Y(k),stat] = maple('bessely',nu(k),Z(k));
      if stat
         Y(k) = inf;
      end
   end
end
