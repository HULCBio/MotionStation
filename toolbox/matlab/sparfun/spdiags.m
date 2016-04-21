function [res1,res2] = spdiags(arg1,arg2,arg3,arg4)
%SPDIAGS Sparse matrix formed from diagonals.
%   SPDIAGS, which generalizes the function "diag", deals with three
%   matrices, in various combinations, as both input and output.
%
%   [B,d] = SPDIAGS(A) extracts all nonzero diagonals from the m-by-n
%   matrix A.  B is a min(m,n)-by-p matrix whose columns are the p
%   nonzero diagonals of A.  d is a vector of length p whose integer
%   components specify the diagonals in A.
%
%   B = SPDIAGS(A,d) extracts the diagonals specified by d.
%   A = SPDIAGS(B,d,A) replaces the diagonals of A specified by d with
%       the columns of B.  The output is sparse.
%   A = SPDIAGS(B,d,m,n) creates an m-by-n sparse matrix from the
%       columns of B and places them along the diagonals specified by d.
%
%   Roughly, A, B and d are related by
%       for k = 1:p
%           B(:,k) = diag(A,d(k))
%       end
%
%   Example: These commands generate a sparse tridiagonal representation
%   of the classic second difference operator on n points.
%       e = ones(n,1);
%       A = spdiags([e -2*e e], -1:1, n, n)
%
%   Some elements of B, corresponding to positions "outside" of A, are
%   not actually used.  They are not referenced when B is an input and
%   are set to zero when B is an output.  If a column of B is longer than
%   the diagonal it's representing, elements of super-diagonals of A
%   correspond to the lower part of the column of B, while elements of
%   sub-diagonals of A correspond to the upper part of the column of B.
%
%   Example: This uses the top of the first column of B for the second
%   sub-diagonal and the bottom of the third column of B for the first
%   super-diagonal.
%       B = repmat((1:n)',1,3);
%       S = spdiags(B,[-2 0 1],n,n);
%
%   See also DIAG.

%   Rob Schreiber, RIACS, and Cleve Moler, 2/13/91, 6/1/92.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.12.4.3 $  $Date: 2003/10/21 11:55:59 $


if nargin <= 2
   if size(arg1,1) ~= size(arg1,2) && min(size(arg1))==1,
      error('MATLAB:spdiags:VectorInput', 'A cannot be a vector.');
   end
   % Extract diagonals
   A = arg1;
   if nargin == 1
      % Find all nonzero diagonals
      [i,j] = find(A);
      d = sort(j-i);
      d = d(find(diff([-inf; d])));
   else
      % Diagonals are specified
      d = arg2(:);
   end
   [m,n] = size(A);
   p = length(d);
   B = zeros(min(m,n),p);
   for k = 1:p
      if m >= n
         i = max(1,1+d(k)):min(n,m+d(k));
      else
         i = max(1,1-d(k)):min(m,n-d(k));
      end
      if ~isempty(i), B(i,k) = diag(A,d(k)); end
   end
   res1 = B;
   res2 = d;
end

if nargin >= 3
   % Create a sparse matrix from its diagonals
   B = arg1;
   d = arg2(:);
   p = length(d);
   moda = (nargin == 3);
   if moda
      % Modify a given matrix
      A = arg3;
   else
      % Start from scratch
      A = sparse(arg3,arg4);
   end
   
   % Process A in compact form
   [i,j,a] = find(A);
   a = [i j a];
   [m,n] = size(A);
   
   if moda
      for k = 1:p     
         % Delete current d(k)-th diagonal
         i = find(a(:,2)-a(:,1) == d(k));
         a(i,:) = [];
         % Append new d(k)-th diagonal to compact form
         i = (max(1,1-d(k)):min(m,n-d(k)))';
         a = [a; i i+d(k) B(i+(m>=n)*d(k),k)];
      end
   else
      len=zeros(p+1,1);
      for k = 1:p
          len(k+1) = len(k)+length(max(1,1-d(k)):min(m,n-d(k)));
      end
      a = zeros(len(p+1),3);
      for k = 1:p
         % Append new d(k)-th diagonal to compact form
         i = (max(1,1-d(k)):min(m,n-d(k)))';
         a((len(k)+1):len(k+1),:) = [i i+d(k) B(i+(m>=n)*d(k),k)];
      end
   end
   res1 = sparse(a(:,1),a(:,2),full(a(:,3)),m,n);
end
