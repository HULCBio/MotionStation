function c = eq(x,y)
%EQ  Equal == for GF arrays.
%   A == B does element-by-element comparisons between A and B
%   and returns a matrix of the same size with elements set to one
%   where the relation is true and elements set to zero where it is
%   not.  A and B must have the same dimensions unless one is a
%   scalar. A scalar can be compared with anything.
%   If either A or B is not a GF array, it is cast into a GF
%   array with the same number of bits as the other argument.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:15:13 $ 


if ~isa(x,'gf'), x = gf(x,y.m,y.prim_poly); end
if ~isa(y,'gf'), y = gf(y,x.m,x.prim_poly); end

if x.m~=y.m
  error('Orders must match.')
elseif x.prim_poly~=y.prim_poly
  error('Primitive polynomials must match.')
end

c = x.x == y.x;


