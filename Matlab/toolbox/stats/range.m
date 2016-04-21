function y = range(x)
%RANGE  Sample range.
%   Y = RANGE(X) returns the range of the values in X.  For a vector input,
%   Y is the difference between the maximum and minimum values.  For a
%   matrix input, Y is a vector containing the range for each column.  For
%   N-D arrays, RANGE operates along the first non-singleton dimension.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.2 $  $Date: 2004/01/24 09:36:45 $

y = max(x) - min(x);
