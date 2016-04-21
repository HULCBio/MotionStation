function [varargout] = ceil(varargin)
%CEIL   Round towards plus infinity.
%   CEIL(X) rounds the elements of X to the nearest integers
%   towards infinity.
%
%   See also FLOOR, ROUND, FIX.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:53 $
%   Built-in function.

if nargout == 0
  builtin('ceil', varargin{:});
else
  [varargout{1:nargout}] = builtin('ceil', varargin{:});
end
