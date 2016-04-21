function R = dlyapchol(A, B, E)
%DLYAPCHOL  Square-root solver for discrete-time Lyapunov equations.
%
%   R = DLYAPCHOL(A,B) computes a Cholesky factorization X = R'*R of 
%   the solution X to the Lyapunov matrix equation:
%
%       A*X*A'- X + B*B' = 0
%
%   All eigenvalues of A must lie in the open unit disk for R to exist.
%
%   R = DLYAPCHOL(A,B,E) computes a Cholesky factorization X = R'*R of
%   X solving the generalized Lyapunov equation:
%
%       A*X*A' - E*X*E' + B*B' = 0
%
%   All generalized eigenvalues of (A,E) must lie in the open unit disk 
%   for R to exist.
%
%   See also DLYAP, LYAPCHOL.

%	Author(s): P. Gahinet
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.1.6.2 $  $Date: 2002/11/11 22:21:13 $
%  DLYAPCHOL is based on the SLICOT routines SB03OD and SG03BD.

ni = nargin;
error(nargchk(2,3,ni))
if ~isnumeric(A) || ~isnumeric(B) || (ni>2 && ~isnumeric(E))
   error('LYAPCHOL expects double arrays as inputs.')
end
if ni<3
   E = [];
elseif ~isreal(A) || ~isreal(B)
   error('Cannot solve equation with complex data and E matrix.')
end

% Balancing (minimize spectrum distorsions in Schur/QZ factorizations)
% RE: 1) try/catch to avoid masking error checking in MEX files
%     2) Solver works on transpose data (A',E',B')
C = B';
try
   [A,E,s] = aebalance(A',E','noperm');  % T\A*T, T\E*T
   C = lrscale(C,[],s);                  % C = B'*T
end

% Solve equation
try 
   % Call SLICOT routine SB03OD (E=[]) or SG03BD (descriptor, real)
   % or equivalent complex routines (see ZUTIL.C)
   R = hlyapslv('D',A,E,C);
   R = lrscale(R,[],1./s);   % R->R/T
catch
   rethrow(lasterror)
end