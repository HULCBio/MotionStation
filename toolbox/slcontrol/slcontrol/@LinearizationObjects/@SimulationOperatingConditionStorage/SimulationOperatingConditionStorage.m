function hout = SimulationOperatingConditionStorage
%% SIMULATIONOPEARINGCONDITONSTORAGE Constructor to create a singleton handle to the storage
%% class

%  Author(s): John Glass
%  Copyright 1986-2002 The MathWorks, Inc.

persistent this

if isempty(this)
    this = LinearizationObjects.SimulationOperatingConditionStorage;
end

hout = this;