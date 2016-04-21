function [varargout] = ctranspose(varargin)
%'   Complex conjugate transpose.   
%    X' is the complex conjugate transpose of X. 
%
%    B = CTRANSPOSE(A) is called for the syntax A' (complex conjugate
%    transpose) when A is an object.
%
%    See also TRANSPOSE.

%    Copyright 1984-2003 The MathWorks, Inc.
%    $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:07:43 $

if nargout == 0
  builtin('ctranspose', varargin{:});
else
  [varargout{1:nargout}] = builtin('ctranspose', varargin{:});
end
