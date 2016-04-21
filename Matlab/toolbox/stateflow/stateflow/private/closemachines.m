function varargout = closemachines(varargin)
%CLOSEMACHINES closes all finite-state-machines.

%	E. Mehran Mestchian
%	Copyright 1995-2003 The MathWorks, Inc.
%  $Revision: 1.14.2.2 $  $Date: 2004/04/15 00:56:18 $

if(nargin==0)
	byForce = 0;
else
	byForce = 1;
end
machines = sf('find', 'all', '~machine.simulinkModel', 0);
simModels = sf('get', machines, 'machine.simulinkModel');
openModels = find_system(0,'SearchDepth',1,'type','block_diagram');
simModels = vset(simModels,'*',openModels);
cancel = 0;

for sys=simModels(:)',
	lasterr('');
	try,
		if(byForce)
			bdclose(sys);
		else
			close_system(sys);
		end
	catch,
		disp(lasterr);
		cancel = 1;
		if nargout>0
			varargout{1} = cancel;
		end
	end		
end;


if nargout>0
	varargout{1} = cancel;
end




