function [varargout] = uminus(varargin)
%-  Unary minus.
%   -A negates the elements of A.
%
%   B = UMINUS(A) is called for the syntax '-A' when A is an object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:08:09 $

if nargout == 0
  builtin('uminus', varargin{:});
else
  [varargout{1:nargout}] = builtin('uminus', varargin{:});
end
