function opnew = addoutputspec(op,block,portnumber);
% ADDOUTPUTSPEC Add output specification to operating point specification
%
%   OPNEW=ADDOUTPUTSPEC(OP,'block',PORTNUMBER) adds an output specification 
%   for a Simulink model to an existing operating point specification, OP, 
%   created with OPERSPEC. The signal being constrained by the output 
%   specification is indicated by the name of the block, 'block', and the 
%   port number, PORTNUMBER, that it originates from. You can edit the 
%   output specification within the new operating point specification 
%   object, OPNEW, to include the actual constraints or specifications for 
%   the signal. Use the new operating point specification object with the 
%   function FIDNOP to find operating points for the model. 
%
%   This function will automatically compile the Simulink model, given in 
%   the property Model of OP, to find the block's output portwidth.
%
%   See also OPERSPEC.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:19 $

%% Create the new output constraint object
newoutput = opcond.OutputSpec;

%% Compile the model to get the compiled portwidths
feval(op.Model,[],[],[],'lincompile');

%% Get the port handles
Ports = get_param(block,'PortHandles');
%% Get the port width
PortWidth = get_param(Ports.Outport(portnumber),'CompiledPortWidth');

%% Terminate the compilation
feval(op.Model,[],[],[],'term')

%% Set the properties
newoutput.Block = block;
newoutput.PortNumber = portnumber;
newoutput.PortWidth = PortWidth;
newoutput.Known = 0;
newoutput.y = zeros(PortWidth,1);
newoutput.Min = -inf*ones(PortWidth,1);
newoutput.Max = inf*ones(PortWidth,1);

%% Create a copy of the operating condition spec
opnew = copy(op);

%% Store the output in the OperatingSpec object
opnew.Outputs = [opnew.Outputs;newoutput];