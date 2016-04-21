function [varargout] = sum(varargin)
%SUM Sum of elements.
%   S = SUM(X) is the sum of the elements of the vector X. If
%   X is a matrix, S is a row vector with the sum over each
%   column. For N-D arrays, SUM(X) operates along the first
%   non-singleton dimension.
%   If X is floating point, that is double or single, S is
%   accumulated natively, that is in the same class as X,
%   and S has the same class as X. If X is not floating point,
%   S is accumulated in double and S has class double.
%
%   S = SUM(X,DIM) sums along the dimension DIM. 
%
%   S = SUM(X,'double') and S = SUM(X,DIM,'double') accumulate
%   S in double and S has class double, even if X is single.
%
%   S = SUM(X,'native') and S = SUM(X,DIM,'native') accumulate
%   S natively and S has the same class as X.
%
%   Examples:
%   If   X = [0 1 2
%             3 4 5]
%
%   then sum(X,1) is [3 5 7] and sum(X,2) is [ 3
%                                             12];
%
%   If X = int8(1:20) then sum(X) accumulates in double and the
%   result is double(210) while sum(X,'native') accumulates in
%   int8, but overflows and saturates to int8(127).
%
%   See also PROD, CUMSUM, DIFF, ACCUMARRAY, ISFLOAT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.5 $  $Date: 2004/04/16 22:04:52 $

%   Built-in function.

if nargout == 0
  builtin('sum', varargin{:});
else
  [varargout{1:nargout}] = builtin('sum', varargin{:});
end
