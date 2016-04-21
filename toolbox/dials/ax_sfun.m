function [sys,x0,str,ts] = ax_sfun(t,x,u,flag, ...
    hActx,inputprops,outputprops,inblock,update,connect,dialOut)
%AX_SFUN S-Function for the ActiveX block.
%
%   Enables the Simulink ActiveX block to communicate with ActiveX controls.
%
%   Windows platforms:
%     Implemented by the ax_sfun.dll C-mex, S-function in conjunction with
%     ax_sfun_m.m.  
%   
%   Non-windows platforms:
%     When used on non-Windows platforms, AX_SFUN provides default behavior
%     for the ActiveX block. The default behavior is based on the Connections
%     setting made in the property dialog of the ActiveX block, and is
%     defined by the following guidelines:
%
%     Connections    
%     Setting:      Block Behavior:
%     -----------   ------------------------------------------------------
%     input         Acts as a ground block. Accepts data of any signal
%                    width, but does not act on it.
%     output        Acts as a constant block. If the Input Property parameter
%                    resolves to a valid double array it will be used as the 
%                    output value. Otherwise, the value 1 will be used.
%     both          Acts as direct feedthrough block (i.e. Mux of 1 to 1).
%                    Passes input data directly to the output without
%                    modification. If the width of the input signal
%                    does not match the width of the output signal,
%                    an error will be thrown.
%     neither       Does nothing.
%
%     Examples:
%       1)  INPUT block:
%           The Generic Angular Gauge has a Connections property of 'input'. 
%           It will therefore have a single input port on the block.
%           Any signal may be connected to this input port. The block will
%           do nothing during the Simulation.
%       2)  OUTPUT block:
%           The Generic Knob has a Connections property of 'output'.  The
%           the Output Property for the Generic Knob is KnobValue, so
%           if KnobValue is defined in the workspace as 6, then the value
%           6 will be assigned to the output signal during the simulation.
%           If KnobValue is defined in the workspace as [2 4 6], then the 
%           wide vector [2 4 6] is the output signal during the simulation.
%           If KnobValue does not exist in the workspace, or is empty, the 
%           value 1 will be assigned to the output signal during the simulation.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2003/12/15 15:53:10 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(connect,inputprops,outputprops,dialOut);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=[];

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u,connect,inputprops,outputprops,dialOut);

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case { 1, 4 }
    sys=[];

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

% end 


%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(connect,inputprops,outputprops,dialOut)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0; % assume none
sizes.NumInputs      = 0; % assume none
sizes.DirFeedthrough = 0; % assume not
sizes.NumSampleTimes = 1; % at least one sample time is needed

% Modify based on parameters
if( connect == 3 | connect == 1)
    % BOTH or INPUT
    sizes.NumInputs      = -1; % dynamically sized
    if ~isempty(inputprops)
        sizes.NumInputs = length(inputprops); % Use what we have
    end
end
 
if( connect == 3 | connect == 2)
    % BOTH or OUTPUT
    sizes.NumOutputs = -1; % dynamically sized
    sizes.NumOutputs = length(dialOut); % Use what we have

end

if( connect == 3 )
    % BOTH
    sizes.DirFeedthrough = 1; % OK, we may use it
    if( sizes.NumOutputs > 0 & sizes.NumInputs > 0 )
        if( sizes.NumOutputs ~= sizes.NumInputs )
           error('Numer of inputs does not match number of outputs.')
       end
   end   
end
  

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
if (strcmp(connect, 'both') | strcmp(connect, 'output'))
    % need continuous sample times
    ts = [0 0];
else
    % no need to sample at all!
    ts = [inf 0];
end

% end mdlInitializeSizes


%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u,connect,inputprops,outputprops,dialOut)

sys = [];

switch( connect )
    case  2,
        % Output (source block). Just use the dialOut parameter.
	sys = dialOut;
        
    case 3, 
        % Throughput
        sys = u;
        
end

    
%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate






