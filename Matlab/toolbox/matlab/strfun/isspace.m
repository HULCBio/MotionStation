function [varargout] = isspace(varargin)
%ISSPACE True for white space characters.
%   For a string S, ISSPACE(S) is 1 for white space characters and
%   0 otherwise.  White space characters are spaces, newlines,
%   carriage returns, tabs, vertical tabs, and formfeeds.
%
%   See also ISLETTER.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/10 23:32:40 $

%   Built-in function.

if nargout == 0
  builtin('isspace', varargin{:});
else
  [varargout{1:nargout}] = builtin('isspace', varargin{:});
end
