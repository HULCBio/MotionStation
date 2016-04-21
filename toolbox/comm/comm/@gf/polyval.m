function y = polyval(p,x) 
%   POLYVAL Evaluate polynomial in Galois field.
%   Y = POLYVAL(P,X), when P is a vector of length N+1 whose elements
%   are the coefficients of a polynomial, is the value of the
%   polynomial evaluated at X.
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
%   If X is a matrix or vector, the polynomial is evaluated at all
%   points in X. 

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 20:11:13 $

if ~isa(x,'gf'), x = gf(x,p.m); end
if ~isa(p,'gf'), p = gf(p,x.m); end
if p.m~=x.m
  error('Orders must match.')
elseif p.prim_poly~=x.prim_poly
  error('Primitive polynomials must match.')
end

[m,n] = size(x);
nc = length(p);

% Use Horner's method for general case where X.x is an array.
y = gf(zeros(m,n), p.m);
if length(p)>0
    S.type='()';
    S.subs={1};
    G.type='()';
    G.subs={':'};
    y = subsasgn(y,G,subsref(p,S)); 
end
for i=2:nc
    S.type='()';
    S.subs={i};
    y = x .* y + subsref(p,S);
end

