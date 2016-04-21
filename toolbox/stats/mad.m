function y = mad(x,flag)
%MAD Mean/median absolute deviation. 
%   Y = MAD(X) returns the mean absolute deviation of the values in X.  For
%   vector input, Y is MEAN(ABS(X-MEAN(X)).  For a matrix input, Y is a row
%   vector containing the mean absolute deviation of each column of X.  For
%   N-D arrays, MAD operates along the first non-singleton dimension.
%
%   MAD(X,1) computes Y based on medians, i.e. MEDIAN(ABS(X-MEDIAN(X)).
%   MAD(X,0) is the same as MAD(X), and uses means.
%
%   MAD treats NaNs as missing values, and removes them.
%
%   See also VAR, STD, IQR.

%   References:
%      [1] L. Sachs, "Applied Statistics: A Handbook of Techniques",
%      Springer-Verlag, 1984, page 253.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.2 $  $Date: 2004/01/24 09:34:28 $

% The output size for [] is a special case, handle it here.
if isequal(x,[])
    y = NaN;
    return;
end;

if nargin < 2
    flag = 0;
end

% Figure out which dimension nanmean will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim)
    dim = 1;
end

% Need to tile the output of nanmean to center X.
tile = ones(1,ndims(x));
tile(dim) = sz(dim);

if flag
    % Compute the median of the absolute deviations from the median.
    y = nanmedian(abs(x - repmat(nanmedian(x), tile)));
else
    % Compute the mean of the absolute deviations from the mean.
    y = nanmean(abs(x - repmat(nanmean(x), tile)));
end
