function [varargout] = transpose(varargin)
%.' Transpose.
%   X.' is the non-conjugate transpose.
%
%   B = TRANSPOSE(A) is called for the syntax A.' when A is an object.
%
%   See also CTRANSPOSE, PERMUTE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/04/16 22:08:08 $

if nargout == 0
  builtin('transpose', varargin{:});
else
  [varargout{1:nargout}] = builtin('transpose', varargin{:});
end
