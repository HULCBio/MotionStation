function z = plus(x,y);
%PLUS  Element-by-element addition + of GF arrays.
%   X + Y adds GF matrices X and Y.  X and Y must have the same
%   dimensions unless one is a scalar (a 1-by-1 matrix).
%   A scalar can be added to anything.  
%   If either X or Y is not a GF array, it is cast into a GF
%   array with the same number of bits as the other argument.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:14:47 $ 

if ~isa(x,'gf'), x = gf(x,y.m,y.prim_poly); end
if ~isa(y,'gf'), y = gf(y,x.m,x.prim_poly); end
if x.m~=y.m
  error('Orders must match.')
elseif x.prim_poly~=y.prim_poly
  error('Primitive polynomials must match.')
end
% expand scalar to match size of other argument
if prod(size(x.x))==1
   x.x = x.x(ones(size(y.x)));
elseif prod(size(y.x))==1
   y.x = y.x(ones(size(x.x)));
end   
z=gf(gf_mex(x.x,y.x,x.m,'plus',x.prim_poly),x.m,x.prim_poly); 
 % note: addition doesn't need lookup tables
