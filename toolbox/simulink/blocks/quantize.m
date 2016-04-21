function [sys,x0,str,ts] = quantize(t, x, u, flag, q)
%QUANTIZE An example M-File S-function vectorized quantizer
%   This M-file is an example of a quantizer S-function.  The input
%   is quantized into steps as specified by the quantization interval
%   parameter, q (a column vector).
%
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL, SLUPDATE.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $


switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0         
    [sys,x0,str,ts] = mdlInitializeSizes(q);

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Update and Terminate %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case {2,9}
    sys = []; % do nothing

  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3        
    sys = mdlOutputs(t,x,u,q); 
    
  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

% end quantize

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(q)

  warning(['The S-function vectorized quantizer block, ''',gcb,''' should ' ...
           'be replaced with the built-in vectorized quantizer block ' ...
           'which can be found in the Simulink block library.  Note, ' ...
           'slupdate can be used to automatically update your block ' ...
           'diagram.']);

if (length(q) == 1)
  numInputs = -1; % dynamically sized
else 
  numInputs = length(q);
end

numOutputs = numInputs;

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = numOutputs;
sizes.NumInputs      = numInputs;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = [];
str = [];
ts  = [-1 0];  % sample time: [period, offset]
               % period of -1 means sample time is inherited

% end mdlInitializeSizes

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys=mdlOutputs(t,x,u,q)

    signs = sign(u);
    signs(~signs) = ones(size(signs(~signs)));
    sys = q .* floor(abs(u./q) + 0.5) .* signs;

% end mdlOutputs