function X = ne(A, B)
%NE     Symbolic inequality test.
%   NE(A,B) overloads symbolic A ~= B.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:22:59 $

A = sym(A);
B = sym(B);

% Scalar expansion
if ~isequal(size(A),size(B))
   if all(size(A)==1)
      A = A(ones(size(B)));
   elseif all(size(B)==1)
      B = B(ones(size(A)));
   else
      error('symbolic:sym:ne:errmsg1','Array dimensions must agree.');
   end
end

X = logical(zeros(size(A)));
for k = 1:prod(size(A))
   X(k) = ~strcmp(A(k).s,B(k).s);
end

