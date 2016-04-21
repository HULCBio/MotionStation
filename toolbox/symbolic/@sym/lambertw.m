function W = lambertw(k,X)
%LAMBERTW Lambert's W function.
%   W = LAMBERTW(X) is the solution to w*exp(w) = x.
%   W = LAMBERTW(K,X) is the K-th branch of this multi-valued function.
%   Reference: Robert M. Corless, G. H. Gonnet, D. E. G. Hare,
%   D. J. Jeffrey, and D. E. Knuth, "On the Lambert W Function",
%   Advances in Computational Mathematics, volume 5, 1996, pp. 329-359.
%   Also available from:
%   http://pineapple.apmaths.uwo.ca/~rmc/papers/LambertW/index.html

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/16 22:22:46 $


if nargin == 1
   X = k;
   k = sym(0);
else
   X = sym(X);
   k = sym(k);
end

if all(size(k) == 1)
   [W,stat] = maple('map2','lambertw',k,X);
elseif all(size(X) == 1)
   [W,stat] = maple('map','lambertw',k,X);
else
   error('symbolic:sym:lambertw:errmsg1','One argument must be a scalar.')
end


if stat
   % Singularity encountered.
   if all(size(k) == 1)
      k = k(ones(size(X)));
   else
      X = X(ones(size(k)));
   end
   W = X;
   for j = 1:prod(size(W));
      [W(j),stat] = maple('lambertw',k(j),X(j));
      if stat
         W(j) = inf;
      end
   end
end
