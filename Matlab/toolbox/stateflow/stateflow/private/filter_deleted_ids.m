function validIds = filter_deleted_ids(sfHandles),
%FILTER_DELETED_IDS( SFHANDLES )

%	Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:45 $

%
% Remove stale handles (i.e., bad handles AND handles of objects on the clipboard or deleted machines).
%
	validIds = [];
	if isempty(sfHandles), return; end;
   
	GET = sf('method','get');
    
	%
	% filter out obvious bad handles
	%
	isHandleV = logical(sf('ishandle', sfHandles));
	sfHandles = sfHandles(isHandleV);

	if isempty(sfHandles), return; end;

	%
	% filter out objects with invalid charts
	%
	stateISA = sf(GET, 'default', 'state.isa');
	junctionISA = sf(GET, 'default', 'junction.isa');
	transitionISA = sf(GET, 'default', 'transition.isa');
	machineISA = sf(GET, 'default', 'machine.isa');

	chartObjs = sf('find', sfHandles, '.isa', [stateISA; junctionISA; transitionISA]); % objects with a chart id field '.chart'
	actualMachines = sf('find', sfHandles, '.isa', machineISA); % actual machines objects.
	machineObjs = vset(sfHandles, '-', chartObjs); % objects with a machine id field '.machine'
	machineObjs = vset(machineObjs, '-', actualMachines);

	if ~isempty(chartObjs),
		charts = [];
		for obj=chartObjs(:)',
		  charts(end+1) = sf(GET, obj, '.chart');
		end
		hasValidChart = logical(sf('ishandle', charts));
  
		if ~isempty(hasValidChart), chartObjs = chartObjs(hasValidChart); end;
	end;
   
	%
	% filter out objects whose machine is invalid 
	%
	machines = [];
	for obj=machineObjs(:)',
		machines(end+1) = sf(GET, obj, '.machine');
	end
	
	hasValidMachine = logical(sf('ishandle', machines));

	if ~isempty(hasValidMachine), 
		machineObjs = machineObjs(hasValidMachine); 
		machines = machines(hasValidMachine);
	end;

	%
	% filter out objects who's machine is the clipboard or who's machine is deleted.
	%
	if ~isempty(machines),
		clipboardId = get_clipboard_machine;

		isClipboard = machines == clipboardId;
		isDeleted = sf(GET, machines, '.deleted');  

		m = ~(isClipboard(:) | isDeleted(:));
		machineObjs = machineObjs(m);
	end;

	% 
	% filter out bad machines
	%
	if ~isempty(actualMachines),
		clipboardId = get_clipboard_machine;

		isClipboard = actualMachines == clipboardId;
		isDeleted = sf(GET, actualMachines, '.deleted');  

		m = ~(isClipboard(:) | isDeleted(:));
		actualMachines = actualMachines(m);
	end;

	validIds = [chartObjs(:)' machineObjs(:)' actualMachines(:)'];



