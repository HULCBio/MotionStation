function [varargout] = ans(varargin)
%ANS Most recent answer.
%   ANS is the variable created automatically when expressions
%   are not assigned to anything else. ANSwer.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:04:53 $
%   Built-in function.

if nargout == 0
  builtin('ans', varargin{:});
else
  [varargout{1:nargout}] = builtin('ans', varargin{:});
end
