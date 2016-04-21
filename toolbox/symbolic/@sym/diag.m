function D = diag(A,offset)
%DIAG   Create or extract symbolic diagonals.
%   DIAG(V,K), where V is a row or column vector with N components,
%   returns a square sym matrix of order N+ABS(K) with the
%   elements of V on the K-th diagonal. K = 0 is the main
%   diagonal, K > 0 is above the main diagonal and K < 0 is
%   below the main diagonal. 
%   DIAG(V) simply puts V on the main diagonal. 
%  
%   DIAG(X,K), where X is a sym matrix, returns a column vector 
%   formed from the elements of the K-th diagonal of X. 
%   DIAG(X) is the main diagonal of X. 
%
%   Examples:
%
%      v = [a b c]
%
%      Both diag(v) and diag(v,0) return
%         [ a, 0, 0 ]
%         [ 0, b, 0 ]
%         [ 0, 0, c ]
%
%      diag(v,-2) returns
%         [ 0, 0, 0, 0, 0 ]
%         [ 0, 0, 0, 0, 0 ]
%         [ a, 0, 0, 0, 0 ]
%         [ 0, b, 0, 0, 0 ]
%         [ 0, 0, c, 0, 0 ]
%
%      A =
%         [ a, b, c ]
%         [ 1, 2, 3 ]
%         [ x, y, z ]
%
%      diag(A) returns
%         [ a ]
%         [ 2 ]
%         [ z ]
% 
%      diag(A,1) returns
%         [ b ]
%         [ 3 ]

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:08:30 $

if nargin == 1
   offset = 0; 
end;

% Vector case
if any(size(A)==1)
   A = A(:);
   d = abs(offset)+length(A);
   D(d,d) = sym;
   if offset > 0
      for k = 1:length(A) 
         D(k,k+offset) = A(k);
      end;
   else
      for k = 1:length(A)
         D(k+abs(offset),k) = A(k);
      end;
   end;

% Matrix case
else
   D = sym('0');
   if offset > 0
      for k = 1:length(A)-offset
         D(k,1) = A(k,k+offset);
      end;
   else
      for k = 1: length(A)+offset
         D(k,1) = A(k+abs(offset),k);
      end;
   end;

end;   
