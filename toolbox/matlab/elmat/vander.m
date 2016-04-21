function A = vander(v)
%VANDER Vandermonde matrix.
%   A = VANDER(V) returns the Vandermonde matrix whose columns
%   are powers of the vector V, that is A(i,j) = v(i)^(n-j).

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 03:44:50 $

n = length(v);
v = v(:);
A = ones(n);
for j = n-1:-1:1
    A(:,j) = v.*A(:,j+1);
end
