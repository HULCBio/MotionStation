function C = compar(A, k)
%COMPAR Comparison matrices.
%   GALLERY('COMPAR',A) is DIAG(B) - TRIL(B,-1) - TRIU(B,1),
%   where B = ABS(A). GALLERY('COMPAR',A) is often denoted by M(A)
%   in the literature.
%
%   GALLERY('COMPAR',A,1) is a modified version of A with each diagonal
%   element replaced by its absolute value and each off-diagonal
%   element A(M,N) replaced by -MAX(ABS(A(M,:))).
%   However, if A is triangular, GALLERY('COMPAR',A,1) is too.

%   Reference:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Society for Industrial and Applied Mathematics, Philadelphia,
%       1996, Chap. 8.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 03:41:20 $

if nargin == 1, k = 0; end
[m, n] = size(A);
p = min(m, n);

if k == 0

% This code uses less temporary storage than the `high level' definition above.
   C = -abs(A);
   for j=1:p
     C(j,j) = abs(A(j,j));
   end

elseif k == 1

   C = A';
   for j=1:p
       C(k,k) = 0;
   end
   mx = max(abs(C));
   C = -mx'*ones(1,n);
   for j=1:p
       C(j,j) = abs(A(j,j));
   end
   if isequal(A,tril(A)), C = tril(C); end
   if isequal(A,triu(A)), C = triu(C); end

end
