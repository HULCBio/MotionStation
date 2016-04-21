function machine = actual_machine_referred_by(chart)
%
% Find the actual machine referrenced by the activeInstance of the
% input chart.  
%
% This corrrectly returns the machineId of the parent model from which
% this chart's simulink block or library instance has been opened.
%

%	Copyright 1995-2003 The MathWorks, Inc.
%	$Revision: 1.7.2.2 $  $Date: 2004/04/15 00:55:58 $

chartMachine = sf('get', chart, '.machine');
activeInstance = sf('get', chart, '.activeInstance');

if (isequal(activeInstance, 0) || ~ishandle(activeInstance)),
    machine = chartMachine;
else
    modelH = bdroot(activeInstance);
    machine = sf('find','all','machine.simulinkModel', modelH);
    
    if(isempty(machine)), machine = chartMachine;	end;
end;
