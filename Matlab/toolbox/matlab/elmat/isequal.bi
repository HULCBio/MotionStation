function [varargout] = isequal(varargin)
%ISEQUAL True if arrays are numerically equal.
%   Numeric data types and structure field order
%   do not have to match.
%   NaNs are not considered equal to each other.
%
%   ISEQUAL(A,B) is 1 if the two arrays are the same size
%   and contain the same values, and 0 otherwise.
%
%   ISEQUAL(A,B,C,...) is 1 if all the input arguments are
%   numerically equal.
%
%   ISEQUAL recursively compares the contents of cell arrays and
%   structures.  If all the elements of a cell array or structure
%   are numerically equal, ISEQUAL will return 1.
%
%   If B is defined, and you set A = B; then ISEQUAL(A,B) is
%   not necessarily true. If B contains a NaN element, NaNs
%   are not equal to each other by definition, and ISEQUAL
%   will return false.
%   
%   See also ISEQUALWITHEQUALNANS, EQ.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.16.4.2 $  $Date: 2003/05/01 20:41:39 $
%   Built-in function.

if nargout == 0
  builtin('isequal', varargin{:});
else
  [varargout{1:nargout}] = builtin('isequal', varargin{:});
end
