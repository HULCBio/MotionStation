function [varargout] = hess(varargin)
%HESS   Hessenberg form.
%   H = HESS(A) is the Hessenberg form of the matrix A.  
%   The Hessenberg form of a matrix is zero below the first
%   subdiagonal and has the same eigenvalues as A. If the matrix 
%   is symmetric or Hermitian, the form is tridiagonal.  
%
%   [P,H] = HESS(A) produces a unitary matrix P and a Hessenberg
%   matrix H so that A = P*H*P' and P'*P = EYE(SIZE(P)).
%
%   [AA,BB,Q,Z] = HESS(A,B) for square matrices A and B, produces
%   an upper Hessenberg matrix AA, an upper triangular matrix BB,
%   and unitary matrices Q and Z such that
%      Q*A*Z = AA,  Q*B*Z = BB.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:07:22 $
%   Built-in function.

if nargout == 0
  builtin('hess', varargin{:});
else
  [varargout{1:nargout}] = builtin('hess', varargin{:});
end
