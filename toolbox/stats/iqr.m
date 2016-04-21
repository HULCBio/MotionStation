function y = iqr(x,dim)
%IQR Interquartile range. 
%   Y = IQR(X) returns the interquartile range of the values in X.  For
%   vector input, Y is the difference between the 75th and 25th percentiles
%   of X.  For matrix input, Y is a row vector containing the interquartile
%   range of each column of X.  For N-D arrays, IQR operates along the
%   first non-singleton dimension.
%
%   The IQR is a robust estimate of the spread of the data, since changes
%   in the upper and lower 25% of the data do not affect it.
%
%   IQR(X,DIM) calculates the interquartile range along the dimension DIM
%   of X.
%
%   See also PRCTILE, STD, VAR.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.2 $  $Date: 2004/01/24 09:34:11 $

if nargin == 1
    y = diff(prctile(x, [25; 75]));
else
    y = diff(prctile(x, [25; 75],dim),[],dim);
end
