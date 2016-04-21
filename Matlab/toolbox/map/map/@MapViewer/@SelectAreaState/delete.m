function delete(this)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:57:15 $

set(this.MapViewer.Figure,'Pointer','Arrow',...
                  'WindowButtonDownFcn','');
if ~isempty(this.Box) && ishandle(this.Box)
  delete(this.Box);
end
this.disableMenus;
