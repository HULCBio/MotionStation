function  [sys,x0,str,ts] = sfuncont(t,x,u,flag)
%SFUNCONT An example M-File S-function for continuous systems.
%   This M-file is designed to be used as a template for other
%   S-functions. Right now it acts as an integrator. This template
%   is an example of a continuous system with no discrete components.
%
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

switch flag
  case 0                                                % Initialization
    sys = [1,      % number of continuous states
           0,      % number of discrete states
           1,      % number of outputs
           1,      % number of inputs
           0,      % reserved must be zero
           1,      % direct feedthrough flag
           1];     % number of sample times
    x0  = 0;
    str = [];
    ts  = [0 0];   % sample time: [period, offset]

  case 1                                                % Derivatives
    sys = u;

  case 2                                                % Discrete state update
    sys = []; % do nothing

  case 3
    sys = x;
  
  case 9                                                % Terminate
    sys = []; % do nothing

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end
