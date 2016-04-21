function [varargout] = fix(varargin)
%FIX    Round towards zero.
%   FIX(X) rounds the elements of X to the nearest integers
%   towards zero.
%
%   See also FLOOR, ROUND, CEIL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:02 $
%   Built-in function.

if nargout == 0
  builtin('fix', varargin{:});
else
  [varargout{1:nargout}] = builtin('fix', varargin{:});
end
