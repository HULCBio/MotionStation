function [varargout] = det(varargin)
%DET    Determinant.
%   DET(X) is the determinant of the square matrix X.
%
%   Use COND instead of DET to test for matrix singularity.
%
%   See also COND.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:07:19 $
%   Built-in function.

if nargout == 0
  builtin('det', varargin{:});
else
  [varargout{1:nargout}] = builtin('det', varargin{:});
end
