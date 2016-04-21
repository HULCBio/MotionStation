function C = mod(A,B)
%MOD    Symbolic matrix element-wise mod.
%   C = MOD(A,B) for symbolic matrices A and B with integer elements
%   is the positive remainder in the element-wise division of A by B.  
%   For matrices A with polynomial entries, MOD(A,B) is applied to the
%   individual coefficients.
%
%   Examples:
%      ten = sym('10');
%      mod(2^ten,ten^3)
%      24
%
%      syms x
%      mod(x^3-2*x+999,10)
%      x^3+8*x+9
%
%   See also QUOREM.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:22:55 $

A = sym(A);
B = sym(B);
if all(size(B) == 1)
   C = maple('map','modp',A,B);
elseif all(size(A) == 1)
   C = maple('map2','modp',A,B);
elseif isequal(size(A),size(B));
   C = A;
   for k = 1:prod(size(A))
      C(k) = maple('modp',A(k),B(k));
   end
else
   error('symbolic:sym:mod:errmsg1','Array dimensions must agree.')
end
