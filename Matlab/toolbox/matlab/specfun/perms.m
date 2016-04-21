function P = perms(V)
%PERMS  All possible permutations.
%   PERMS(1:N), or PERMS(V) where V is a vector of length N, creates a
%   matrix with N! rows and N columns containing all possible
%   permutations of the N elements.
%
%   This function is only practical for situations where N is less
%   than about 10 (for N=11, the output takes over 3 giga-bytes).
%
%   See also NCHOOSEK, RANDPERM, PERMUTE.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:55:02 $

V = V(:).'; % Make sure V is a row vector
n = length(V);
if n <= 1, P = V; return; end

q = perms(1:n-1);  % recursive calls
m = size(q,1);
P = zeros(n*m,n);
P(1:m,:) = [n * ones(m,1) q];

for i = n-1:-1:1,
   t = q;
   t(t == i) = n;
   P((n-i)*m+1:(n-i+1)*m,:) = [i*ones(m,1) t]; % assign the next m
                                               % rows in P.
end

P = V(P);
