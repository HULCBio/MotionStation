function dlg_revert_property( ui, objectId, propertyName, checkIsIced )
% DLG_REVERT_PROPERTY( UI, OBJECTID, PROPERTYNAME, CHECKISICED)

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:09 $
	
	error(nargchk(4,4,nargin));

   fig = sf('get',objectId,'.dialog');
   if fig==0 | ~ishandle(fig), return; end
   userData = get(ui,'UserData');
   if isfield(userData,'revertBuffer') & ~isempty(userData.revertBuffer)
   	if (checkIsIced & dlg_is_iced(objectId)), return; end
      if isfield(userData.revertBuffer,'values') & isfield(userData.revertBuffer,'value')
         value = userData.revertBuffer.values(userData.revertBuffer.value);
         sf('set',objectId,propertyName,value);
      elseif isfield(userData.revertBuffer,'value')
         sf('set',objectId,propertyName,userData.reverBuffer.value);
      else
         sf('set',objectId,propertyName,userData.revertBuffer);
      end
%      disp(['reverted ' propertyName]);
   else
%      disp(['no change in ' propertyName]);
   end
   set(ui,'UserData',[]);
   userData.revertBuffer = [];
   set(ui,'UserData',userData);


