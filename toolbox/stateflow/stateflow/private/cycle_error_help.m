function cycle_error_help
%CYCLE_ERROR_HELP
%   Opens up Stateflow model cycle_error_fix.mdl
%   which illustrates a couple of commonly found
%   cycle(loop) flow-graph constructs which are 
%   not allowed by Stateflow 3.0 and shows how to
%   fix them.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:56:34 $
modelName = 'sf_cycle_error_fix';
open_system(modelName);
machineId = sf('find','all','machine.name',modelName);
chart = sf('get',machineId,'machine.charts');
sf('Open',chart);
