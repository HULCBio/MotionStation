function [m,p,z,e] = dlqew(a,g,c,h,q,r,nn)
%DLQEW  Kalman estimator for discrete-time systems with process 
%   noise feedthrough.
%
%   Given the system
%
%      x[k+1] = Ax[k] + Bu[k] + Gw[k]           {State equation}
%      y[k]   = Cx[k] + Du[k] + Hw[k] + v[k]    {Measurements}
%
%   with unbiased process noise w[k] and measurement noise v[k] 
%   with covariances
%
%      E{ww'} = Q,    E{vv'} = R,    E{wv'} = 0 ,
%
%   [M,P,Z,E] = DLQEW(A,G,C,H,Q,R)  returns the gain matrix M such 
%   that the discrete, stationary Kalman filter with observation 
%   and time update equations
%
%      x[k|k]   = x[k|k-1] + M(y[k] - Cx[k|k-1] - Du[k])
%      x[k+1|k] = Ax[k|k] + Bu[k] 
%
%   produces an optimal state estimate x[k|k] of x[k] given y[k] and
%   the past measurements.  The resulting Kalman estimator can be 
%   formed with DESTIM.
%
%   Also returned are the steady-state error covariances
%
%      P = E{(x[k|k-1] - x)(x[k|k-1] - x)'}     (Riccati solution)
%      Z = E{(x[k|k] - x)(x[k|k] - x)'}         (Error covariance)
%
%   and the estimator poles E = EIG(A-A*M*C).
%
%   See also  DLQE, LQED, DESTIM, KALMAN, and DARE.

%   Clay M. Thompson  7-23-90
%   Revised: P. Gahinet 7-25-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 06:34:11 $

ni = nargin;
error(nargchk(6,7,ni));
if ni==6,
   nn = zeros(size(q,1),size(r,1));
end


% Check dimensions and symmetry
error(abcdchk(a,[],c,[]))
Nx = size(a,1);
Nw = size(g,2);
Ny = size(c,1);
if Nx~=size(g,1),
   error('The A and G matrices must have the same number of rows.')
elseif ~isequal(size(h),[Ny Nw])
   error('H  must have as many rows as C and as many columns as G.')
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


% Derive reduced matrices for DARE.  First derive the equivalent 
% Q,N,R for the auxiliary measurement noise vv = Hw+v
hn = h * nn;
nn = q * h' + nn;                    
rr = r  + hn + hn' + h * q * h';     % RR = R+H*N+N'*H'+H*Q*H'
% Then incorporate G
qq = g * q * g';                     % QQ = G*Q*G'
nn = g * nn;                         % NN = G*(Q*H'+N)


% Enforce symmetry and check positivity
qq = (qq+qq')/2;
rr = (rr+rr')/2;
[u,t] = schur(rr);
t = real(diag(t));  % eigenvalues of RR
if min(t)<=0,
   error('The covariance matrix of Hw+v must be positive definite.')
else
   Nr = (nn*u)*diag(1./sqrt(t));   % NN RR^(-1/2)
   Qr = qq - Nr * Nr';             % Schur complement of [QQ NN;NN' RR]
   if min(real(eig(Qr)))<-1e3*eps,
      warning(...
        'The matrix [G 0;H I]*[Q N;N'' R]*[G 0;H I]'' should be nonnegative definite.')
   end
end


% Call DARE to compute P
[p,e,k,report] = dare(a',c',qq,rr,nn,'report');
k = k';    % A*L=(APC'+NN)/(RR+CPC') is the transposed Riccati gain 

% Handle failure
if report==-1,
   error(sprintf(...
    ['(C,A) or (A-G*NN/RR*C,G*(Q-NN/RR*NN'')*G'') has non minimal modes\n' ...
     'near unit circle where  NN = Q*H''+N  and  RR = R+H*N+N''*H''+H*Q*H''.']))
elseif report==-2,
   error('(C,A) is undetectable.')
end

% Compute M
mtrue = p*c'/(rr+c*p*c');
if ~any(nn),
  % M = PC'/(RR+CPC')
  m = mtrue;
else
  % RE: for backward compatibility, M is set to A\K even though this is 
  %     not the right innovation gain when NN~=0. This ensures that A*M 
  %     coincides with the filter gain K as assumed by DESTIM and DREG.
  if rcond(a)<eps,
     error('Use KALMAN to compute the correct filter gains when A is singular')
  else
     % Set M=A\K for backward compatibility
     warning('Use KALMAN to compute the correct Kalman filter when G*(Q*H''+N)~=0.')
     m = a\k;
  end
end

% Compute Z=(I-MC)*P
z = (eye(Nx)-mtrue*c)*p;
z = (z+z')/2;
    

% end dlqew

