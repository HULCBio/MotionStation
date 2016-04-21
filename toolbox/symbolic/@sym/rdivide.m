function X = rdivide(A, B)
%RDIVIDE Symbolic array right division.
%   RDIVIDE(A,B) overloads symbolic A ./ B.
%
%   See also LDIVIDE, MRDIVIDE, MLDIVIDE, QUOREM.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:23:04 $

A = sym(A);
B = sym(B);

% Scalar expansion
if ~isequal(size(A),size(B))
   if all(size(A)==1)
      A = A(ones(size(B)));
   elseif all(size(B)==1)
      B = B(ones(size(A)));
   else
      error('symbolic:sym:rdivide:errmsg1','Array dimensions must agree.');
   end
end

X = A;
for k = 1:prod(size(A))
   if B(k) ~= 0
      X(k) = maple(A(k),'/',B(k));
   elseif A(k) ~= 0
      X(k) = Inf;
   else
      X(k) = NaN;
   end
end
