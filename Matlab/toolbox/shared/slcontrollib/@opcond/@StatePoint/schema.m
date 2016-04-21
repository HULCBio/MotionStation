function schema
%SCHEMA  Defines properties for @StatePoint class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:27 $

%% Register class
c = schema.class(findpackage('opcond'), 'StatePoint');

%% Public attributes
%% Property storing the number of states in a block
p = schema.prop(c,'Nx','MATLAB array');

%% Property for the simulink block name
schema.prop(c, 'Block', 'string');                   

%% Property for the value of the states
p = schema.prop(c, 'x', 'MATLAB array');             
p.SetFunction = @LocalSetValue;

%% User storable description of the state object
schema.prop(c, 'Description', 'string');             % User description

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function to check for valid input arguements for the state x property
%% type.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NewValue = LocalSetValue(this,NewValue);

if (~isempty(this.Nx)) && ...
        (~(length(NewValue)==this.Nx) && ~(length(NewValue) == 0))
    error('Invalid entry. The block %s has %d state(s)',this.Block,this.NStates);
end