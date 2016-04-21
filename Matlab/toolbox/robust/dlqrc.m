function [K,P,Perr] = dlqrc(A,B,QRN,aretype)
%DLQRC Discrete optimal LQR control synthesis.
%
% [K,P,PERR] = DLQRC(A,B,QRN,ARETYPE) solves the discrete Riccati equation
%     and produces the discrete optimal LQR feedback gain K such that the
%     feedback law u = -Kx minimizes the cost function in time interval [i,n]
%             n-1
%  J(i) = 1/2 SUM { [x(k)' u(k)'] | Q  N | |x(k)| }; ( QRN := |Q  N| )
%             k=i                 | N' R | |u(k)|    (        |N' R| )
%
%     subject to the constraint equation: x(k+1) = A(k)x(k) + B(k)u(k)
%     Also returned is P, the steady-state solution to the discrete ARE:
%				           -1
%		0 = A'PA - P - A'PB(R+B'PB)  B'P'A + Q
%
%     In addition, it will calculate the residual of the ARE. If the
%     problem is ill-posed such that the residual is large or there
%     exists closed loop poles with unity magnitude, a warning message
%     will be displayed.
%
%     aretype = 'eigen' --- solve Riccati via eigenstructure (default)
%     aretype = 'schur' --- solve Riccati via Schur method.
%

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

if nargin == 3
   aretype = 'eigen';
end

aretype = lower(aretype);

%
[n,n] = size(A);
[Q,N,NT,R] = sys2ss(QRN,n);
Q = Q - N/R*NT;
A = A - B/R*NT;
[P1,P2,lamp,Perr,wellposed,P] = daresolv(A,B,Q,R,aretype);
K = (R+B'*P*B)\B'*P*A + R\NT;
%
% ------ End of DLQRC.M ---- RYC/MGS %
