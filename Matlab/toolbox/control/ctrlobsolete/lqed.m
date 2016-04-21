function [l,p,z,e] = lqed(a,g,c,q,r,Ts)
%LQED  Discrete Kalman estimator design from continuous 
%      cost function.
%
%   [M,P,Z,E] = LQED(A,G,C,Q,R,Ts) calculates the discrete Kalman 
%   gain matrix M that minimizes the discrete estimation error 
%   equivalent to the estimation error for the continuous system
%            .
%            x = Ax + Bu + Gw    {State equation}
%            y = Cx + Du +  v    {Measurements}
%
%   with process and measurement noise
%      E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R,  E{wv'} = 0.
%
%   Also returned are the discrete Riccati solution P, the estimate
%   error covariance Z, and the discrete estimator poles 
%   E = EIG(Ad-Ad*M*C).  The resulting discrete Kalman estimator can 
%   be formed with DESTIM.
%
%   The continuous plant (A,B,C,D) and continuous covariance matrices 
%   (Q,R) are discretized using the sample time Ts and zero-order hold 
%   approximation.  The gain matrix M is then calculated using DLQE.
%
%   See also  DLQE, LQE, LQRD, and DESTIM.

%   Clay M. Thompson 7-18-90
%   Revised: P. Gahinet  7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:33:08 $

% Reference: This routine is based on the routine DISRW.M by Franklin, 
% Powell and Workman and is described on pp. 454-455 of "Digital Control
% of Dynamic Systems".

ni = nargin;
error(nargchk(6,6,ni));

% Check dimensions and symmetry
error(abcdchk(a,[],c,[]))
Nx = size(a,1);
Nw = size(g,2);
Ny = size(c,1);
if Nx~=size(g,1),
   error('The A and G matrices must have the same number of rows.')
elseif any(size(q)~=Nw),
   error('Q must be square with as many columns as G.')
elseif any(size(r)~=Ny),
   error('The R matrix must be square with as many rows as C.')
elseif norm(q'-q,1) > 100*eps*norm(q,1),
   warning('Q is not symmetric and has been replaced by (Q+Q'')/2).')
elseif norm(r'-r,1) > 100*eps*norm(r,1),
   warning('R is not symmetric and has been replaced by (R+R'')/2).')
end


% Discretize the state-space system.
ad = expm(a*Ts);

% Compute discrete equivalent of continuous noise 
Za = zeros(Nx); 
M = [ -a  g*q*g'
      Za   a'   ];
phi = expm(M*Ts);
phi12 = phi(1:Nx,Nx+1:2*Nx);
phi22 = phi(Nx+1:2*Nx,Nx+1:2*Nx);
Qd = phi22'*phi12;
Qd = (Qd+Qd')/2;        % Make sure Qd is symmetric
Rd = r/Ts;

% Call DARE to compute P
[p,e,k,report] = dare(ad',c',Qd,Rd,'report');

% Handle failure
if report==-1,
   error(...
   '(Ad,Qd) or (C,Ad) has non minimal modes near unit circle.')
elseif report==-2,
   error('(C,Ad) is undetectable.')
end

% Compute L and Z
l = p*c'/(Rd+c*p*c');
z = (eye(Nx)-l*c)*p;
z = (z+z')/2;


% end lqed

