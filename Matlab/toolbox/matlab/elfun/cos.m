function [varargout] = cos(varargin)
%COS    Cosine.
%   COS(X) is the cosine of the elements of X. 
%
%   See also ACOS, COSD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.3 $  $Date: 2004/04/16 22:05:56 $
%   Built-in function.

if nargout == 0
  builtin('cos', varargin{:});
else
  [varargout{1:nargout}] = builtin('cos', varargin{:});
end
