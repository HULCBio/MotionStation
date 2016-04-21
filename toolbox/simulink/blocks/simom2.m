function [sys,x0,str,ts]=simom2(t,x,u,flag,A,B,C,D)
%SIMOM2 Example state-space M-file S-function with external A,B,C,D matrices
%   This S-function implements a system described by state-space equations:
%   
%           dx/dt = A*x + B*u
%               y = C*x + D*u
%   
%   where x is the state vector, u is vector of inputs, and y is the vector
%   of outputs. The matrices, A,B,C,D are provided externally as parameters
%   to this M-file.
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.20 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,                                                
    [sys,x0,str,ts] = mdlInitializeSizes(A,B,C,D);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1                                                
    sys = mdlDerivatives(t,x,u,A,B,C,D);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3                                                
    sys = mdlOutputs(t,x,u,A,B,C,D);
  
  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%

  case 9                                         
    sys = []; % do nothing

end

%end simom2

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(A,B,C,D)

sizes = simsizes;

sizes.NumContStates  = size(A,1);
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = size(D,1);
sizes.NumInputs      = size(D,2);
sizes.DirFeedthrough = any(any(D~=0));
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
x0  = ones(size(A,1),1); 
str = [];
ts  = [0 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys = mdlDerivatives(t,x,u,A,B,C,D)

sys = A*x + B*u;

% end mdlDerivatives

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u,A,B,C,D)

sys = C*x + D*u;

% end mdlOutputs

