function [u,b] = find_unique(v)
%FIND_UNIQUE - Find the unique elements in a vector
%
% U = FIND_UNIQUE(V) Take the vector V and generate a
% sorted list U of the unique elements in V.
%
% [U,B] = FIND_UNIQUE(V) Return an index matrix that 
% shows how the original matrix is produced from the 
% list, B, i.e., 
%                   V = U(B)

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/23 03:00:31 $

v = v(:);
[sortV,I] = sort(v);
repeatedInd = [logical(0) ; sortV(1:(end-1))==sortV(2:end)];
u = sortV;
u(repeatedInd) = [];

if nargout>1
    b(I) = (1:length(v))'-cumsum(repeatedInd);
end
