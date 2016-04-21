function y=nncopy(x,m,n)
%NNCOPY Copy matrix or cell array.
%
%  Syntax
%
%     nncopy(x,m,n)
%  
%  Description
%
%    NNCOPY(X,M,N) takes two arguments,
%      X - RxC matrix (or cell array).
%      M - Number of vertical copies.
%      N - Number of horizontal copies.
%    and returns a new (R*M)x(C*N) matrix (or cell array).
%
%  Examples
%
%     x1 = [1 2 3; 4 5 6];
%     y1 = nncopy(x1,3,2)
%     x2 = {[1 2]; [3; 4; 5]}
%     y2 = nncopy(x2,2,3)

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

[r,c] = size(x);
rowInd = rem([0:(r*m-1)],r)+1;
colInd = rem([0:(c*n-1)],c)+1;
y = x(rowInd,colInd);
