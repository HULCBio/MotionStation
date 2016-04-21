function Y = triu(X,offset)
%TRIU   Symbolic upper triangle.
%   TRIU(X) is the upper triangular part of X.
%   TRIU(X,K) is the elements on and above the K-th diagonal of
%   X.  K = 0 is the main diagonal, K > 0 is above the main
%   diagonal and K < 0 is below the main diagonal.
%
%   Examples:
%
%      Suppose
%         A =
%            [   a,   b,   c ]
%            [   1,   2,   3 ]
%            [ a+1, b+2, c+3 ]
% 
%      then
%         triu(A) returns
%            [   a,   b,   c ]
%            [   0,   2,   3 ]
%            [   0,   0, c+3 ]
%        
%         triu(A,1) returns
%            [ 0, b, c ]
%            [ 0, 0, 3 ]
%            [ 0, 0, 0 ]
%        
%         triu(A,-1) returns
%            [   a,   b,   c ]
%            [   1,   2,   3 ]
%            [   0, b+2, c+3 ]

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/15 03:08:09 $

Y = sym(zeros(size(X)));
if nargin == 1, offset = 0; end;

for m = 1: length(X)-abs(offset)
    for n = m+abs(offset): length(X)
       Y(m,n) = X(m,n);
    end;
end;

if offset < 0
   for m = 1: length(X)
      for n = max(1,m+offset):min(length(X),m-offset-1);
         Y(m,n) = X(m,n);
      end;
   end;
end;
