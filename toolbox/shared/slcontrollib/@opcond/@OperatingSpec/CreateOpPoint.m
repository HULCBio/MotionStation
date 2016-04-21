function newopcond = CreateOpPoint(opspec,varargin);
%% Method to get the state, input vectors in
%% their proper order for the model in its current state.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:14 $

%% Create a copy of the operating condition object
newopcond = opcond.OperatingPoint;
newopcond.Model = opspec.Model;
newopcond.T = opspec.T;

if nargin == 1
    constr_states = opspec.States;
    if isempty(constr_states)
        states = [];
    end
        
    for ct = length(opspec.States):-1:1
        %% Find the SimMech state references if needed.  This will be a subset
        %% of all the states in the SimMechanics machine.
        if isa(constr_states(ct),'opcond.StateSpecSimMech')
            ind = strmatch([constr_states(ct).SimMechBlock,':'],constr_states(ct).SimMechSystemStates);
            %% Create a new object
            states(ct) = opcond.StatePointSimMech;
            states(ct).SimMechMachineName = constr_states(ct).SimMechMachineName;
            states(ct).SimMechBlockStates = constr_states(ct).SimMechBlockStates;
            states(ct).SimMechSystemStates = constr_states(ct).SimMechSystemStates;
            states(ct).SimMechBlock        = constr_states(ct).SimMechBlock;
        else
            %% Create a new object
            states(ct) = opcond.StatePoint;
        end        
        %% Copy information
        states(ct).Block        = constr_states(ct).Block;
        states(ct).Nx           = constr_states(ct).Nx;
        states(ct).x            = constr_states(ct).x;
        states(ct).Description  = constr_states(ct).Description;
    end
    
    constr_inputs = opspec.Inputs;
    if isempty(constr_inputs)
        inputs = [];
    end
    for ct = length(opspec.Inputs):-1:1
        %% Create a new object
        inputs(ct) = opcond.InputPoint;
        %% Copy information
        inputs(ct).Block        = constr_inputs(ct).Block;
        inputs(ct).PortWidth           = constr_inputs(ct).PortWidth;
        inputs(ct).u            = constr_inputs(ct).u;
        inputs(ct).Description  = constr_inputs(ct).Description;
    end
    
elseif (nargin == 3)
    x = varargin{1};
    u = varargin{2};
    
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
            newstate = opcond.StatePointSimMech;
        else
            %% Create a new object
            newstate = opcond.StatePoint;
        end

        %% Copy information
        newstate.Block        = constr_states(ct).Block;
        newstate.Nx           = numel(x(ind));
        newstate.x            = x(ind);
        newstate.Description  = constr_states(ct).Description;
        states = [states; newstate];

        if isa(constr_states(ct),'opcond.StateSpecSimMech')
            newstate.SimMechMachineName = constr_states(ct).SimMechMachineName;
            newstate.SimMechBlockStates = constr_states(ct).SimMechBlockStates;
            newstate.SimMechSystemStates = constr_states(ct).SimMechSystemStates;
            newstate.SimMechBlock        = constr_states(ct).SimMechBlock;
        end
    end

    %% Extract the input levels
    constr_inputs = opspec.Inputs;
    inputs = [];
    offset = 0;
    for ct = 1:length(constr_inputs)
        %% Create a new object
        newinput = opcond.InputPoint;
        newinput.PortWidth   = constr_inputs(ct).PortWidth;
        newinput.u           = u(offset+1:offset+constr_inputs(ct).PortWidth);
        newinput.Block       = constr_inputs(ct).Block;
        newinput.Description = constr_inputs(ct).Description;
        inputs = [inputs;newinput];
        offset = offset + inputs(ct).PortWidth;
    end
end
newopcond.States = states;
newopcond.Inputs = inputs;

