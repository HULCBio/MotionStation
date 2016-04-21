function [varargout] = decpath(varargin)
%Private function used by Simulink.

% Copyright 2004 The MathWorks, Inc.
  
%   Built-in function.

[varargout{1:nargout}] = builtin('decpath', varargin{:});
