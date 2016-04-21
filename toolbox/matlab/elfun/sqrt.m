function [varargout] = sqrt(varargin)
%SQRT   Square root.
%   SQRT(X) is the square root of the elements of X. Complex 
%   results are produced if X is not positive.
%
%   See also SQRTM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:06:22 $
%   Built-in function.

if nargout == 0
  builtin('sqrt', varargin{:});
else
  [varargout{1:nargout}] = builtin('sqrt', varargin{:});
end
