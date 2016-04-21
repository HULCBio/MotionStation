function y = nanvar(x)
%NANVAR Variance, ignoring NaNs.
%   Y = NANVAR(X) returns the sample variance of the values in X, treating
%   NaNs as missing values.  For a vector input, Y is the variance of the
%   non-NaN elements of X.  For a matrix input, Y is a row vector
%   containing the variance of the non-NaN elements in each column of X.
%   For N-D arrays, NANVAR operates along the first non-singleton dimension
%   of X.
%
%   See also VAR, NANSTD, NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:34:37 $

% The output size for [] is a special case, handle it here.
if isequal(x,[]), y = NaN; return; end;

% Figure out which dimension sum will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim), dim = 1; end

% Count up non-NaNs, and set the divisor.  For one datum, set it to return 0,
% for no data, set it to return NaN.
n = sum(~isnan(x));
denom = max(n - 1, 1);
denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

% Need to tile the mean of X to center it.
tile = ones(1,ndims(x)); tile(dim) = sz(dim);

x0 = x - repmat(nanmean(x), tile);
y = nansum(conj(x0).*x0) ./ denom;
