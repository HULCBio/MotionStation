function dlg_revert( method, fig )
%DLG_REVERT( METHOD, FIG )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:08 $

return; % Disabled

switch method
   case 'enable'
      button = findobj(fig,'Type','uicontrol','Style','pushbutton','String','Revert');
      set(button,'Enable','on');
   case 'disable'
      button = findobj(fig,'Type','uicontrol','Style','pushbutton','String','Revert');
      set(button,'Enable','off');
   otherwise
      warning('Invalid method');
end

