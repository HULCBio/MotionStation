function newstate = umtoggle(uimenu_handle)
%UMTOGGLE  Toggle "checked" status of uimenu object.
%  UMTOGGLE(U) changes the 'checked' status of the object
%  U from 'on' to 'off' or from 'off' to 'on', and returns
%  1 if the new status is 'on' and 0 if the new status is
%  'off'.
%
% See also UIMENU MENUBAR WINMENU

%  Author: T. Krauss 10-14-94
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.13 $  $Date: 2002/04/15 03:27:33 $

str = get(uimenu_handle,'checked');
if strcmp(str,'on')
   newstate = 0;  newstr = 'off';
else
   newstate = 1;  newstr = 'on';
end
set(uimenu_handle,'checked',newstr)

