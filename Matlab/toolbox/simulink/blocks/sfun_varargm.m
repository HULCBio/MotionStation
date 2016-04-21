function [sys,x0,str,ts] = sfun_varargm(t,x,u,flag,varargin)
%SFUN_VARARGM Example vararg S-function 
%
%  This is an example S-function that demonstrates how to use the MATLAB vararg
%  facility. The S-function is a discrete counter running at a period of 1
%  second which produces one output per variable argument passed in.
%

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $

  switch flag,

    case 0,      % Initialization
      [sys,x0,str,ts]=mdlInitializeSizes(varargin{:});

    case 2,      % Update
      sys=mdlUpdate(t,x,u,varargin{:});

    case 3,      % Outputs
      sys=mdlOutputs(t,x,u);

    case 9,      % Terminate
      sys=[];

    otherwise
      error(['Unhandled flag = ',num2str(flag)]);
  end

%end sfun_varargm.m



% Function: mdlInitializeSizes ================================================
% Abstract: 
%     Discrete S-function running with period of 1 second. No input and
%     the number of outputs is equal to the number of variable arguments
%     passed in to the S-function.
%
function [sys,x0,str,ts]=mdlInitializeSizes(varargin)

  sizes = simsizes;

  nParams = nargin;

  if nParams <= 0
    error(['At least one parameter must be supplied']);
  end
  
  sizes.NumContStates  = 0;
  sizes.NumDiscStates  = nParams;
  sizes.NumOutputs     = nParams;
  sizes.NumInputs      = 0;
  sizes.DirFeedthrough = 1;
  sizes.NumSampleTimes = 1;

  sys = simsizes(sizes);

  x0  = zeros(1,nParams);

  str = [];

  ts  = [1 0];

%endfunction mdlInitializeSizes



% Function: mdlUpdate ==========================================================
% Abstract:
%     Increment each state by the amount specified in the vararg inputs.
%     
function sys=mdlUpdate(t,x,u,varargin)

  for i=1:nargin-3
    sys(i) = x(i) + varargin{i};
  end
  
%endfunction mdlUpdate



% Function: mdlOutputs =========================================================
% Abstract:
%     Output the current value of the counter(s) saved in the discrete state(s).
%
function sys=mdlOutputs(t,x,u)

  for i=1:length(x)
    sys(i) = x(i);
  end
  
%endfunction mdlOutputs

%[eof] sfun_varargm.m