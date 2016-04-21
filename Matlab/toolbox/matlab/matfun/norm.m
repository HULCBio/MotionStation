function [varargout] = norm(varargin)
%NORM   Matrix or vector norm.
%   For matrices...
%     NORM(X) is the largest singular value of X, max(svd(X)).
%     NORM(X,2) is the same as NORM(X).
%     NORM(X,1) is the 1-norm of X, the largest column sum,
%                     = max(sum(abs(X))).
%     NORM(X,inf) is the infinity norm of X, the largest row sum,
%                     = max(sum(abs(X'))).
%     NORM(X,'fro') is the Frobenius norm, sqrt(sum(diag(X'*X))).
%     NORM(X,P) is available for matrix X only if P is 1, 2, inf or 'fro'.
%
%   For vectors...
%     NORM(V,P) = sum(abs(V).^P)^(1/P).
%     NORM(V) = norm(V,2).
%     NORM(V,inf) = max(abs(V)).
%     NORM(V,-inf) = min(abs(V)).
%
%   See also COND, RCOND, CONDEST, NORMEST.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.2 $  $Date: 2004/04/16 22:07:26 $
%   Built-in function.

if nargout == 0
  builtin('norm', varargin{:});
else
  [varargout{1:nargout}] = builtin('norm', varargin{:});
end
