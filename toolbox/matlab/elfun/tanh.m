function [varargout] = tanh(varargin)
%TANH   Hyperbolic tangent.
%   TANH(X) is the hyperbolic tangent of the elements of X.
%
%   See also ATANH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.3 $  $Date: 2004/04/16 22:06:24 $
%   Built-in function.

if nargout == 0
  builtin('tanh', varargin{:});
else
  [varargout{1:nargout}] = builtin('tanh', varargin{:});
end
