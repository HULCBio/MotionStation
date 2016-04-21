function schema
%SCHEMA  Defines properties for @StateSpecSimMech class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:37 $

%% Register class
c = schema.class(findpackage('opcond'), 'StateSpecSimMech');

%% Public attributes
%% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

%% Property for the SimMechanics Information
schema.prop(c, 'SimMechSystemStates', 'MATLAB array');
schema.prop(c, 'SimMechMachineName', 'MATLAB array');
schema.prop(c, 'SimMechBlockStates', 'MATLAB array');
schema.prop(c, 'SimMechBlock', 'MATLAB array');

%% Property for the value of the states
p = schema.prop(c, 'x', 'MATLAB array');             
p.SetFunction = @LocalSetValue;

%% Property storing the number of states in a block
schema.prop(c,'Nx','MATLAB array');

%% Property for the known state flag
schema.prop(c, 'Known', 'MATLAB array');

%% On/Off property for the steady state flag
schema.prop(c, 'SteadyState', 'MATLAB array');    

%% Property for the lower bounds for a set of states for a block during
%% trim
p = schema.prop(c, 'Min', 'MATLAB array');        % Lower Bound
p.SetFunction = @LocalSetValue;

%% Property for the upper bounds for a set of states for a block during
%% trim
p = schema.prop(c, 'Max', 'MATLAB array');        % Upper Bound
p.SetFunction = @LocalSetValue;

%% User storable description of the state object
schema.prop(c, 'Description', 'string');             % User description

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements for the number of states.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalSetValue(this,NewValue);

if (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(length(NewValue) == 0))
    error('Invalid entry. The block %s has %d state(s)',this.Block,this.Nx);
end