function [sys,x0,str,ts]  = vdpm(t,x,u,flag)
%VDPM Example M-File S-function implementing the Van der Pol equation
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
   [sys,x0,str,ts] = mdlInitializeSizes;
   
   %%%%%%%%%%%%%%%
   % Derivatives %
   %%%%%%%%%%%%%%%
   
case 1,                
   sys = mdlDerivatives(t,x,u);
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Update, Output, and Terminate %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
case {2, 3, 9},                                                
    sys = []; % do nothing
    
 otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

%
%===================================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%===================================================================================
%
function [sys, x0,str,ts] = mdlInitializeSizes

sizes = simsizes;
sizes.NumContStates  = 2;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = [.25 .25]; 
str = [];
ts  = [0 0];  % continuous sample time: [period, offset]

% end mdlInitializeSizes

%
%===================================================================================
% mdlDerivatives
%
%===================================================================================
%
function sys = mdlDerivatives(t,x,u)

sys(1) = x(1) .* (1 - x(2).^2) - x(2);
sys(2) = x(1);

% end mdlInitializeSizes
