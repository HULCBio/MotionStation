function [kest,l,p,m,z] = kalmd(sys,qn,rn,Ts)
%KALMD  Discrete Kalman estimator for continuous plant
%
%   [KEST,L,P,M,Z] = KALMD(SYS,Qn,Rn,Ts)  produces a discrete 
%   Kalman estimator KEST for the continuous plant 
%        .
%        x = Ax + Bu + Gw      {State equation}
%        y = Cx + Du +  v      {Measurements}
%
%   with process and measurement noise
%
%     E{w} = E{v} = 0,  E{ww'} = Qn,  E{vv'} = Rn,  E{wv'} = 0.
%
%   The LTI system SYS specifies the plant data (A,[B G],C,[D 0]).
%   The continuous plant and covariance matrices (Q,R) are first 
%   discretized using the sample time Ts and zero-order hold 
%   approximation, and the discrete Kalman estimator for the 
%   resulting discrete plant is then calculated with KALMAN.
%
%   Also returned are the estimator and innovation gains L and M, 
%   and the steady-state error covariances P and Z  (type 
%   HELP DKALMAN for details).
%
%   See also  LQRD, KALMAN, LQGREG.

%   Author(s): Clay M. Thompson 7-18-90, P. Gahinet  8-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 05:50:20 $

ni = nargin;
error(nargchk(4,4,ni))
if ~isa(sys,'ss'),
   error('SYS must be a state-space LTI model.')
elseif hasdelay(sys),
   if sys.Ts,
      % Map delay times to poles at z=0 in discrete-time case
      sys = delay2z(sys);
   else
      error('Not supported for continuous-time delay systems.')
   end
end

% Extract plant data 
[a,bb,c,dd] = ssdata(sys);
tsp = sys.Ts;
Nx = size(a,1);
[Ny,md] = size(dd);
if tsp~=0,
   error('Use KALMAN for discrete plants SYS.')
elseif Ny==0,
   error('C and D must be nonempty.')
end

% Check symmetry and dimensions of Qn,Rn
[Nw,Nw2] = size(qn);
Nu = md-Nw;
if Nw~=Nw2 | Nw>md,
   error('Qn must be square with fewer columns than inputs in SYS.')
elseif any(size(rn)~=Ny),
   error('Rn must be square with as many rows as measured outputs.')
elseif norm(qn'-qn,1) > 100*eps*norm(qn,1),
   warning('Qn is not symmetric and has been replaced by (Q+Q'')/2).')
elseif norm(rn'-rn,1) > 100*eps*norm(rn,1),
   warning('Rn is not symmetric and has been replaced by (R+R'')/2).')
end

% Extract B,G,D,H
b = bb(:,1:Nu);   d = dd(:,1:Nu);
g = bb(:,Nu+1:Nu+Nw);   h = dd(:,Nu+1:Nu+Nw);
if any(h(:)),
   error('Cannot handle case with direct feedthrough from w to y.')
end

% Form G*Q*G', enforce symmetry and check positivity
qn = g * qn *g';
qn = (qn+qn')/2;
rn = (rn+rn')/2;
if min(real(eig(rn)))<=0,
   error('The covariance matrix Rn must be positive definite.')
end


% Discretize the state-space system.
[ad,bd] = c2d(a,b,Ts);

% Compute discrete equivalent of continuous noise 
Za = zeros(Nx); 
M = [-a  qn ; zeros(Nx) a'];
phi = expm(M*Ts);
phi12 = phi(1:Nx,Nx+1:2*Nx);
phi22 = phi(Nx+1:2*Nx,Nx+1:2*Nx);
Qd = phi22'*phi12;
Qd = (Qd+Qd')/2;        % Make sure Qd is symmetric
Rd = rn/Ts;

% Call KALMAN on discretized plant/noise to derive KEST
set(sys,'a',ad,'b',[bd eye(Nx)],'d',[d zeros(Ny,Nx)]);
sys.Ts = Ts;
[kest,l,p,m,z] = kalman(sys,Qd,Rd);


