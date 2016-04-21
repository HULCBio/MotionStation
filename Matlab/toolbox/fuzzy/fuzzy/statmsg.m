function statmsg(figNumber,msgStr)
%STATMSG Send message to GUI status field.
%   STATMSG(figNumber,msgStr) causes the message contained in msgStr
%   to be passed to the status line (a text uicontrol field with the
%   Tag property set to "status") of the specified figure. 

%   Ned Gulley, 4-27-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/14 22:20:59 $

set(findobj(figNumber,'Type','uicontrol','Tag','status'),'String',msgStr);
