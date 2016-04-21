function [varargout] = acos(varargin)
%ACOS   Inverse cosine.
%   ACOS(X) is the arccosine of the elements of X. Complex
%   results are obtained if ABS(x) > 1.0 for some element.
%
%   See also COS, ACOSD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.3 $  $Date: 2004/04/16 22:05:40 $
%   Built-in function.

if nargout == 0
  builtin('acos', varargin{:});
else
  [varargout{1:nargout}] = builtin('acos', varargin{:});
end
