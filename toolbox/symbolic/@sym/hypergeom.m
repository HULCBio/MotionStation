function h = hypergeom(n,d,z)
% HYPERGEOM  Generalized hypergeometric function.
% HYPERGEOM(N, D, Z) is the generalized hypergeometric function F(N, D, Z),
% also known as the Barnes extended hypergeometric function and denoted by
% jFk where j = length(N) and k = length(D).   For scalar a, b and c,
% HYPERGEOM([a,b],c,z) is the Gauss hypergeometric function 2F1(a,b;c;z).
% 
% The definition by a formal power series is
%    hypergeom(N,D,z) = sum(k=0:inf, (C(N,k)/C(D,k))*z^k/k!) where
%    C(V,k) = prod(i=1:length(V), gamma(V(i)+k)/gamma(V(i)))
% Either of the first two arguments may be a vector providing the coefficient
% parameters for a single function evaluation.  If the third argument is a
% vector, the function is evaluated pointwise.  The result is numeric if all
% the arguments are numeric and symbolic if any of the arguments is symbolic.
% See Abramowitz and Stegun, Handbook of Mathematical Functions, chapter 15.
%
% Examples:
%    syms a z
%    hypergeom([],[],z)             returns   exp(z)
%    hypergeom(1,[],z)              returns   -1/(-1+z)
%    hypergeom(1,2,z)               returns   (exp(z)-1)/z
%    hypergeom([1,2],[2,3],z)       returns   -2*(-exp(z)+1+z)/z^2
%    hypergeom(a,[],z)              returns   (1-z)^(-a)
%    hypergeom([],1,-z^2/4)         returns   besselj(0,z)
%    hypergeom([-n, n],1/2,(1-z)/2) returns   T(n,z)    where
%    T(n,z) = expand(cos(n*acos(z))) is the n-th Chebyshev polynomial.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/16 22:22:34 $

if length(z) == 1
   h = sym(maple(['simplify(hypergeom(' vec2list(n) ',' ...
           vec2list(d) ',' char(sym(z)) '));']));
   h = simplify(simple(h));
else
   h = sym(maple(['simplify(map(Z -> hypergeom(' vec2list(n) ',' ...
           vec2list(d) ',Z),' char(sym(z)) '));']));
end

% ------------------------

function m = vec2list(v)
%VEC2LIST Converts a MATLAB vector into a Maple list.
%   VEC2LIST(v) takes a MATLAB vector and returns a character
%   string of the form [v1,v2,...,vn].
%
%   Examples
%      vec2list(1:4)                returns   [1,2,3,4]
%      vec2list(sym('[a,b,c,d]'))   returns   [a,b,c,d]
if isempty(v)
   m = '[]';
elseif length(v) == 1
   m = ['[' char(sym(v)) ']'];
else
   m = char(sym(v),1);
   m(1:7) = [];
   m(end) = [];
end
