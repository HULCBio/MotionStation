function m = geomean(x)
%GEOMEAN Geometric mean.
%   M = GEOMEAN(X) returns the geometric mean of the values in X.  When X
%   is an n element vector, M is the n-th root of the product of the n
%   elements in X.  For a matrix input, M is a row vector containing the
%   geometric mean of each column of X.  For N-D arrays, GEOMEAN operates
%   along the first non-singleton dimension.
%
%   See also MEAN, HARMMEAN, TRIMMEAN.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.2 $  $Date: 2003/11/01 04:26:17 $

if any(x(:) < 0)
    error('stats:geomean:BadData', 'X may not contain negative values.')
end

% Figure out which dimension sum will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim), dim = 1; end

n = sz(dim);
% Prevent divideByZero warnings for empties, but still return a NaN result.
if n == 0, n = NaN; end

% Take the n-th root of the product of elements of X, along dimension DIM.
% prod(x).^(1/n) would not give logOfZero warnings, they're an artifact of
% using logs, so silence them.
warn = warning('off', 'MATLAB:log:logOfZero');
m = exp(sum(log(x)) ./ n);
warning(warn)
