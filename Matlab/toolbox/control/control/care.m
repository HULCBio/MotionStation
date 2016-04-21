function varargout = care(A,B,Q,varargin)
%CARE  Solve continuous-time algebraic Riccati equations.
%
%   [X,L,G] = CARE(A,B,Q,R,S,E) computes the unique stabilizing
%   solution X of the continuous-time algebraic Riccati equation
%                               -1
%      A'XE + E'XA - (E'XB + S)R  (B'XE + S') + Q = 0 .
%
%   When omitted, R, S and E are set to the default values R=I, S=0,
%   and E=I.  Beside the solution X, CARE also returns the gain matrix
%               -1
%          G = R  (B'XE + S')
%
%   and the vector L of closed-loop eigenvalues (i.e., EIG(A-B*G,E)).
%
%   [X,L,G,REPORT] = CARE(...) returns a diagnosis REPORT with
%   value:
%     * -1 if the Hamiltonian matrix has jw-axis eigenvalues
%     * -2 if there is no finite stabilizing solution X
%     * Frobenius norm of relative residual if X exists and is finite.
%   This syntax does not issue any error message when X fails to exist.
%
%   [X1,X2,D,L] = CARE(A,B,Q,...,'factor') returns two matrices 
%   X1, X2 and a diagonal scaling matrix D such that X = D*(X2/X1)*D.
%   The vector L contains the closed-loop eigenvalues.  All outputs 
%   are empty when the associated Hamiltonian matrix has eigenvalues 
%   on the imaginary axis.
%
%   [...] = CARE(A,B,Q,...,'nobalance') disables automatic scaling of 
%   the data.
%
%   See also DARE.

%   Author(s): Alan J. Laub (1993) with key contributions by Pascal Gahinet, 
%              Cleve Moler, and Andy Potvin
%   Revised: 94-10-29, 95-07-20, 96-01-09, 8-21-96
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.3 $ $Date: 2004/04/10 23:13:30 $

%   Assumptions: E is nonsingular, Q=Q', R=R' with R nonsingular, and
%                the associated Hamiltonian pencil has no eigenvalues
%                on the imaginary axis.
%   Sufficient conditions to guarantee the above are stabilizability,
%   detectability, and [Q S;S' R] >= 0, with R > 0.
%
%   Reference: W.F. Arnold, III and A.J. Laub, ``Generalized Eigenproblem
%	       Algorithms and Software for Algebraic Riccati Equations,''
%	       Proc. IEEE, 72(1984), 1746--1754.

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

% Assess whether E regular and R can be safely inverted
DescFlag = ~isequal(E,eye(n));
if DescFlag
   UseExplicitForm = false;
   if rcond(E)<eps,
      error('E must be nonsingular.')
   end        
elseif isequal(R,diag(diag(R)))
   % R is diagonal
   D = diag(R);
   if any(D==0)
      error('R matrix must be nonsingular.')
   else
      UseExplicitForm = true;  U = 1;
   end
else
   [U,D] = schur(R);
   D = diag(D);
   Da = abs(D);
   if min(Da) <= eps*max(Da),
      error('R matrix must be nonsingular.')
   else
      UseExplicitForm = (min(Da) > sqrt(eps)*max(Da));
   end
end

   
% Work with Hamiltonian matrix if E=I and R well conditioned 
% wrt inversion, otherwise use extended Hamiltonian pencil
if UseExplicitForm,
   % Form Hamitonian matrix
   %    H = [A-B/R*S'  -B/R*B' ; -Q+S/R*S'  -A'+S/R*B']
   DINV = diag(1./D);
   BU = B * U;
   SU = S * U;
   AS = A - BU * DINV * SU';
   H12 = -BU * DINV * BU';       
   H21 = -Q + SU * DINV * SU';   
   
   H = [AS (H12+H12')/2; (H21+H21')/2 -AS'];
   J = [];
else
   % Form Hamitonian pencil
   H = [A zeros(n) B;-Q -A' -S;S' B' R];
   J = blkdiag(E,E',zeros(m));
end


% Solve equation
if any(strcmp(Flags,'factor'))
   % Factored form
   [X1,X2,D,L,Report] = gcare(H,J,n,Flags{:});
   if OldSyntax
      % Pre-R14 syntax
      z = orth([D\X1;D*X2]);
      varargout = {z(1:n,:) z(n+1:end,:) L Report};
   else
      varargout = {X1 X2 D L Report};
   end
else
   [X,L,Report] = gcare(H,J,n,Flags{:});
   G = [];
   no = nargout;
   
   % Compute gain matrix G
   if Report==0 && no>2
      G = R\(B'*X*E+S');
   end
   
   % Compute relative residual
   if Report==0 && no>3
      T1 = A'*X*E + E'*X*A;
      T2 = (E'*X*B + S)*G;
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