function B = power(A,p)
%POWER  Symbolic array power.
%   POWER(A,p) overloads symbolic A.^p.
%
%   Examples:
%      A = [x 10 y; alpha 2 5];
%      A .^ 2 returns [x^2 100 y^2; alpha^2 4 25].
%      A .^ x returns [x^x 10^x y^x; alpha^x 2^x 5^x].
%      A .^ A returns [x^x 1.0000e+10 y^y; alpha^alpha 4 3125].
%      A .^ [1 2 3; 4 5 6] returns [x 100 y^3; alpha^4 32 15625].
%      A .^ magic(3) is an error.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:23:01 $

A = sym(A);
p = sym(p); 

if all(size(p) == 1)
   % Scalar exponent
   B = A;
   for k = 1:prod(size(A))
      B(k) = maple(A(k),'^',p);
   end

elseif all(size(A) == 1)
   % Scalar base
   B = p;
   for k = 1:prod(size(p))
      B(k) = maple(A,'^',p(k));
   end

elseif isequal(size(A),size(p))
   B = A;
   for k = 1:prod(size(A))
      B(k) = maple(A(k),'^',p(k));
   end

else
   error('symbolic:sym:power:errmsg1','Array dimensions must agree.')
end 
