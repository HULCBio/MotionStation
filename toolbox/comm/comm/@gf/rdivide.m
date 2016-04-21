function z = rdivide(x,y,varargin)
%RDIVIDE Element-wise quotient ./ of GF arrays.
%   A./B denotes element-by-element division.  A and B
%   must have the same dimensions unless one is a scalar.
%   Division by the element 0 generates an error.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:16:12 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if ~isa(x,'gf'), x = gf(x,y.m,y.prim_poly); end
if ~isa(y,'gf'), y = gf(y,x.m,x.prim_poly); end
if x.m~=y.m
  error('Orders must match.')
elseif x.prim_poly~=y.prim_poly
  error('Primitive polynomials must match.')
end
if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
  [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
end
% expand scalar to match size of other argument
if prod(size(x.x))==1
   x.x = x.x(ones(size(y.x)));
elseif prod(size(y.x))==1
   y.x = y.x(ones(size(x.x)));
end   
z = x;
z.x = gf_mex(y.x,y.x,x.m,'rdivide',...
               x.prim_poly,GF_TABLE1,GF_TABLE2);  % <-- element-wise multiplicitive inverse
z.x = gf_mex(x.x,z.x,x.m,'times',...
               x.prim_poly,GF_TABLE1,GF_TABLE2);  % <-- element-wise multiplication
