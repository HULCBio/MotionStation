function [varargout] = min(varargin)
%MIN    Smallest component.
%   For vectors, MIN(X) is the smallest element in X. For matrices,
%   MIN(X) is a row vector containing the minimum element from each
%   column. For N-D arrays, MIN(X) operates along the first
%   non-singleton dimension.
%
%   [Y,I] = MIN(X) returns the indices of the minimum values in vector I.
%   If the values along the first non-singleton dimension contain more
%   than one minimal element, the index of the first one is returned.
%
%   MIN(X,Y) returns an array the same size as X and Y with the
%   smallest elements taken from X or Y. Either one can be a scalar.
%
%   [Y,I] = MIN(X,[],DIM) operates along the dimension DIM.
%
%   When complex, the magnitude MIN(ABS(X)) is used, and the angle 
%   ANGLE(X) is ignored. NaN's are ignored when computing the minimum.
%
%   Example: If X = [2 8 4   then min(X,[],1) is [2 3 4],
%                    7 3 9]
%
%       min(X,[],2) is [2    and min(X,5) is [2 5 4
%                       3],                   5 3 5].
%
%   See also MAX, MEDIAN, MEAN, SORT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.16.4.2 $  $Date: 2004/04/16 22:04:49 $

%   Built-in function.

if nargout == 0
  builtin('min', varargin{:});
else
  [varargout{1:nargout}] = builtin('min', varargin{:});
end
