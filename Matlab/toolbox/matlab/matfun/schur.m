function [varargout] = schur(varargin)
%SCHUR  Schur decomposition.
%   [U,T] = SCHUR(X) produces a quasitriangular Schur matrix T and
%   a unitary matrix U so that X = U*T*U' and U'*U = EYE(SIZE(U)).
%   X must be square.
%
%   T = SCHUR(X) returns just the Schur matrix T.
%
%   If X is complex, the complex Schur form is returned in matrix T.
%   The complex Schur form is upper triangular with the eigenvalues
%   of X on the diagonal.
%
%   If X is real, two different decompositions are available.
%   SCHUR(X,'real') has the real eigenvalues on the diagonal and the
%   complex eigenvalues in 2-by-2 blocks on the diagonal.
%   SCHUR(X,'complex') is triangular and is complex if X has complex
%   eigenvalues.  SCHUR(X,'real') is the default.
%
%   See RSF2CSF to convert from Real to Complex Schur form.
%
%   See also ORDSCHUR, QZ.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.3 $  $Date: 2004/04/16 22:07:33 $
%   Built-in function.

if nargout == 0
  builtin('schur', varargin{:});
else
  [varargout{1:nargout}] = builtin('schur', varargin{:});
end
