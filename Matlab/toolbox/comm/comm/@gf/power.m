function z = power(x,y,varargin)
%POWER  Element-by-element exponentiation .^ of GF array.
%   Z = X.^Y denotes element-by-element powers.  X and Y
%   must have the same dimensions unless one is a scalar. 
%   X is a GF array, and Y must be double or integer.  
%   If Y is double, only its integer portion is retained.
%   The result Z is a GF array in the same field as X.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.5 $  $Date: 2002/04/14 20:11:19 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

if isa(y,'gf'), 
    error('x.^y not defined for y in GF(2^M).') 
end

if(~isfinite(y))
    error('Exponentiation by Inf or NaN not defined for Galois Fields');
end

% expand scalar to match size of other argument
if prod(size(x.x))==1
    x.x = x.x(ones(size(y)));
elseif prod(size(y))==1
    y = y(ones(size(x.x)));
end   
if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
    [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
end
% First invert wherever y1 is negative
ind=find(y<0);
x.x(ind) = gf_mex(x.x(ind),x.x(ind),x.m,'rdivide',x.prim_poly,GF_TABLE1,GF_TABLE2);
y1 = uint16(abs(y));  % Round and cast to required type
% Now raise each element to the given power:
z=gf(gf_mex(x.x,y1,x.m,'power',x.prim_poly,GF_TABLE1,GF_TABLE2),...
    x.m,x.prim_poly);  % <-- element-wise power

