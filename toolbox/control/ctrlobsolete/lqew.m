function [l,p,e] = lqew(a,g,c,h,q,r,nn)
%LQEW  Kalman estimator for continuous-time systems with process 
%   noise feedthrough.
%
%   Given the system
%       .
%       x = Ax + Bu + Gw        {State equation}
%       y = Cx + Du + Hw + v    {Measurements}
%
%   with unbiased process noise w and measurement noise v with 
%   covariances
%
%       E{ww'} = Q,    E{vv'} = R,    E{wv'} = N ,
%
%   [L,P,E] = LQEW(A,G,C,H,Q,R,N)  calculates the observer gain 
%   matrix L such that the stationary Kalman filter
%       .
%       x_e  = Ax_e + Bu + L(y - Cx_e - Du)
%
%   produces an optimal state estimate x_e of x using the sensor
%   measurements y.  The resulting Kalman estimator can be formed
%   with ESTIM.
%
%   The noise cross-correlation N is set to zero when omitted.  
%   Also returned are the solution P of the associated Riccati 
%   equation and the estimator poles E = EIG(A-L*C).
%
%   See also  LQE, DLQEW, LQGREG, CARE, and ESTIM.

%   Clay M. Thompson  7-23-90
%   Revised  P. Gahinet,  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:33:05 $

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

% Derive reduced matrices for CARE.  First derive the equivalent 
% Q,N,R for the auxiliary measurement noise vv = Hw+v
hn = h * nn;
nn = q * h' + nn;
rr = r  + hn + hn' + h * q * h';
% Then incorporate G
qq = g * q * g';
nn = g * nn;

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


% Call CARE
[p,e,k,report] = care(a',c',qq,rr,nn,'report');
l = k';

% Handle failure
if report==-1,
   error(sprintf(...
    ['(C,A) or (A-G*NN/RR*C,G*(Q-NN/RR*NN'')*G'') has non minimal modes\n' ...
     'near jw axis where  NN = Q*H''+N  and  RR = R+H*N+N''*H''+H*Q*H''.']))
elseif report==-2,
   error('(C,A) is undetectable.')
end

% end lqew


