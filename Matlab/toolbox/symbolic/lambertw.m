function W = lambertw(k,X)
%LAMBERTW Lambert's W function.
%   W = LAMBERTW(X) is the solution to w*exp(w) = x.
%   W = LAMBERTW(K,X) is the K-th branch of this multi-valued function.
%   Reference: Robert M. Corless, G. H. Gonnet, D. E. G. Hare,
%   D. J. Jeffrey, and D. E. Knuth, "On the Lambert W Function",
%   Advances in Computational Mathematics, volume 5, 1996, pp. 329-359.
%   Also available from:
%   http://pineapple.apmaths.uwo.ca/~rmc/papers/LambertW/index.html

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:13:50 $

if nargin == 1
   W = double(lambertw(sym(k)));
else
   W = double(lambertw(sym(k),sym(X)));
end
