function disableMenus(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:35 $

menus = [findall(this.EditMenu,'Tag','select all');
         findall(this.EditMenu,'Tag','cut');
         findall(this.EditMenu,'Tag','copy');
         findall(this.EditMenu,'Tag','paste')];              
set(menus,'Enable','off');


