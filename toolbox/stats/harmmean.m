function m = harmmean(x)
%HARMMEAN Harmonic mean.
%   M = HARMMEAN(X) returns the harmonic mean of the values in X.  For
%   vector input, M is the inverse of the mean of the inverses of the
%   elements in X.  For matrix input, M is a row vector containing the
%   harmonic mean of each column of X.  For N-D arrays, HARMMEAN operates
%   along the first non-singleton dimension.
%
%   See also MEAN, GEOMEAN, TRIMMEAN.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.2 $  $Date: 2004/01/24 09:34:03 $

% Figure out which dimension sum will work along.
sz = size(x);
dim = find(sz ~= 1, 1);
if isempty(dim), dim = 1; end

% Take the reciprocal of the mean of the reciprocals of X.
m = sz(dim) ./ sum(1./x);
