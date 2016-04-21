function z=conv(x,y);
%CONV  Convolution of GF vectors.
%   C = CONV(A, B) convolves GF vectors A and B.  The resulting
%   vector has length LENGTH(A)+LENGTH(B)-1. 
%   If A and B are vectors of polynomial coefficients, convolving
%   them is equivalent to multiplying the two polynomials.
%
%   See also CONVMTX.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:15:10 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if ~isa(x,'gf'), x = gf(x,y.m,y.prim_poly); end
if ~isa(y,'gf'), y = gf(y,x.m,x.prim_poly); end

if x.m~=y.m
  error('Orders must match.')
elseif x.prim_poly~=y.prim_poly
  error('Primitive polynomials must match.')
end

z = x;

% zero pad:
z.x(length(x.x)+length(y.x)-1) = 0;
z.x = uint16(zeros(size(z.x)));

if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
   [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
end

for k = 1:length(x.x)
  for j = 1:length(y.x)
    z.x(k+j-1) = bitxor(z.x(k+j-1),gf_mex(x.x(k),y.x(j),x.m,'times',...
                                     x.prim_poly,GF_TABLE1,GF_TABLE2));
  end
end

% make the orientation match the longest input
if(length(x) > length(y))
    %follow x
    if( find(size(x)==1) ~= find(size(z)==1))
        z = z';
    end
else
    %follow y
    if( find(size(y)==1) ~=find(size(z)==1))
        z = z';
    end
end

