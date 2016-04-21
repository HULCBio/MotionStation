function opreport = CreateOpReport(opspec,x,u,y,dx);
%CREATEOPREPORT Method create the operating condition report from trim analysis
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:15 $

%% Create a copy of the operating condition object
opreport = opcond.OperatingReport;
opreport.Model = opspec.Model;
opreport.Time = opspec.Time;

%% Get the states of the system
[sizes, x0, x_str, pp, qq] = feval(opspec.Model,[],[],[],'sizes'); 
   
%% Extract the states from the operating condition object
constr_states = opspec.States;
states = [];
for ct = 1:length(constr_states)
    %% Find the state indecies
    ind = find(strcmp(constr_states(ct).Block,x_str));
    %% Find the SimMech state references if needed.  This will be a subset
    %% of all the states in the SimMechanics machine.
    if isa(constr_states(ct),'opcond.StateSpecSimMech')
        ind = ind(strmatch([constr_states(ct).SimMechBlock,':'],constr_states(ct).SimMechSystemStates));
        %% Create a new object
        newstate = opcond.StateReportSimMech;
    else
        %% Create a new object
        newstate = opcond.StateReport;
    end
    
    %% Copy information
    newstate.Block       = constr_states(ct).Block;   
    newstate.Nx          = numel(x(ind));
    newstate.x           = x(ind);
    newstate.Known       = constr_states(ct).Known;
    newstate.SteadyState = constr_states(ct).SteadyState;
    newstate.Description = constr_states(ct).Description;
    newstate.Min         = constr_states(ct).Min;
    newstate.Max         = constr_states(ct).Max;
    newstate.dx          = dx(ind);
        
    if isa(constr_states(ct),'opcond.StateSpecSimMech')
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
offset = 0;
for ct = 1:length(constr_inputs)
    %% Create a new object
    newinput = opcond.InputReport;
    
    %% Copy Information
    newinput.PortWidth = constr_inputs(ct).PortWidth;
    newinput.u         = u(offset+1:offset+opspec.Inputs(ct).PortWidth);
    newinput.Known     = constr_inputs(ct).Known;
    newinput.Block     = constr_inputs(ct).Block;
    newinput.Description = constr_inputs(ct).Description; 
    newinput.Min         = constr_inputs(ct).Min; 
    newinput.Max         = constr_inputs(ct).Max; 
    
    %% Store the new input
    inputs = [inputs;newinput];
    
    %% Increment the offset
    offset = offset + inputs(ct).PortWidth;
end

%% Extract the output levels
constr_outputs = opspec.Outputs;
outputs = [];
offset = 0;
for ct = 1:length(constr_outputs)
    %% Create a new object
    newoutput = opcond.OutputReport;
    
    %% Copy information
    newoutput.PortWidth = opspec.Outputs(ct).PortWidth;
    newoutput.PortNumber = opspec.Outputs(ct).PortNumber;
    newoutput.y          = y(offset+1:offset+opspec.Outputs(ct).PortWidth);
    newoutput.yspec      = opspec.Outputs(ct).y;
    newoutput.Known      = opspec.Outputs(ct).Known;    
    newoutput.Block      = opspec.Outputs(ct).Block;
    newoutput.Description = opspec.Outputs(ct).Description;
    newoutput.Min         = opspec.Outputs(ct).Min;
    newoutput.Max         = opspec.Outputs(ct).Max;
            
    %% Store the new output 
    outputs = [outputs;newoutput];

    %% Increment the offset
    offset = offset + outputs(ct).PortWidth;
end

opreport.States = states;
opreport.Inputs = inputs;
opreport.Outputs = outputs;