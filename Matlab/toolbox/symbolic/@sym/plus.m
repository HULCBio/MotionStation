function X = plus(A, B)
%PLUS   Symbolic addition.
%   PLUS(A,B) overloads symbolic A + B.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:23:00 $

A = sym(A);
B = sym(B);

% Scalar expansion
if ~isequal(size(A),size(B))
   if all(size(A)==1)
      A = A(ones(size(B)));
   elseif all(size(B)==1)
      B = B(ones(size(A)));
   else
      error('symbolic:sym:plus:errmsg1','Array dimensions must agree.');
   end
end

X = maple(A(:),'+',B(:));

% Fix case where Maple returns a scalar
if all(size(X) == 1)
   X = X(ones(size(A)));
end

X = reshape(X,size(A));
