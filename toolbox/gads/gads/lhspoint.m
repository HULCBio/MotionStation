function x = lhspoint(n,p)
%LHSPOINT Generates latin hypercube points.
%  	X = LHSPOINT(N,P) Generates a latin hypercube sample X containing N
%  	values on each of P variables.  For each column, the N values are
% 	 randomly distributed with one from each interval (0,1/N), (1/N,2/N),
% 	 ..., (N-1/N,1), and they are randomly permuted.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2004/01/16 16:52:05 $

x = rand(n,p);
for i=1:p
    x(:,i) = rank(x(:,i));
end
x = x - rand(size(x));
x = x / n;
x = x';
%Safegaurd which should not occur in LHS
x(:,(~any(x))) = [];

%------------RANK function used by lhspoint
function r=rank(x)
[sx, rowidx] = sort(x);
r(rowidx) = 1:length(x);
r = r(:);
