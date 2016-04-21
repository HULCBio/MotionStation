function [varargout] = find(varargin)
%FIND   Find indices of nonzero elements.
%   I = FIND(EXPR) evaluates the logical expression EXPR and returns the
%   indices of those elements of the resulting matrix that are equal to the
%   logical TRUE state.  For example, I = FIND(A > 100) returns the indices
%   of those elements of A that are greater than 100.  If EXPR is a matrix,
%   FIND returns linear indices.
% 
%   [R,C] = FIND(EXPR) returns the row and column indices of the evaluated
%   expression which are TRUE.  This syntax is especially useful when
%   working with sparse matrices.  If EXPR evaluates to an N-dimensional
%   array where N > 2, then C is a linear index over the trailing
%   dimensions. 
% 
%   [R,C,V] = FIND(EXPR) also returns a vector V containing the values that
%   correspond to the locations R,C in which EXPR is true.  Note that
%   MATLAB evaluates the expressions before it performs the find operation,
%   so V will contain the values returned after evaluating EXPR.
%
%   [...] = FIND(EXPR,K) returns at most the first K indices of EXPR that
%   evaluate to TRUE.  K must be a positive integer, but can be of any
%   numeric type.
%
%   [...] = FIND(EXPR,K,'first') returns at most the first K indices of
%   EXPR that evaluate to TRUE.
%
%   [...] = FIND(EXPR,K,'last') returns at most the last K indices of EXPR
%   that evaluate to TRUE.
%
%   See also SPARSE, IND2SUB.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.6 $  $Date: 2004/04/16 22:04:57 $
%   Built-in function.

if nargout == 0
  builtin('find', varargin{:});
else
  [varargout{1:nargout}] = builtin('find', varargin{:});
end
