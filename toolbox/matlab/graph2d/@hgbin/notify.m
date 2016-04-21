function binObj = notify(binObj, caller, prop, value)
%HGOBJ/NOTIFY Notify method for hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:54 $

otherItems = binObj.Items; 
otherItems = otherItems(find(otherItems~=caller));

switch prop
case 'position'
case 'doclick'
   if strcmp(value,'normal')
	  if ~isempty(otherItems)
         otherItems.IsSelected = 0;
	  end
   end
end

