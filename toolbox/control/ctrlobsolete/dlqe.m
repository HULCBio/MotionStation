function [m,p,z,e] = dlqe(a,g,c,q,r,nn)
%DLQE  Kalman estimator design for discrete-time systems.
%
%   Given the system
%
%      x[n+1] = Ax[n] + Bu[n] + Gw[n]    {State equation}
%      y[n]   = Cx[n] + Du[n] +  v[n]    {Measurements}
%
%   with unbiased process noise w[n] and measurement noise v[n] 
%   with covariances
%
%      E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
%   [M,P,Z,E] = DLQE(A,G,C,Q,R)  returns the gain matrix M such 
%   that the discrete, stationary Kalman filter with observation 
%   and time update equations
%
%      x[n|n]   = x[n|n-1] + M(y[n] - Cx[n|n-1] - Du[n])
%      x[n+1|n] = Ax[n|n] + Bu[n] 
%   
%   produces an optimal state estimate x[n|n] of x[n] given y[n] and
%   the past measurements.  The resulting Kalman estimator can be 
%   formed with DESTIM.
%
%   Also returned are the steady-state error covariances
%
%      P = E{(x[n|n-1] - x)(x[n|n-1] - x)'}     (Riccati solution)
%      Z = E{(x[n|n] - x)(x[n|n] - x)'}         (Error covariance)
%
%   and the estimator poles E = EIG(A-A*M*C).
%
%   See also  DLQEW, LQED, DESTIM, KALMAN, and DARE.

%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet, 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 06:34:14 $

ni = nargin;
error(nargchk(5,6,ni));
if ni==5,
   nn = zeros(size(q,1),size(r,1));
end

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
elseif ~isequal(size(nn),[Nw Ny]),
   error('N must have as many rows as Q and as many columns as R.')
elseif norm(q'-q,1) > 100*eps*norm(q,1),
   warning('Q is not symmetric and has been replaced by (Q+Q'')/2).')
elseif norm(r'-r,1) > 100*eps*norm(r,1),
   warning('R is not symmetric and has been replaced by (R+R'')/2).')
end


% Derive reduced matrices for DARE
qg = g * q * g';
ng = g * nn;

% Enforce symmetry and check positivity
qg = (qg+qg')/2;
r = (r+r')/2;
[u,t] = schur(r);
t = real(diag(t));  % eigenvalues of R
if min(t)<=0,
   error('The covariance matrix R  must be positive definite.')
else
   Nr = (ng*u)*diag(1./sqrt(t));   % N R^(-1/2)
   Qr = qg - Nr * Nr';             % Schur complement of [QG NG;NG' R]
   if min(real(eig(Qr)))<-1e3*eps,
      warning('The matrix [G*Q*G'' G*N;N''*G'' R] should be nonnegative definite.')
   end
end


% Call DARE to compute P
[p,e,k,report] = dare(a',c',qg,r,ng,'report');
k = k';     % K=(APC'+GN)/(R+CPC') is the filter gain s.t. 
            % x[k+1|k] = Ax[k|k-1]+Bu[k]+K(y[k]-Cx[k|k-1]-Du[k])

% Handle failure
if report==-1,
   error(...
   '(A-G*N/R*C,G*(Q-N/R*N'')*G'') or (C,A) has non minimal modes near unit circle.')
elseif report==-2,
   error('(C,A) is undetectable.')
end

% Compute M
mtrue = p*c'/(r+c*p*c');
if ~any(ng),
  % M = PC'/(R+CPC') 
  m = mtrue;
else
  % RE: for backward compatibility, M is set to A\K even though this is 
  %     not the right innovation gain when N~=0. This ensures that A*M 
  %     coincides with the filter gain K as assumed by DESTIM and DREG.
  if rcond(a)<eps,
     error('Use KALMAN to compute the correct filter gains when A is singular')
  else
     % Set M=A\K for backward compatibility
     warning('Use KALMAN to compute the correct Kalman filter when E{wv''}~=0.')
     m = a\k;
  end
end

% Compute Z=(I-MC)*P
z = (eye(Nx)-mtrue*c)*p;
z = (z+z')/2;
    

% end dlqe
