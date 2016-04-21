function y = nansum(x)
%NANSUM Sum, ignoring NaNs.
%   Y = NANSUM(X) returns the sum of X, treating NaNs as missing values.
%   For vector input, Y is the sum of the non-NaN elements in X.  For
%   matrix input, Y is a row vector containing the sum of non-NaN elements
%   in each column.  For N-D arrays, NANSUM operates along the first
%   non-singleton dimension.
%
%   See also SUM, NANMEAN, NANVAR, NANSTD, NANMIN, NANMAX, NANMEDIAN.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.10.2.3 $  $Date: 2004/01/24 09:34:36 $

% Sum up non-NaNs.  Cols of all NaNs will return zero.
x(isnan(x)) = 0;
y = sum(x);
