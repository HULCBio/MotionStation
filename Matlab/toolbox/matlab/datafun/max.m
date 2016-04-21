function [varargout] = max(varargin)
%MAX    Largest component.
%   For vectors, MAX(X) is the largest element in X. For matrices,
%   MAX(X) is a row vector containing the maximum element from each
%   column. For N-D arrays, MAX(X) operates along the first
%   non-singleton dimension.
%
%   [Y,I] = MAX(X) returns the indices of the maximum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one maximal element, the index of the first one is returned.
%
%   MAX(X,Y) returns an array the same size as X and Y with the
%   largest elements taken from X or Y.  Either one can be a scalar.
%
%   [Y,I] = MAX(X,[],DIM) operates along the dimension DIM. 
%
%   When complex, the magnitude MAX(ABS(X)) is used, and the angle
%   ANGLE(X) is ignored.  NaN's are ignored when computing the maximum.
%
%   Example: If X = [2 8 4   then max(X,[],1) is [7 8 9],
%                    7 3 9]
%
%       max(X,[],2) is [8    and max(X,5) is [5 8 5
%                       9],                   7 5 9].
%
%   See also MIN, MEDIAN, MEAN, SORT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.16.4.2 $  $Date: 2004/04/16 22:04:48 $

%   Built-in function.

if nargout == 0
  builtin('max', varargin{:});
else
  [varargout{1:nargout}] = builtin('max', varargin{:});
end
