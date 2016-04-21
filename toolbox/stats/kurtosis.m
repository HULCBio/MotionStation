function k = kurtosis(x,flag)
%KURTOSIS Kurtosis. 
%   K = KURTOSIS(X) returns the sample kurtosis of the values in X.  For a
%   vector input, K is the fourth central moment of X, divided by fourth
%   power of its standard deviation.  For a matrix input, K is a row vector
%   containing the sample kurtosis of each column of X.  For N-D arrays,
%   KURTOSIS operates along the first non-singleton dimension.
%   
%   KURTOSIS(X,0) adjusts the kurtosis for bias.  KURTOSIS(X,1) is the same
%   as KURTOSIS(X), and does not adjust for bias.
%
%   KURTOSIS treats NaNs as missing values, and removes them.
%
%   See also MEAN, MOMENT, STD, VAR, SKEWNESS.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2004/01/24 09:34:16 $

% The output size for [] is a special case, handle it here.
if isequal(x,[])
    k = NaN;
    return;
end;

% Figure out which dimension nanmean will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim)
    dim = 1;
end

% Need to tile the output of nanmean to center X.
tile = ones(1,ndims(x));
tile(dim) = sz(dim);

% Center X, compute its fourth and second moments, and compute the
% uncorrected kurtosis.
x0 = x - repmat(nanmean(x), tile);
s2 = nanmean(x0.^2); % this is the biased variance estimator
m4 = nanmean(x0.^4);
k = m4 ./ s2.^2;

% Bias correct the kurtosis.
if nargin > 1 && flag == 0
    n = sum(~isnan(x));
    n(n<4) = NaN; % bias correction is not defined for n < 4.
    k = ((n+1).*k - 3.*(n-1)) .* (n-1)./((n-2).*(n-3)) + 3;
end
