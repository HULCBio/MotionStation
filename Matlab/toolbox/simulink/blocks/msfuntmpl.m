function msfuntmpl(block)
%MSFUNTMPL A template for an M-file S-function
%   The M-file S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl' with the name
%   of your S-function.  
%
%   It should be noted that the M-file S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more 
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%  
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  
  
%%
%% The setup method is used to setup the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.  
%%   
setup(block);
  
%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the S-function block's basic characteristics such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%% 
%%   C-Mex S-function counterpart: mdlInitializeSizes
%%
function setup(block)

  % Register number of ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;
  
  % Setup port properties to be inherited or dynamic
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;

  % Override input port properties
  block.InputPort(1).DatatypeID  = 0;
  block.InputPort(1).Complexity  = 0;
  
  % Override output port properties
  block.OutputPort(1).DatatypeID  = 0;
  block.OutputPort(1).Complexity  = 0;

  % Register parameters
  block.NumDialogPrms     = 3;
  block.DialogPrmsTunable = {'Tunable','Nontunable','SimOnlyTunable'};

  % Register sample times
  %  [0 offset]            : Continuous sample time
  %  [positive_num offset] : Discrete sample time
  %
  %  [-1, 0]               : Port-based sample time
  %  [-2, 0]               : Variable sample time
  block.SampleTimes = [0 0];
  
  %% -----------------------------------------------------------------
  %% Options
  %% -----------------------------------------------------------------
  % Specify if Accelerator should use TLC or call back into 
  % M-file
  block.SetAccelRunOnTLC(false);
  
  %% -----------------------------------------------------------------
  %% The M-file S-function uses an internal registry for all
  %% block methods. You should register all relevant methods
  %% (optional and required) as illustrated below. You may choose
  %% any suitable name for the methods and implement these methods
  %% as local functions within the same file.
  %% -----------------------------------------------------------------
    
  %% -----------------------------------------------------------------
  %% Register methods called during update diagram/compilation
  %% -----------------------------------------------------------------
  
  %% 
  %% CheckParameters:
  %%   Required         : No
  %%   Functionality    : Called in order to allow validation of
  %%                      block's dialog parameters. User is 
  %%                      responsible for calling this method
  %%                      explicitly at the start of the setup method
  %%   C-Mex counterpart: mdlCheckParameters
  %%
  block.RegBlockMethod('CheckParameters', @CheckPrms);

  %%
  %% SetInputPortSamplingMode:
  %%   Required         : No
  %%   Functionality    : Check and set input and output port 
  %%                      attributes specifying if port is operating 
  %%                      in sample-based or frame-based mode
  %%   C-Mex counterpart: mdlSetInputPortFrameData
  %%
  block.RegBlockMethod('SetInputPortSamplingMode', @SetInpPortFrameData);
  
  %%
  %% SetInputPortDimensions:
  %%   Required         : No
  %%   Functionality    : Check and set input and optionally output
  %%                      port dimensions
  %%   C-Mex counterpart: mdlSetInputPortDimensionInfo
  %%
  block.RegBlockMethod('SetInputPortDimensions', @SetInpPortDims);

  %%
  %% SetOutputPortDimensions:
  %%   Required         : No
  %%   Functionality    : Check and set output and optionally input
  %%                      port dimensions
  %%   C-Mex counterpart: mdlSetOutputPortDimensionInfo
  %%
  block.RegBlockMethod('SetOutputPortDimensions', @SetOutPortDims);
  
  %%
  %% SetInputPortDatatype:
  %%   Required         : No
  %%   Functionality    : Check and set input and optionally output
  %%                      port datatypes
  %%   C-Mex counterpart: mdlSetInputPortDataType
  %%
  block.RegBlockMethod('SetInputPortDataType', @SetInpPortDataType);
  
  %%
  %% SetOutputPortDatatype:
  %%   Required         : No
  %%   Functionality    : Check and set output and optionally input
  %%                      port datatypes
  %%   C-Mex counterpart: mdlSetOutputPortDataType
  %%
  block.RegBlockMethod('SetOutputPortDataType', @SetOutPortDataType);
  
  %%
  %% SetInputPortComplexSignal:
  %%   Required         : No
  %%   Functionality    : Check and set input and optionally output
  %%                      port complexity attributes
  %%   C-Mex counterpart: mdlSetInputPortComplexSignal
  %%
  block.RegBlockMethod('SetInputPortComplexSignal', @SetInpPortComplexSig);
  
  %%
  %% SetOutputPortComplexSignal:
  %%   Required         : No
  %%   Functionality    : Check and set output and optionally input
  %%                      port complexity attributes
  %%   C-Mex counterpart: mdlSetOutputPortComplexSignal
  %%
  block.RegBlockMethod('SetOutputPortComplexSignal', @SetOutPortComplexSig);
  
  %%
  %% PostPropagationSetup:
  %%   Required         : No
  %%   Functionality    : Setup work areas and state variables. Can
  %%                      also register run-time methods here
  %%   C-Mex counterpart: mdlSetWorkWidths
  %%
  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);

  %% -----------------------------------------------------------------
  %% Register methods called at run-time
  %% -----------------------------------------------------------------
  
  %% 
  %% ProcessParameters:
  %%   Required         : No
  %%   Functionality    : Called in order to allow update of run-time
  %%                      parameters
  %%   C-Mex counterpart: mdlProcessParameters
  %%  
  block.RegBlockMethod('ProcessParameters', @ProcessPrms);

  %% 
  %% InitializeConditions:
  %%   Required         : No
  %%   Functionality    : Called in order to initalize state and work
  %%                      area values
  %%   C-Mex counterpart: mdlInitializeConditions
  %% 
  block.RegBlockMethod('InitializeConditions', @InitializeConditions);
  
  %% 
  %% Start:
  %%   Required         : No
  %%   Functionality    : Called in order to initalize state and work
  %%                      area values
  %%   C-Mex counterpart: mdlStart
  %%
  block.RegBlockMethod('Start', @Start);

  %% 
  %% Outputs:
  %%   Required         : Yes
  %%   Functionality    : Called to generate block outputs in
  %%                      simulation step
  %%   C-Mex counterpart: mdlOutputs
  %%
  block.RegBlockMethod('Outputs', @Outputs);

  %% 
  %% Update:
  %%   Required         : No
  %%   Functionality    : Called to update discrete states
  %%                      during simulation step
  %%   C-Mex counterpart: mdlUpdate
  %%
  block.RegBlockMethod('Update', @Update);

  %% 
  %% Derivatives:
  %%   Required         : No
  %%   Functionality    : Called to update derivatives of
  %%                      continuous states during simulation step
  %%   C-Mex counterpart: mdlDerivatives
  %%
  block.RegBlockMethod('Derivatives', @Derivatives);
  
  %% 
  %% Projection:
  %%   Required         : No
  %%   Functionality    : Called to update projections during 
  %%                      simulation step
  %%   C-Mex counterpart: mdlProjections
  %%
  block.RegBlockMethod('Projection', @Projection);

  %% 
  %% ZeroCrossings:
  %%   Required         : No
  %%   Functionality    : For S-functions with continuous sample
  %%                      time, if input signals have discontinuities,
  %%                      this method is called to detect 
  %%                      discontinuities
  %%   C-Mex counterpart: mdlZeroCrossings
  %%
  block.RegBlockMethod('ZeroCrossings', @ZeroCrosssings);
  
  %% 
  %% ZeroCrossings:
  %%   Required         : No
  %%   Functionality    : Called when simulation goes to pause mode
  %%                      or continnues from pause mode
  %%   C-Mex counterpart: mdlSimStatusChange
  %%
  block.RegBlockMethod('SimStatusChange', @SimStatusChange);
  
  %% 
  %% ZeroCrossings:
  %%   Required         : Yes
  %%   Functionality    : Called at the end of simulation for cleanup
  %%   C-Mex counterpart: mdlTerminate
  %%
  block.RegBlockMethod('Terminate', @Terminate);

  %% -----------------------------------------------------------------
  %% Register methods called during code generation
  %% -----------------------------------------------------------------
  
  %%
  %% WriteRTW:
  %%   Required         : No
  %%   Functionality    : Write specific information to RTW file
  %%   C-Mex counterpart: mdlRTW
  %%
  block.RegBlockMethod('WriteRTW', @WriteRTW);
