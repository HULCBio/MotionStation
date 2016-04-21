function [m,v]= poisstat(lambda);
%POISSTAT Mean and variance for the Poisson distribution.
%   [M,V] = POISSTAT(LAMBDA) returns the mean and variance of
%   the Poisson distribution with parameter LAMBDA.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.22.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.2 $  $Date: 2004/01/16 20:10:04 $

if nargin <  1, 
    error('stats:poisstat:TooFewInputs','Requires one input argument.'); 
end

% Initialize mean and variance to zero.
if isa(lambda,'single')
   m  = zeros(size(lambda),'single');
   v = zeros(size(lambda),'single');
else
   m  = zeros(size(lambda));
   v = zeros(size(lambda));
end

% Lambda must be positive.
k = find(lambda <= 0);
if any(k), 
    tmp = NaN;
    m(k)  = tmp(ones(size(k)));
    v(k) = m(k);
end

k = find(lambda > 0);
if any(k)
    m(k) = lambda(k);
    v(k) = lambda(k);
end
