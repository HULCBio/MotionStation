function [sys,x0,str,ts]=limintm(t,x,u,flag,lb,ub,xi)
%LIMINTM Limited integrator implementation.
%   Example M-file S-function implementing a continuous limited integrator
%   where the output is bounded by lower bound (LB) and upper bound (UB)
%   with initial conditions (XI).
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0         
    [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1
    sys = mdlDerivatives(t,x,u,lb,ub);

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Update and Terminate %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case {2,9}
    sys = []; % do nothing

  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3
    sys = mdlOutputs(t,x,u); 

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

% end limintm

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi)

sizes = simsizes;
sizes.NumContStates  = 1;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = xi;
ts  = [0 0];   % sample time: [period, offset]

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Compute derivatives for continuous states.
%=============================================================================
%
function sys = mdlDerivatives(t,x,u,lb,ub)

if (x <= lb & u < 0)  | (x>= ub & u>0 )
  sys = 0;
else
  sys = u;
end

% end mdlDerivatives

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)

sys = x;

% end mdlOutputs