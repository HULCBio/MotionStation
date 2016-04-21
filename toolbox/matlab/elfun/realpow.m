function [varargout] = realpow(varargin)
%REALPOW Real power.
%   Z = REALPOW(X,Y) denotes element-by-element powers.  X and Y
%   must have the same dimensions unless one is a scalar. 
%   A scalar can operate into anything.
%
%   An error is produced if the result is complex.
% 
%   See also POWER, MPOWER, REALLOG, REALSQRT.

% $Revision: 1.3.4.2 $  $Date: 2004/04/16 22:06:13 $
% Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
  builtin('realpow', varargin{:});
else
  [varargout{1:nargout}] = builtin('realpow', varargin{:});
end
