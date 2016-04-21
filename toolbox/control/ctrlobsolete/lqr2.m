function [k,p,e] = lqr2(a,b,q,r,s)
%LQR2   Linear-quadratic regulator design for continuous-time systems.
%   [K,S] = LQR2(A,B,Q,R)  calculates the optimal feedback gain matrix
%   K such that the feedback law  u = -Kx  minimizes the cost function
%
%         J = Integral {x'Qx + u'Ru} dt
%                                         .
%   subject to the constraint equation:   x = Ax + Bu 
%       
%   Also returned is S, the steady-state solution to the associated 
%   algebraic Riccati equation:
%                             -1
%           0 = SA + A'S - SBR  B'S + Q
%
%   [K,S] = LQR2(A,B,Q,R,N) includes the cross-term 2x'Nu that 
%       relates u to x in the cost functional. 
%
%   The controller can be formed with REG.
%
%   LQR2 uses the SCHUR algorithm of [1] and is more numerically
%   reliable than LQR3, which uses eigenvector decomposition.
%
%   See also: ARE, LQR, and LQE2.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:02 $

%  written-
%       11 May 87  M. Wette, ECE Dep't., Univ. of California,
%                            Santa Barbara, CA  93106, (805) 961-3616
%                  e-mail:   mwette%gauss@hub.ucsb.edu
%                            laub%lanczos@hbu.ucsb.edu
%  revised-
%       27 Aug 87  JNL
%  revised-
%       16 Mar 88  Wette & Laub
%                  (changed notation and edited documentation)

% References:
%  [1] A.J. Laub, "A Schur Method for Solving Algebraic Riccati
%  Equations", IEEE Transactions on Automatic Control, vol. AC-24,
%  1979, pp. 913-921.

% Convert data for linear-quadratic regulator problem to data for
% the algebraic Riccati equation. 
%   F = A - B*inv(R)*S'
%   G = B*inv(R)*B'
%   H = Q - S*inv(R)*S'
% R must be symmetric positive definite.

error(nargchk(4,5,nargin));
[msg,a,b]=abcdchk(a,b); error(msg);

[n,m] = size(b);
ri = inv(r);
rb = ri*b';
g = b*rb;
if (nargin > 4),
    rs = ri*s';
    f = a - b*rs;
    h = q - s*rs;
else
    f = a;
    h = q;
    rs = zeros(m,n);
end

% Solve ARE:
p = are(f,g,h);

% Find gains:
k = rs + rb*p;
if nargout==3,
   e = eig(a-b*k);
end

% end lqr2