%endfunction

%% -------------------------------------------------------------------
%% The local functions below are provided for illustrative purposes
%% to show how you may implement the various block methods listed
%% above.
%% -------------------------------------------------------------------

function CheckPrms(block)
  
  a = block.DialogPrm(1).Data;
  if ~strcmp(class(a), 'double')
    error('Invalid parameter');
  end
  
%endfunction
  
function ProcessPrms(block)
%endfunction

function SetInpPortFrameData(block, idx, fd)
  
  block.InputPort(idx).SamplingMode = fd;
  block.OutputPort(1).SamplingMode  = fd;
  
%endfunction

function SetInpPortDims(block, idx, di)
  
  block.InputPort(idx).Dimensions = di;
  block.OutputPort(1).Dimensions  = di;

%endfunction

function SetOutPortDims(block, idx, di)
  
  block.OutputPort(idx).Dimensions = di;
  block.InputPort(1).Dimensions    = di;

%endfunction

function SetInpPortDataType(block, idx, dt)
  
  block.InputPort(idx).DataTypeID = dt;
  block.OutputPort(1).DataTypeID  = dt;

%endfunction
  
function SetOutPortDataType(block, idx, dt)

  block.OutputPort(idx).DataTypeID  = dt;
  block.InputPort(1).DataTypeID     = dt;

%endfunction  

function SetInpPortComplexSig(block, idx, c)
  
  block.InputPort(idx).Complexity = c;
  block.OutputPort(1).Complexity  = c;

%endfunction 
  
function SetOutPortComplexSig(block, idx, c)

  block.OutputPort(idx).Complexity = c;
  block.InputPort(1).Complexity    = c;

%endfunction 
    
function DoPostPropSetup(block)
  block.NumDworks = 1;
  
  block.Dwork(1).Name            = 'x1';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0; % double
  block.Dwork(1).Complexity      = 0; % real
  block.Dwork(1).UsedAsDiscState = 1;

%endfunction

function InitializeConditions(block)
%endfunction

function Start(block)
  
  block.Dwork(1).Data = 0;
  
%endfunction

function WriteRTW(block)
%endfunction

function Outputs(block)
  
  block.OutputPort(1).Data = block.Dwork(1).Data + block.InputPort(1).Data;
  
%endfunction

function Update(block)
  
  block.Dwork(1).Data = block.InputPort(1).Data;
  
%endfunction

function Derivatives(block)
%endfunction

function Projection(block)
%endfunction
  
function ZeroCrosssings(block)
%endfunction

function SimStatusChange(block, s)
  
  if s == 0
    disp('Pause has been called');
  elseif s == 1
    disp('Continue has been called');
  end
  
%endfunction
    
function Terminate(block)
%endfunction
 
