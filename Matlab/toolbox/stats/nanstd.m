function y = nanstd(x)
%NANSTD Standard deviation, ignoring NaNs.
%   Y = NANSTD(X) returns the sample standard deviation of the values in X,
%   treating NaNs as mssing values.  For a vector input, Y is the standard
%   deviation of the non-NaN elements of X.  For a matrix input, Y is a row
%   vector containing the standard deviation of the non-NaN elements in
%   each column of X. For N-D arrays, NANSTD operates along the first
%   non-singleton dimension of X.
%
%   See also STD, NANVAR, NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.10.2.4 $  $Date: 2004/01/24 09:34:35 $

y = sqrt(nanvar(x));
