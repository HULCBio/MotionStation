function [varargout] = mldivide(varargin)
%\   Backslash or left matrix divide.
%   A\B is the matrix division of A into B, which is roughly the
%   same as INV(A)*B , except it is computed in a different way.
%   If A is an N-by-N matrix and B is a column vector with N
%   components, or a matrix with several such columns, then
%   X = A\B is the solution to the equation A*X = B computed by
%   Gaussian elimination. A warning message is printed if A is
%   badly scaled or nearly singular.  A\EYE(SIZE(A)) produces the
%   inverse of A.
%
%   If A is an M-by-N matrix with M < or > N and B is a column
%   vector with M components, or a matrix with several such columns,
%   then X = A\B is the solution in the least squares sense to the
%   under- or overdetermined system of equations A*X = B. The
%   effective rank, K, of A is determined from the QR decomposition
%   with pivoting. A solution X is computed which has at most K
%   nonzero components per column. If K < N this will usually not
%   be the same solution as PINV(A)*B.  A\EYE(SIZE(A)) produces a
%   generalized inverse of A.
%
%   C = MLDIVIDE(A,B) is called for the syntax 'A \ B' when A or B is an
%   object.
%
%   See also LDIVIDE, RDIVIDE, MRDIVIDE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:53 $

if nargout == 0
  builtin('mldivide', varargin{:});
else
  [varargout{1:nargout}] = builtin('mldivide', varargin{:});
end
