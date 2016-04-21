function [varargout] = isinteger(varargin)
%ISINTEGER True for arrays of integer data type.
%   ISINTEGER(A) returns true if A is an array of integer data type and false
%   otherwise.
%
%   The 8 integer data types in MATLAB are int8, uint8, int16, uint16,
%   int32, uint32, int64 and uint64.
%
%   Example:
%      isinteger(int8(3))
%      returns true because int8 is a valid integer data type but
%      isinteger (3)
%      returns false since the constant 3 is actually a double as is shown by
%      class(3)
%
%   See also ISA, ISNUMERIC, ISFLOAT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/03/08 02:01:34 $
%   Built-in function.

if nargout == 0
  builtin('isinteger', varargin{:});
else
  [varargout{1:nargout}] = builtin('isinteger', varargin{:});
end
