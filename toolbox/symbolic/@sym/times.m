function X = times(A, B)
%TIMES  Symbolic array multiplication.
%   TIMES(A,B) overloads symbolic A .* B.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:23:15 $

A = sym(A);
B = sym(B);

% Scalar expansion
if ~isequal(size(A),size(B))
   if all(size(A)==1)
      A = A(ones(size(B)));
   elseif all(size(B)==1)
      B = B(ones(size(A)));
   else
      error('symbolic:sym:times:errmsg1','Array dimensions must agree.');
   end
end

X = A;
for k = 1:prod(size(A))
   X(k) = maple(A(k),'*',B(k));
end
