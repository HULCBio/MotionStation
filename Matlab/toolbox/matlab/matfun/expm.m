function [varargout] = expm(varargin)
%EXPM   Matrix exponential.
%   EXPM(X) is the matrix exponential of X.  EXPM is computed using
%   a scaling and squaring algorithm with a Pade approximation.
%
%   Although it is not computed this way, if X has a full set
%   of eigenvectors V with corresponding eigenvalues D, then
%   [V,D] = EIG(X) and EXPM(X) = V*diag(exp(diag(D)))/V.
%
%   EXP(X) computes the exponential of X element-by-element.
%
%   See also LOGM, SQRTM, FUNM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/16 22:07:21 $
%   Built-in function.

if nargout == 0
  builtin('expm', varargin{:});
else
  [varargout{1:nargout}] = builtin('expm', varargin{:});
end
