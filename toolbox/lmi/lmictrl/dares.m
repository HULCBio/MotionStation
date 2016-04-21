function [X,L,G,RR] = dares(A,B,Q,R,S,E)

% Usage: [X,L,G,RR] = dares(A,B,Q,R,S,E)
% Given A,B,Q,R,S,E and the discrete-time algebraic Riccati equation
%                                      -1 
%    E'XE = A'XA - (A'XB + S)(B'XB + R)  (A'XB + S)' + Q
% or, equivalently, (if R is nonsingular)
%                                -1             -1                     -1
%    E'XE = F'XF - F'XB(B'XB + R)  B'XF + Q - SR  S'  (where F = A - BR  S'),
% compute the unique symmetric stabilizing nxn solution matrix X.
% Additional optional outputs include an n-vector L of closed-loop
% eigenvalues, the mxn gain matrix G given by
%                -1
% G = -(B'XB + R)  (B'XA + S'),
%
% and RR, the Frobenius norm of the relative residual matrix.
%
% Assumptions: E is nonsingular, Q=Q', R=R', and the associated
%              symplectic pencil has no eigenvalues on the unit circle.
%    Sufficient conditions to guarantee the above are stabilizability,
%    detectability, and [Q S;S' R] >= 0.
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
% Last revision: August 21, 1994
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

% Check that R matrix is correct size

if size(R) ~= [m,m]
   error('Order of R matrix must = number of columns of B matrix.')
end

if nargin < 6, E = eye(n); end
if nargin < 5, S = zeros(n,m); end

% Scaling details

   RINV = pinv(R);
   QS = Q-S*RINV*S';
   BRB = B*RINV*B';
   if BRB == 0
      error('System not scalable by this heuristic.  Use dare.m.')
   end
   rho = norm(QS,'fro')/norm(BRB,'fro');
   if rho > 1, B = sqrt(rho)*B; Q = Q/rho; S = S/sqrt(rho); end

% Set up extended pencil

a = [E zeros(n,n+m);zeros(n) A' zeros(n,m);zeros(m,n) -B' zeros(m)];
b = [A zeros(n) B;-Q E' -S;S' zeros(m,n) R];

% Compression step in case R is singular

[q,r] = qr(b(:,n2+1:n2+m));
a = q(:,n2+m:-1:m+1)'*a(:,1:n2);
b = q(:,n2+m:-1:m+1)'*b(:,1:n2);

% Do initial QZ algorithm; eigenvalues of this pencil have a tendency
% to deflate out in the "desired" order

[aa,bb,q,z] = qz(a,b,'complex');

% Find all pencil eigenvalues outside the unit circle

daa = abs(diag(aa));
dbb = abs(diag(bb));
[ignore,p] = sort(daa <= dbb);
if sum(ignore) ~= n
   error('Cannot order eigenvalues; spectrum too near unit circle.')
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
   disp('May not find symmetric solution; spectrum too near unit circle.')
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
   L = va./vb;
end

% Compute gain matrix G

if nargout > 2
   G = -(B'*X*B+R)\(B'*X*A+S');
end

% Compute Frobenius norm of relative residual

if nargout > 3
   Res = A'*X*A - E'*X*E + (A'*X*B + S)*G + Q;
   RR = norm(Res,'fro')/max(1,norm(X,'fro'));
end

% *** last line of dares.m ***
