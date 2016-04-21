function Menu = findMenu(this,Tag)
%FINDMENU  Finds right-click menu with specified tag.

%  Author(s): James Owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:45 $
Menu = find(handle(this.UIcontextMenu),'Tag',Tag);