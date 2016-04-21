function modelH = machine2model(machineID)
% MACHINE2MODEL returns the Simulink model handle for a Stateflow machine ID

%   J. Breslau
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:58:40 $

    modelH = sf('get', machineID, 'machine.simulinkModel');