function result = dlg_is_iced(objectId)
%DLG_IS_ICED  returns a boolean indicating iced state of the input object.
%   For iced objects an error dialog is created.

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.10.2.1 $  $Date: 2004/04/15 00:57:02 $

result = sf('IsIced',objectId);
if ~result, return; end
[MACHINE,CHART,STATE,TRANSITION,JUNCTION,EVENT,DATA,TARGET] = sf('get','default'...
   ,'machine.isa'...
   ,'chart.isa'...
   ,'state.isa'...
   ,'transition.isa'...
   ,'junction.isa'...
   ,'event.isa'...
   ,'data.isa'...
   ,'target.isa'...
);
switch sf('get',objectId,'.isa')
   case MACHINE
		name = 'machine';
   case CHART
		name = 'chart';
   case STATE
		name = 'state';
   case TRANSITION
		name = 'transition';
   case JUNCTION
		name = 'junction';
   case EVENT
		name = 'event';
   case DATA
		name = 'data';
   case TARGET
		name = 'target';
   otherwise
      warning('Bad object type.');
		name = 'unkown object';
end
errordlg(sprintf(...
	'New properties of Stateflow %s could not be applied. The %s is probably locked either because you are simulating or because its parent is locked!'...
	,name,name)...
	,'Apply Failed!'...
	,'replace');


