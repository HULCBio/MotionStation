function [varargout] = isfloat(varargin)
%ISFLOAT True for floating point arrays, both single and double.
%   ISFLOAT(A) returns true if A is a floating point array and false otherwise.
%
%   Single and double are the only floating point data types in MATLAB.
%
%   Example:
%      isfloat(single(pi))
%      returns true since single is floating point data type while
%      isfloat(int8(3))
%      returns false since int8 is not a floating point data type.
%
%   See also ISA, DOUBLE, SINGLE, ISNUMERIC, ISINTEGER.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/03/08 02:01:33 $
%   Built-in function.

if nargout == 0
  builtin('isfloat', varargin{:});
else
  [varargout{1:nargout}] = builtin('isfloat', varargin{:});
end
