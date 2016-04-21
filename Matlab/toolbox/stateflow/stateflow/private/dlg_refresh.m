function dlg_refresh( objectIds, property )
% DLG_REFRESH( OBJECTIDS, PROPERTY)

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:06 $

[MACHINE, TARGET, CHART, STATE, TRANSITION, JUNCTION, DATA, EVENT] = sf('get','default'...
	,'machine.isa'...
	,'target.isa'...
	,'chart.isa'...
	,'state.isa'...
	,'transition.isa'...
	,'junction.isa'...
	,'data.isa'...
	,'event.isa');

if nargin>1
   for id = objectIds(:)'
   	if sf('ishandle',id)
   		switch sf('get',id,'.isa')
   		case MACHINE
   			machinedlg('refresh',id,property);
   		case TARGET
   			targetdlg('refresh',id,property);
   		case CHART
   			chartdlg('refresh',id,property);
   		case STATE
   			statedlg('refresh',id,property);
   		case TRANSITION
   			transdlg('refresh',id,property);
   		case JUNCTION
   			junctdlg('refresh',id,property);
   		case DATA
   			datadlg('refresh',id,property);
   		case EVENT
   			eventdlg('refresh',id,property);
   		end
   	else
   		warning('Ignoring invalid object ID.');
   	end
   end
else
   for id = objectIds(:)'
   	if sf('ishandle',id)
   		switch sf('get',id,'.isa')
   		case MACHINE
   			machinedlg('refresh',id);
   		case TARGET
   			targetdlg('refresh',id);
   		case CHART
   			chartdlg('refresh',id);
   		case STATE
   			statedlg('refresh',id);
   		case TRANSITION
   			transdlg('refresh',id);
   		case JUNCTION
   			junctdlg('refresh',id);
   		case DATA
   			datadlg('refresh',id);
   		case EVENT
   			eventdlg('refresh',id);
   		end
   	else
   		warning('Ignoring invalid object ID.');
   	end
   end
end
   

