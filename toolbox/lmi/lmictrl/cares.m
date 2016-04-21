function [X,L,G,RR] = cares(A,B,Q,R,S,E)

% Usage: [X,L,G,RR] = cares(A,B,Q,R,S,E)
% Given A,B,Q,R,S,E and the continuous-time algebraic Riccati equation
%                             -1
%    A'XE + E'XA - (E'XB + S)R  (B'XE + S') + Q = 0
% or, equivalently,
%                       -1             -1                         -1
%    F'XE + E'XF - E'XBR  B'XE + Q - SR  S' = 0  (where F = A - BR  S'),
% compute the unique symmetric stabilizing nxn solution matrix X.
% Additional optional outputs include an n-vector L of closed-loop
% eigenvalues, the mxn gain matrix G given by
%       -1
% G = -R  (B'XE + S'),
%
% and RR, the Frobenius norm of the relative residual matrix.
%
% Assumptions: E is nonsingular, Q=Q', R=R' with R nonsingular, and
%              the associated Hamiltonian pencil has no eigenvalues
%              on the imaginary axis.
%    Sufficient conditions to guarantee the above are stabilizability,
%    detectability, and [Q S;S' R] >= 0, with R > 0.
%
% If S and E are not specified, they are set to the default values
% S = 0 and E = I.  This code version implements a heuristic automatic
% scaling strategy but no iterative improvement.  The scaling strategy
% assumes that B is not 0; if B = 0, a Lyapunov solver can be employed.

% Reference: W.F. Arnold, III and A.J. Laub, "Generalized Eigenproblem
%            Algorithms and Software for Algebraic Riccati Equations,"
%            Proc. IEEE, 72(1984), 1746--1754.

% Written by: Alan J. Laub (1993)  (laub@ece.ucsb.edu)
%    with key contributions by Pascal Gahinet and Cleve Moler
% Last revision: July 1, 1994
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $


% Estimate relative machine precision eps

eps = 1;
while (1+eps) > 1
   eps = eps/2;
end
eps = 2*eps;

[n,m] = size(B);
n2 = 2*n;

% Check that R matrix is correct size and nonsingular

if size(R) ~= [m,m]
   error('Order of R matrix must = number of columns of B matrix.')
end
if eps*cond(R) > 1
   error('R matrix must be nonsingular in continuous-time case.')
end

if nargin < 6, E = eye(n); end
if nargin < 5, S = zeros(n,m); end

% Exploit R being diagonal; else use extended pencil

if (diag(diag(R))-R) == 0
   RINV = diag(diag(R).\1);
   AS = A-B*RINV*S';
   QS = Q-S*RINV*S';
   BRB = B*RINV*B';
   if BRB == 0
      error('B = 0.  Use Lyapunov solver instead.')
   end

   % Scaling details

   rho = norm(QS,'fro')/norm(BRB,'fro');
   if rho > 1, BRB = rho*BRB; QS = QS/rho; end
   if rho > 1, B = sqrt(rho)*B; Q = Q/rho; S = S/sqrt(rho); end
   normH = norm([AS -BRB;-QS -AS'],'fro');

   a = [AS-normH*E -BRB;-QS -AS'-normH*E'];
   b = [AS+normH*E -BRB;-QS -AS'+normH*E'];
else
   % Set up extended pencil after scaling

   AS = A-B/R*S';
   QS = Q-S/R*S';
   BRB = B/R*B';
   if BRB == 0
      error('B = 0.  Use Lyapunov solver instead.')
   end
   rho = norm(QS,'fro')/norm(BRB,'fro');
   if rho > 1, B = sqrt(rho)*B; Q = Q/rho; S = S/sqrt(rho); end
   normH = norm([AS -BRB;-QS -AS'],'fro');

   a = [A-normH*E zeros(n) B;-Q -A'-normH*E' -S;S' B' R];
   b = [A+normH*E zeros(n) B;-Q -A'+normH*E' -S;S' B' R];

   % Compression step in case R is ill-conditioned w.r.t. inversion

   [q,r] = qr(a(:,n2+1:n2+m));
   a = q(:,n2+m:-1:m+1)'*a(:,1:n2);
   b = q(:,n2+m:-1:m+1)'*b(:,1:n2);

end

% Do initial QZ algorithm; eigenvalues of this pencil have a tendency
% to deflate out in the "desired" order

[aa,bb,q,z] = qz(a,b,'complex');

% Find all pencil eigenvalues outside the unit circle

daa = abs(diag(aa));
dbb = abs(diag(bb));
[ignore,p] = sort(daa <= dbb);
if sum(ignore) ~= n
   error('Cannot order eigenvalues; spectrum too near imaginary axis.')
end

% Order pencil eigenvalues so that those outside the unit circle are in the
% leading n positions

p(p) = 1:n2;     % inverse permutation
for j = n2:-1:2
   i = find(p==j);
   for k = i:j-1
      [aa,bb,z] = qzexch(aa,bb,z,k);
   end
   p(i) = [];
end

% Account for non-identity E matrix and orthonormalize basis

if nargin > 5
   x1 = E*z(1:n,1:n);
   a = [x1;z(n+1:n2,1:n)];
   [q,r] = qr(a);
   z = q(:,1:n);
end

% Check for symmetry of solution

z1 = z(1:n,1:n);
z2 = z(n+1:n2,1:n);
z12 = z1'*z2;
if norm(z12-z12',1) > sqrt(eps)*norm(z1,1)
   disp('May not find symmetric solution; spectrum too near imaginary axis.')
end

% Solve for X via ``QZ symmetrization trick''
% (should be better than z2/z1)

[uu,vv,u,v] = qz(z1,z2,'complex');
X = u'*diag(diag(vv)./diag(uu))*u;
X = real(X);

% Undo scaling factor

if rho > 1, X = rho*X; B = B/sqrt(rho); Q = rho*Q; S = sqrt(rho)*S; end

% Compute L = vector of n closed-loop eigenvalues; use the
% last n elements of diag(aa)./diag(bb) to avoid dealing with
% infinite eigenvalues in the first n components

if nargout > 1
   va = diag(aa); vb = diag(bb);
   va = va(n+1:n2); vb = vb(n+1:n2);
   % Undo implicit Cayley transform
   L = (va+vb)./(va-vb);
   L = normH*L;
end

% Compute gain matrix G

if nargout > 2
   G = -R\(B'*X*E+S');
end

% Compute Frobenius norm of relative residual

if nargout > 3
   Res = A'*X*E + E'*X*A + (E'*X*B + S)*G + Q;
   RR = norm(Res,'fro')/max(1,norm(X,'fro'));
end

% *** last line of cares.m ***
