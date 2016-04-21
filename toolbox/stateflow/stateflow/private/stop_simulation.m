function stop_simulation(machine)
	%%% If the debugger gui is up then we must let the Debugger stop simulation

% Copyright 2003 The MathWorks, Inc.

	hDebugger = sf('get',machine,'machine.debug.dialog');

	if(hDebugger & ishandle(hDebugger) & strcmp( get(hDebugger,'tag'), 'SF_DEBUGGER' ))
		sfdebug('gui','stop_debugging',machine);
	else
		sfsim('stop', machine);
	end
