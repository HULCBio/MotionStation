function magicsquare(n)
%MAGICSQUARE generates a magic square matrix of the size specified
%    by the input parameter n.

% Copyright 2003 The MathWorks, Inc.

if (ischar(n))
    n=str2num(n);
end
magic(n)