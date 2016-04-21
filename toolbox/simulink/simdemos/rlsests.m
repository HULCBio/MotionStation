function  [sys, x0, str, ts]  = rlsests(t,x,u,flag,nstates,lambda,dt)
%RLSESTS S-function to perform system identification.
%
%   This M-file is designed to be used in a Simulink S-function block.
%   It performs parameter estimation using the Recursive Least Squares
%   Parameter Estimation Algorithm with Exponential Data Weighting
%   
%   The input arguments are
%
%     nstates:        the number of states in the states vector
%     lambda:         the exponential data weighting factor
%     dt:             how often to sample points (secs)
%
%   The RLS estimator is defined by the following equations:
%
%   	                        1      P(k-2) * phi(k-1) * [y(k) - phi(k-1)'theta(k-1)]
%     theta[k] = theta[k-1] + ------ * -------------------------------------------------
%   	                      lambda         lambda + phi(k-1)' * P(k-2) * phi(k-1)
%
%   	         1       P(k-2) * phi(k-1) * phi(k-1)' * P(k-2)
%     P(k-1) = ------ * ----------------------------------------
%   	       lambda    lambda + phi(k-1)' * P(k-2) * phi(k-1)
%
%   where:
%
%     theta:		the parameter estimates
%     phi:		the state vector
%     P:		the covariance matrix
%     lambda:		the exponential data weighting factor
%
%   See also SFUNTMPL., "Adaptive Filtering, Prediction, and Control",
%   G. C. Goodwin & K. S. Sin.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.20 $
%   Rick Spada 6-17-92.

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(nstates,dt);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%

  case 2,
    sys=mdlUpdate(t,x,u,nstates,lambda);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u,nstates);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

%end rlsests.m

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(nstates,dt)

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = nstates+nstates*nstates;	% enough discrete states to hold the estimates
                                                % and the covariance matrix
sizes.NumOutputs     =  nstates;	        % nstate estimate outputs
sizes.NumInputs      = nstates+1;               % nstate+1 (regression vector + system output)
  					        % inputs
sizes.DirFeedthrough = 1;   % direct feedthrough
sizes.NumSampleTimes = 1;   % 1 sample time

sys = simsizes(sizes);

% initialize the covariance matrix and initial estimates
P = eye(nstates, nstates) * 1e6;
x0 = [ones(nstates,1)', P(:)']';
ts = [dt, 0];
str = [];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,nstates,lambda)

  theta = x(1:nstates);					% parameter estimates
  P = zeros(nstates,nstates);				% get covariance matrix
  P(:) = x(nstates+1:nstates+nstates*nstates);
  yk = u(nstates + 1);					% system output
  phi = u(1:nstates);					% state vector
  est_err = yk - phi' * theta;				% estimation error
  den = lambda + phi' * P * phi;			% lambda + phi' * P * phi
  theta_new = theta + P * phi * (est_err / den);	% new parameter estimates
  Pnew = (P - P * phi * phi' * P / den) / lambda;	% new covariance
  sys = [theta_new', Pnew(:)']';			% return them
 
% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u,nstates)

 sys = x(1:nstates);
 sys = sys(:); 

% end mdlOutputs

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate













