function [varargout] = isnumeric(varargin)
%ISNUMERIC True for numeric arrays.
%   ISNUMERIC(A) returns true if A is a numeric array and false otherwise. 
%
%   For example, integer and float (single and double) arrays are numeric,
%   while logicals, strings, cell arrays, and structure arrays are not.
%
%   Example:
%      isnumeric(pi)
%      returns true since pi has class double while
%      isnumeric(true)
%      returns false since true has data class logical.
%
%   See also ISA, DOUBLE, SINGLE, ISFLOAT, ISINTEGER, ISSPARSE, ISLOGICAL, ISCHAR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/03/08 02:01:36 $

if nargout == 0
  builtin('isnumeric', varargin{:});
else
  [varargout{1:nargout}] = builtin('isnumeric', varargin{:});
end
