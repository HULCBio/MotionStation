function dlg_apply_ui_checkbox( ui, objectId, propertyName, checkIsIced )
%DLG_APPLY_UI_CHECKBOX( UI, OBJECTID, PROPERTYNAME, CHECKISICED)

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:56:46 $

	error(nargchk(4,4,nargin));

   fig = sf('get',objectId,'.dialog');
   if fig==0 | ~ishandle(fig), return; end
	newValue = get(ui,'Value');
	if iscell(newValue)
		newValue = [newValue{:}];
	end
   value = sf('get',objectId,propertyName);
	applyNewValue = any(value~=newValue);
	for i = 1:length(ui)
	   userData = get(ui(i),'UserData');
   	set(ui(i),'UserData',[]);
	   if value(i) ~= newValue(i)
   	   userData.revertBuffer = value(i);
		else
      	userData.revertBuffer = [];
	   end
	   set(ui(i),'UserData',userData);
	end
	if applyNewValue & (~checkIsIced | ~dlg_is_iced(objectId))
%		disp(['applied ' propertyName]);
		sf('set',objectId,propertyName,newValue);
		dlg_revert('enable',fig);
	end
		

