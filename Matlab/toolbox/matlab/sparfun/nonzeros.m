function s = nonzeros(S)
%NONZEROS Nonzero matrix elements.
%   NONZEROS(S) is a full column vector of the nonzero elements of S.
%   This gives the s, but not the i and j, from [i,j,s] = find(S).
%
%   See also NNZ, FIND.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.8.4.1 $  $Date: 2004/03/02 21:48:25 $

s = sparsfun('nzvals',S);
