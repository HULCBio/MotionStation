function [varargout] = atanh(varargin)
%ATANH  Inverse hyperbolic tangent.
%   ATANH(X) is the inverse hyperbolic tangent of the elements of X.
%
%   See also TANH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:05:52 $
%   Built-in function.

if nargout == 0
  builtin('atanh', varargin{:});
else
  [varargout{1:nargout}] = builtin('atanh', varargin{:});
end
