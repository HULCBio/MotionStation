function [varargout] = getenv(varargin)
%GETENV Get environment variable.
%   GETENV('NAME'), where NAME is a text string, searches the underlying
%   operating system's environment list for a string of the form
%   NAME=VALUE and returns the string VALUE if such a string is present.
%   If the specified name cannot be found, an empty matrix is returned.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:58:01 $
%   Built-in function.

if nargout == 0
  builtin('getenv', varargin{:});
else
  [varargout{1:nargout}] = builtin('getenv', varargin{:});
end
