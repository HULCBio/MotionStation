function [varargout] = round(varargin)
%ROUND  Round towards nearest integer.
%   ROUND(X) rounds the elements of X to the nearest integers.
%
%   See also FLOOR, CEIL, FIX.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:16 $
%   Built-in function.

if nargout == 0
  builtin('round', varargin{:});
else
  [varargout{1:nargout}] = builtin('round', varargin{:});
end
