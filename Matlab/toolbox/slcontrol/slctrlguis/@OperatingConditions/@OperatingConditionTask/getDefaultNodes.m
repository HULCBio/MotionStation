function nodes = getDefaultNodes(this)
%% GETDEFAULTNODES  Return list of required component names.

%% Author(s): John Glass
%% Revised: 
%% Copyright 1986-2003 The MathWorks, Inc.

%% Define list of required components for objects of this class
oppoint = CreateOpPoint(this.OpSpecData);
nodes = OperatingConditions.OperConditionValuePanel(oppoint,'Default Operating Point');  