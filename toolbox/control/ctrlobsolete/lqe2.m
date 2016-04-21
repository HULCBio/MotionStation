function [l,p] = lqe2(a,g,c,q,r,t)
%LQE2   Linear quadratic estimator design. For the continuous-time system:
%       .
%       x = Ax + Bu + Gw            {State equation}
%       z = Cx + Du + v             {Measurements}
%   with process noise and measurement noise covariances:
%       E{w} = E{v} = 0,  E{ww'} = Q,  E{vv'} = R, E{wv'} = 0
%
%   L = LQE2(A,G,C,Q,R) returns the gain matrix L such that the 
%   stationary Kalman filter:   .
%                                   x = Ax + Bu + L(z - Cx - Du)
%   produces an LQG optimal estimate of x. The estimator can be formed
%   with ESTIM.
%
%   [L,P] = LQE2(A,G,C,Q,R) returns the gain matrix L and the Riccati
%   equation solution P which is the estimate error covariance.
%
%   [L,P] = LQE2(A,G,C,Q,R,N) solves the estimator problem when the
%   process and sensor noise is correlated: E{wv'} = N.
%
%   LQE2 uses the SCHUR algorithm and is more numerically reliable 
%   than LQE, which uses eigenvector decomposition.
%
%   See also: LQEW, LQE, and ESTIM.

%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:11 $

error(nargchk(5,6,nargin));

% Calculate estimator gains using LQR2 and duality:
if nargin==5
  [k,s] = lqr2(a',c',g*q*g',r);
else
  [k,s] = lqr2(a',c',g*q*g',r,g*t);
end  
l=k';
p=s';

