function sftiffprintall
%SFTIFFPRINTALL

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:00:21 $

	% Choice of print colors
	stateColor = [0 1 1];      % Cyan
	junctionColor = [1 0 1];   % Magenta
	transitionColor = [1 1 0]; % Yellow
	chartColor = [0 0 0];      % Black

	% List of all Statecharts
	charts = sf('get','all','chart.id');

	for id = charts(:).',
		sf('set',id...
			,'.stateColor',stateColor...
			,'.junctionColor',junctionColor...
			,'.transitionColor',transitionColor...
			,'.chartColor',chartColor...
		);
		sfprint(id,'tif');
	end
