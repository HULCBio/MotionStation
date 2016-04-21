function [varargout] = floor(varargin)
%FLOOR  Round towards minus infinity.
%   FLOOR(X) rounds the elements of X to the nearest integers
%   towards minus infinity.
%
%   See also ROUND, CEIL, FIX.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:03 $
%   Built-in function.

if nargout == 0
  builtin('floor', varargin{:});
else
  [varargout{1:nargout}] = builtin('floor', varargin{:});
end
