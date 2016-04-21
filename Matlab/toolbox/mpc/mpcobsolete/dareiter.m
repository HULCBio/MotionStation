function X = dareiter(F,G1,G2,H)
%DAREITER Discrete-time algebraic Riccati equation solver.
%       X = dareiter(F, G1, G2, H)
% 	DAREITER uses an iterative doubling algorithm and returns
%	the stabilizing solution (if it exists) to the discrete-time
%	Riccati equation:
%
%         F' X F - X - F' X G1 (G2 + G1' X G1)^(-1) G1' X F + H = 0
%
%       assuming G is symmetric and nonnegative definite and H is
%       symmetric.
%

% Kjell Gustafsson
% LastEditDate : Wed Jul  4 11:21:11 1990
% Copyright 1994-2003 The MathWorks, Inc.
% Lund Institute of Technology, Lund, SWEDEN
%       $Revision: 1.1.6.2 $

Pnew = F';
Xnew = H;
Wnew = -G1/G2*G1';

X = 0*Xnew;
k = 1;

while norm(Xnew-X,1) > 1e-10*norm(X,1)
  P = Pnew;
  X = Xnew;
  W = Wnew;
  temp1 = (eye(length(X))-X*W)\P;
  temp2 = (eye(length(X))-W*X)\P';
  Pnew = P*temp1;
  Xnew = X + P*X*temp2;
  Wnew = W + P'*W*temp1;
  k = k + 1;
  if k>100
    error('No convergence');
  end
end

X = Xnew;
