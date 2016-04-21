function opcopy = copy(oppoint);
%COPY 
%
%  OPCOPY = COPY(OPPOINT) Creates a copy of an operating spec object.
%

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:05 $

%% Create a copy of the operating condition object
opcopy = opcond.OperatingPoint;
opcopy.Model = oppoint.Model;
opcopy.Time = oppoint.Time;

%% Extract the states from the operating condition object
constr_states = oppoint.States;
states = [];
for ct = 1:length(constr_states)
    %% Find the SimMech state references if needed.  This will be a subset
    %% of all the states in the SimMechanics machine.
    if isa(constr_states(ct),'opcond.StatePointSimMech')
        %% Create a new object
        newstate = opcond.StatePointSimMech;
    else
        %% Create a new object
        newstate = opcond.StatePoint;
    end
    
    %% Copy information
    newstate.Block       = constr_states(ct).Block;   
    newstate.Nx          = constr_states(ct).Nx;
    newstate.x           = constr_states(ct).x;
    newstate.Description = constr_states(ct).Description;
        
    if isa(constr_states(ct),'opcond.StatePointSimMech')
        newstate.SimMechMachineName = constr_states(ct).SimMechMachineName;
        newstate.SimMechBlockStates = constr_states(ct).SimMechBlockStates;
        newstate.SimMechSystemStates = constr_states(ct).SimMechSystemStates;
        newstate.SimMechBlock        = constr_states(ct).SimMechBlock;
    end

    %% Store the new state
    states = [states;newstate];
end

%% Extract the input levels
constr_inputs = oppoint.Inputs;
inputs = [];
for ct = 1:length(constr_inputs)
    %% Create a new object
    newinput = opcond.InputPoint;
    
    %% Copy Information
    newinput.PortWidth = constr_inputs(ct).PortWidth;
    newinput.u         = constr_inputs(ct).u;
    newinput.Block     = constr_inputs(ct).Block;
    newinput.Description = constr_inputs(ct).Description; 
    
    %% Store the new input
    inputs = [inputs;newinput];
end

opcopy.States = states;
opcopy.Inputs = inputs;
