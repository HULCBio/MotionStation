function dlg_edit_field( method, objectId, propName, tag, preprocess, checkIsIced)
% DLG_EDIT_FIELD( METHOD, OBJECTID, PROPERTYNAME, TAG, PREPROCESS, CHECKISICED )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:56:51 $

error(nargchk(6,6,nargin));

if length(objectId)>1
	% Sub-dialog mechanism is to be used => objectId = [id subDlgH]
	fig = objectId(2);
	objectId = objectId(1);
	propStr = sf('get',objectId,propName);
else
	[fig,propStr] = sf('get',objectId,'.dialog',propName);
	if isequal(fig,0) | ~ishandle(fig)
		sf('set',objectId,'.dialog',0);
		return;
	end
end

ui = findobj(fig,'Type','uicontrol','Style','edit','Tag',tag,'Enable','on');
if isempty(ui)
	return;
end
userData = get(ui,'UserData');
set(ui,'UserData',[]);

switch method
case 'apply'
   newStr = dlg_get_string(ui);
   if isnumeric(propStr)
      % Property value is numeric => evaluate newStr
		status = 0;
      eval(['newStr=',newStr,';'],'status=1;');
		if status==1
			dlg_set_string(ui,num2str(propStr));
			return;
		end
   end
	if ~isempty(preprocess) % preprocess
		newStr = feval(preprocess,newStr);
	end
   if ~isequal(propStr,newStr) & (~checkIsIced | ~dlg_is_iced(objectId))
	   userData.revertBuffer = propStr; % remember current value of the property
		ok=1;
		eval('sf(''set'',objectId,propName,newStr)','ok=0;');
		if ~ok
			sf('set',objectId,propName,propStr);
   	   userData = rmfield(userData,'revertBuffer');
%	   		disp(['failed to apply ' propName]);
		else
		   dlg_revert('enable',fig);
%	   		disp(['applied ' propName]);
		end
	elseif isfield(userData,'revertBuffer')
      userData = rmfield(userData,'revertBuffer');
	end
case 'revert'
   if isfield(userData,'revertBuffer') & (~checkIsIced | ~dlg_is_iced(objectId))
      % there is stuff to revert
      if ~isequal(propStr,userData.revertBuffer)
   		if ~isempty(preprocess) % preprocess
	   		newStr = feval(preprocess,userData.revertBuffer);
         else
      	   newStr = userData.revertBuffer;
	   	end
	      sf('set',objectId,propName,newStr);
   	   dlg_revert('disable',fig);
%	      disp(['reverted ' propName]);
      end
      userData = rmfield(userData,'revertBuffer');
	end
otherwise
   warning('Invalid method.');
end
set(ui,'UserData',userData);

