function [l,p,e] = lqe(a,g,c,q,r,nn)
%LQE  Kalman estimator design for continuous-time systems.
%
%   Given the system
%       .
%       x = Ax + Bu + Gw            {State equation}
%       y = Cx + Du + v             {Measurements}
%
%   with unbiased process noise w and measurement noise v with 
%   covariances
%
%       E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
%   [L,P,E] = LQE(A,G,C,Q,R,N)  returns the observer gain matrix L
%   such that the stationary Kalman filter
%       .
%       x_e = Ax_e + Bu + L(y - Cx_e - Du)
%
%   produces an optimal state estimate x_e of x using the sensor
%   measurements y.  The resulting Kalman estimator can be formed
%   with ESTIM.
%
%   The noise cross-correlation N is set to zero when omitted.  
%   Also returned are the solution P of the associated Riccati 
%   equation
%                            -1
%       AP + PA' - (PC'+G*N)R  (CP+N'*G') + G*Q*G' = 0 
%
%   and the estimator poles E = EIG(A-L*C).
%
%   See also  LQEW, DLQE, LQGREG, CARE, and ESTIM.

%   J.N. Little 4-21-85
%   Revised Clay M. Thompson  7-16-90, P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:33:14 $

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

% Derive reduced matrices for CARE
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


% Call CARE
[p,e,k,report] = care(a',c',qg,r,ng,'report');
l = k';

% Handle failure
if report==-1,
   error(...
   '(A-G*N/R*C,G*(Q-N/R*N'')*G'') or (C,A) has non minimal modes near jw axis.')
elseif report==-2,
   error('(C,A) is undetectable.')
end

% end lqe


