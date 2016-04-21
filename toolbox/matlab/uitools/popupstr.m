function str = popupstr(handle)
%POPUPSTR Get popup menu selection string.
%  STR = POPUPSTR(H) returns the currently selected string
%  for the popup menu uicontrol whose handle is H.

%  Steven L. Eddins, April 1994
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.11 $  $Date: 2002/04/15 03:26:05 $

pick_list = get(handle, 'String');
selection = get(handle, 'Value');
if (iscell(pick_list))
    str = pick_list{selection};
else
    str = deblank(pick_list(selection,:));
end

