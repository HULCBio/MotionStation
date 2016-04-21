% Extracts the diagonal of a (not necessarily square) matrix
% Unlike DIAG, it properly behaves when M is 1xn or nx1

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function d=xdiag(M)

if size(M,1)==1 | size(M,2)==1,
   d=M(1,1);
else
   d=diag(M);
end
