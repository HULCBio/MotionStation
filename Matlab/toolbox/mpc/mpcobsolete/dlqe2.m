function [k,m,p]=dlqe2(phi,gamw,c,q,r)
%DLQE2	Get solution of Kalman Filter equations by iteration.
%        k=dlqe2(phi,gamw,c,q,r)
%        [k,m,p]=dlqe2(phi,gamw,c,q,r)
% Usage is identical to the DLQE routine in the Control Toolbox,
% but DLQE2 can handle systems in which phi is singular, e.g.,
% systems with pure time delay.
%
% Inputs:
%  phi   is phi of a plant model in the MPC format.
%  gamw  is gamma for unmeasured disturbances (w)
%  c     is c of a plant model in the MPC format.
%  q     is the unmeasured disturbance noise covariance matrix
%  r     is the measurement noise covariance matrix
%
% Outputs:
%  k  Optimal steady-state gain for discrete Kalman filter.
%  m  Expected covariance of the errors in state estimates
%     before measurement update.
%  p  Expected covariance of the errors in state estimates
%     after measurement update.
%
% See also SMPCEST.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%
%
%	For the discrete-time system:
%
%	x[n+1] = phi*x[n] + gam*u[n] + gamw*w[n]	    {State equation}
%	y[n]   =   c*x[n] +   d*u[n] +      z[n]	    {Measurements}
%
%	with process noise and measurement noise covariances:
%
%	E{w} = E{z} = 0,  E{ww'} = q,  E{zz'} = r
%
%	the function dlqe2(phi,gamw,c,q,r) returns the gain matrix k
%	such that the discrete, stationary Kalman filter:
%                 _            *
%	State update: x[n+1] = phi*x[n] + gam*u[n]
%                       *      _                  _
%	Observation update: x[n] = x[n] + k*(z[n] - c*x[n] - d*u[n])
%
%	produces an LQG optimal estimate of x.
%	[K,M,P] = dlqe2(phi,gamw,c,q,r) returns the gain matrix K, the Riccati
%	equation solution M, and the estimate error covariance after the
%	measurment update:
%		       *    *
%		P = E{[x-x][x-x]'}
%
% --------version--------------------
%
%  Written 4/17/91 by N. L. Ricker, U. of Washington.

% Error checking.
if (nargin==0)
   disp('usage: [k,m,p]=dlqe2(phi,gamw,c,q,r)');
   return;
end;
if nargin ~= 5
   error('Incorrect number of input arguments')
end

[n,n]=size(phi);
[nqr,nqc]=size(q);
[ngr,ngc]=size(gamw);
if nqr ~= nqc
    error('q must be square')
elseif ngr ~= n
    error('gamw and phi must have equal # of rows')
elseif ngc ~= nqr
    error('Number of columns in gamw must equal number of rows in q')
end

[ny,ncol]=size(c);
[nrr,nrc]=size(r);
if ncol ~= n
   error('phi and c must have equal # of columns')
end
if nrr ~= nrc
   error('r must be a square matrix')
end
if ny ~= nrr
   error('c and r must have equal number of rows')
end

m=dareiter(phi',c',r,gamw*q*gamw');

k=m*c'*inv(r+c*m*c');

p=m-k*c*m;
