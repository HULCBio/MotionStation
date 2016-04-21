function dlg_goto_parent( objectId )
%DLG_GOTO_PARENT( OBJECTID )

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $  $Date: 2004/04/15 00:57:00 $

if (sf('get',objectId,'chart.isa') == 1) % If you are dealing with a chart show machine dialog
	parent = sf('get',objectId,'.machine');  
	machinedlg('construct',parent);
else	% Something other than chart
        obj = idToHandle(sfroot, objectId);
	parent = obj.getParent;
	
	if (isequal(get(get(classhandle(parent), 'Package'), 'Name'), 'Stateflow'))
		parent.view;
	else
		open_system(sf('get',obj.machine.Id,'.simulinkModel'));
	end
end









