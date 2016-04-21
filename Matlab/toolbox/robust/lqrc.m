function [K,P,P1,P2] = lqrc(A,B,QRN,aretype)
%LQRC Continuous optimal LQR control synthesis.
%
% [K,P,P1,P2] = LQRC(A,B,QRN,ARETYPE) solves the Riccati equation and
%     produces the optimal LQR feedback gain K such that the feedback law
%     u = -Kx minimizes the cost function:
%
%       J = 1/2 Integral { [x' u'] | Q  N | |x| } dt ; ( QRN := |Q  N| )
%                                  | N' R | |u|        (        |N' R| )
%                                           .
%     subject to the constraint equation: x = Ax + Bu.
%     Also returned is P, the steady-state solution to the ARE:
%				      -1
%		0 = A'P + PA - (PB+N)R  (B'P+N') + Q
%
%     In addition, it will calculate the residual of the ARE. If the
%     problem is ill-posed such that the residual is large or there
%     exists jw-axis closed loop poles, a warning message will be displayed.
%
%     aretype = 'eigen' --- solve Riccati via eigenstructure (default)
%     aretype = 'schur' --- solve Riccati via Schur method.
%

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

nag1 = nargin;

if nag1 == 3
   aretype = 'eigen';
end

aretype = lower(aretype);

%
[n,n] = size(A);
[Q,N,NT,R] = sys2ss(QRN,n);
Q = Q - N/R*NT;
A = A - B/R*NT;
RR = B/R*B';
[P1,P2,lamp,Perr,wellposed,P] = aresolv(A,Q,RR,aretype);
K = R\(NT + B'*P);
%
% ------ End of LQRC.M ---- RYC/MGS %
