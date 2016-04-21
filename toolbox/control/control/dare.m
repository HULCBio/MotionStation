function varargout = dare(A,B,Q,varargin)
%DARE  Solve discrete-time algebraic Riccati equations.
%
%   [X,L,G] = DARE(A,B,Q,R,S,E) computes the unique stabilizing
%   solution X of the discrete-time algebraic Riccati equation
%                                      -1 
%    E'XE = A'XA - (A'XB + S)(B'XB + R)  (A'XB + S)' + Q
%
%   or, equivalently (if R is nonsingular)
%                                -1             -1                 -1
%    E'XE = F'XF - F'XB(B'XB + R)  B'XF + Q - SR  S'  with  F:=A-BR  S'.
%
%   When omitted, R, S and E are set to the default values R=I, S=0,
%   and E=I.  Beside the solution X, DARE also returns the gain matrix
%                        -1
%          G = (B'XB + R)  (B'XA + S'),
%
%   and the vector L of closed-loop eigenvalues (i.e., EIG(A-B*G,E)).
%
%   [X,L,G,REPORT] = DARE(...) returns a diagnosis REPORT with
%   value:
%     * -1 if the Symplectic matrix has eigenvalues on the unit circle
%     * -2 if there is no finite stabilizing solution X
%     * Frobenius norm of relative residual if X exists and is finite.
%   This syntax does not issue any error message when X fails to exist.
%
%   [X1,X2,D,L] = CARE(A,B,Q,...,'factor') returns two matrices 
%   X1, X2 and a diagonal scaling matrix D such that X = D*(X2/X1)*D.
%   The vector L contains the closed-loop eigenvalues.  All outputs 
%   are empty when the associated Symplectic matrix has eigenvalues 
%   on the unit circle.
%
%   See also CARE.

%   Author(s): Alan J. Laub (1993) with key contributions by Pascal Gahinet, 
%              Cleve Moler, and Andy Potvin
%   Revised: 94-10-29, 95-07-20, 95-07-24, 96-01-09
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.3 $ $Date: 2004/04/10 23:13:34 $

%       Assumptions: E is nonsingular, Q=Q', R=R', and the associated
%                    symplectic pencil has no eigenvalues on the unit circle.
%       Sufficient conditions to guarantee the above are stabilizability,
%       detectability, and [Q S;S' R] >= 0.

%	Reference: W.F. Arnold, III and A.J. Laub, ``Generalized Eigenproblem
%	           Algorithms and Software for Algebraic Riccati Equations,''
%	           Proc. IEEE, 72(1984), 1746--1754.

% Handle empty case
[n,m] = size(B);
if n==0
   varargout = {[] [] [] 0};  return
end

% Parse input list and check inputs
try
   [R,S,E,Flags,OldSyntax] = arecheckin(A,B,Q,varargin{:});
catch
   rethrow(lasterror)
end

%Check E matrix
DescFlag = ~isequal(E,eye(n));
if DescFlag && rcond(E)<eps,
   error('E must be nonsingular.')
end

% Set up extended pencil
H = [A zeros(n) B;-Q  E' -S;S' zeros(m,n) R];
J = [E zeros(n,n+m);zeros(n) A' zeros(n,m);zeros(m,n) -B' zeros(m)];

% Solve equation using generalized solver GDARE
if any(strcmp(Flags,'factor'))
   % Factored form
   [X1,X2,D,L,Report] = gdare(H,J,n,Flags{:});
   if OldSyntax
      % Pre-R14 syntax
      z = orth([D\X1;D*X2]);
      varargout = {z(1:n,:) z(n+1:end,:) L Report};
   else
      varargout = {X1 X2 D L Report};
   end
else
   [X,L,Report] = gdare(H,J,n,Flags{:});
   G = [];
   no = nargout;
   
   % Compute gain matrix G
   if Report==0 && no>2
      G = (B'*X*B+R)\(B'*X*A+S');
   end
   
   % Compute relative residual
   if Report==0 && no>3
      T1 = A'*X*A - E'*X*E;
      T2 = (A'*X*B + S)*G;
      Res = T1 - T2 + Q;
      Report = norm(Res,1)/(1+norm(T1,1)+norm(T2,1)+norm(Q,1));
   end
   
   % Exit errors
   varargout = {X L G Report};
   if no<4
      switch Report
         case -1
            error('Cannot order eigenvalues: spectrum too near the imaginary axis.')
         case -2
            error('Solution X is not finite.')
      end
   end
end   