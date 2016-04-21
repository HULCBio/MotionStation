function [varargout] = isempty(varargin)
%ISEMPTY True for empty array.
%   ISEMPTY(X) returns 1 if X is an empty array and 0 otherwise. An
%   empty array has no elements, that is prod(size(X))==0.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:05:02 $
%   Built-in function.

if nargout == 0
  builtin('isempty', varargin{:});
else
  [varargout{1:nargout}] = builtin('isempty', varargin{:});
end
