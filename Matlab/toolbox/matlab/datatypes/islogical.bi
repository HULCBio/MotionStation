function [varargout] = islogical(varargin)
%ISLOGICAL True for logical array.
%   ISLOGICAL(X) returns true if X is a logical array and false otherwise.
%   Logical arrays must be used to perform logical 0-1 indexing.
%
%   See also LOGICAL, ISNUMERIC, ISCHAR, ISOBJECT, ISJAVA.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
%   Built-in function.

if nargout == 0
  builtin('islogical', varargin{:});
else
  [varargout{1:nargout}] = builtin('islogical', varargin{:});
end
