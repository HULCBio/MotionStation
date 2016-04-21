function sf_simtime_throttle(simTime)
% SF_simtime_throttle  Prevent simulation time from running ahead of real time.
%
% Assuming that the enclosing simulation model can run faster
% than real (wall clock) time, this function will stall the simulator
% until real time catches up.  Primarily useful for testing user interfaces.
% Of course, if the simulation is slower than real time, we can't help.

%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:53:06 $
%

persistent startTime;

if isempty(startTime)
	% remember when simulation started
	startTime = clock;
end

% compute real time since starting, and compare with simulation time
realTime = etime(clock,startTime);
delta = simTime - realTime;
while(delta > 0)
	% stall politely until we catch up
	% pause(max(delta/2,.001));
	realTime = etime(clock,startTime);
	delta = simTime - realTime;
end
