function z = minus(x,y);
%MINUS  Subtraction - of GF arrays.
%   X - Y subtracts matrix Y from X.  X and Y must have the same
%   dimensions unless one is a scalar.  A scalar can be subtracted
%   from anything.  Note that in GF(2^M), subtraction is the
%   same operation as addition.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:15:49 $ 

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
z=gf(gf_mex(x.x,y.x,x.m,'plus',x.prim_poly),x.m,x.prim_poly);  % exactly the same as addition!
