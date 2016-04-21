function [varargout] = uplus(varargin)
%+  Unary plus.
%   +A for numeric arrays is A. 
%
%   B = UPLUS(A) is called for the syntax '+A' when A is an object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:08:12 $

if nargout == 0
  builtin('uplus', varargin{:});
else
  [varargout{1:nargout}] = builtin('uplus', varargin{:});
end
