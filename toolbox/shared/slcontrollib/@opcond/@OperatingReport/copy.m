function opcopy = copy(opspec);
%COPY 
%
%  OPCOPY = COPY(OPREPORT) Creates a copy of an operating report object.
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:11 $

%% Create a copy of the operating condition object
opcopy = opcond.OperatingReport;
opcopy.Model = opspec.Model;
opcopy.Time = opspec.Time;

%% Extract the states from the operating condition object
constr_states = opspec.States;
states = [];
for ct = 1:length(constr_states)
    %% Find the SimMech state references if needed.  This will be a subset
    %% of all the states in the SimMechanics machine.
    if isa(constr_states(ct),'opcond.StateReportSimMech')
        %% Create a new object
        newstate = opcond.StateReportSimMech;
    else
        %% Create a new object
        newstate = opcond.StateReport;
    end
    
    %% Copy information
    newstate.Block       = constr_states(ct).Block;   
    newstate.Nx          = constr_states(ct).Nx;
    newstate.x           = constr_states(ct).x;
    newstate.dx           = constr_states(ct).dx;
    newstate.Known       = constr_states(ct).Known;
    newstate.SteadyState = constr_states(ct).SteadyState;
    newstate.Description = constr_states(ct).Description;
    newstate.Min         = constr_states(ct).Min;
    newstate.Max         = constr_states(ct).Max;
        
    if isa(constr_states(ct),'opcond.StateReportSimMech')
        newstate.SimMechMachineName = constr_states(ct).SimMechMachineName;
        newstate.SimMechBlockStates = constr_states(ct).SimMechBlockStates;
        newstate.SimMechSystemStates = constr_states(ct).SimMechSystemStates;
        newstate.SimMechBlock        = constr_states(ct).SimMechBlock;
    end

    %% Store the new state
    states = [states;newstate];
end

%% Extract the input levels
constr_inputs = opspec.Inputs;
inputs = [];
for ct = 1:length(constr_inputs)
    %% Create a new object
    newinput = opcond.InputReport;
    
    %% Copy Information
    newinput.PortWidth = constr_inputs(ct).PortWidth;
    newinput.u         = constr_inputs(ct).u;
    newinput.Known     = constr_inputs(ct).Known;
    newinput.Block     = constr_inputs(ct).Block;
    newinput.Description = constr_inputs(ct).Description; 
    newinput.Min         = constr_inputs(ct).Min; 
    newinput.Max         = constr_inputs(ct).Max; 
    
    %% Store the new input
    inputs = [inputs;newinput];
end

%% Extract the output levels
constr_outputs = opspec.Outputs;
outputs = [];
for ct = 1:length(constr_outputs)
    %% Create a new object
    newoutput = opcond.OutputReport;
    
    %% Copy information
    newoutput.PortWidth = opspec.Outputs(ct).PortWidth;
    newoutput.PortNumber = opspec.Outputs(ct).PortNumber;
    newoutput.y          = opspec.Outputs(ct).y;
    newoutput.yspec      = opspec.Outputs(ct).yspec;    
    newoutput.Known      = opspec.Outputs(ct).Known;    
    newoutput.Block      = opspec.Outputs(ct).Block;
    newoutput.Description = opspec.Outputs(ct).Description;
    newoutput.Min         = opspec.Outputs(ct).Min;
    newoutput.Max         = opspec.Outputs(ct).Max;
            
    %% Store the new output 
    outputs = [outputs;newoutput];
end

opcopy.States = states;
opcopy.Inputs = inputs;
opcopy.Outputs = outputs;