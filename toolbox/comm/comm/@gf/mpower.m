function z = mpower(x,y,varargin)
%MPOWER  Matrix exponentiation ^ of GF array.
%   Z = X^y is X to the y power if y is a (double or int) integer
%   scalar and X is a square GF matrix. If y is an integer greater 
%   than one, the power is computed by repeated multiplication. For 
%   negative integer y, the matrix is first inverted and then inverse
%   used in repeated multiplication.  Noninteger portions of y are
%   rounded.
%
%   Z = x^Y, if Y is a square matrix and x is a scalar, is an error.
%   Z = X^Y, where both X and Y are matrices, is also an error.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/03/27 00:16:00 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2


if isa(y,'gf'), 
    error('x^y not defined for y in GF(2^M).') 
end

if(~isfinite(y))
    error('Exponentiation by Inf or NaN not defined for Galois Fields');
end

y = round(double(y)); 

% expand scalar to match size of other argument
if size(x.x,1)~=size(x.x,2)
    error('^ only defined for square matrices (and scalars)')
elseif prod(size(y))~=1
    error('in x^y, y must be a scalar')
else
    if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
        [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
    end
    z = x;
    if y == 0
        z.x = uint16(eye(size(x.x,1)));
    elseif y > 0
        z.x = x.x;
    elseif y < 0
        z = inv(x);
        x.x = z.x;
    end
    for k=2:abs(y)
        z.x = gf_mex(z.x,x.x,x.m,'mtimes',...
            x.prim_poly,GF_TABLE1,GF_TABLE2);  % <-- matrix multiply 
    end
end   



