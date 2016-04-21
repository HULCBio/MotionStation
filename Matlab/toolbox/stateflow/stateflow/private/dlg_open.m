function dlg_open( objectIds )
%DLG_OPEN( OBJECTIDS )  opens the property dialog for the given objects

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:04 $

if isempty(objectIds), return; end;

[MACHINE, TARGET, CHART, STATE, TRANSITION, JUNCTION, DATA, EVENT] = sf('get','default'...
	,'machine.isa'...
	,'target.isa'...
	,'chart.isa'...
	,'state.isa'...
	,'transition.isa'...
	,'junction.isa'...
	,'data.isa'...
	,'event.isa');

objectIds = filter_deleted_ids(objectIds);

if isempty(objectIds), 
	warndlg({'Object''s dialog not available. ', '(object has been deleted or has an invalid id)'});
end;

for id = objectIds(:)'
	if sf('ishandle',id)
		switch sf('get',id,'.isa')
		case MACHINE
			machinedlg('construct',id);
		case TARGET
			targetdlg('construct',id);
		case CHART
			chartdlg('construct',id);
		case STATE
			statedlg('construct',id);
		case TRANSITION
			transdlg('construct',id);
		case JUNCTION
			junctdlg('construct',id);
		case DATA
			datadlg('construct',id);
		case EVENT
			eventdlg('construct',id);
		end
	else
		warning('Ignoring invalid object ID.');
	end
end

