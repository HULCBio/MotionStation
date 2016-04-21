function h = nicholsmenu(Editor, Anchor, MenuType)
%NICHOLSMENU  Creates menus specific to the Nichols editor.
% 
%   H = NICHOLSMENU(EDITOR,ANCHOR,MENUTYPE) creates a menu item, related
%   submenus, and associated listeners.  The menu is attached to the 
%   parent object with handle ANCHOR.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:04:59 $

switch MenuType
 case 'show'
  % Show menu
  h = uimenu(Anchor,'Label', sprintf('Show'));
  
  % Margin submenu
  hs = uimenu(h, 'Label',    sprintf('Stability Margins'), ...
	         'Checked',  Editor.MarginVisible, ...
	         'Callback', {@MarginMenuCB Editor});
  lsnr = handle.listener(Editor, findprop(Editor, 'MarginVisible'), ...
			 'PropertyPostSet', {@LocalSetCheck hs});
end

set(h, 'UserData', lsnr)  % Anchor listeners for persistency


% ----------------------------------------------------------------------------%
% Listener Callbacks
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalSetCheck
% Callbacks for property listeners
% ----------------------------------------------------------------------------%
function LocalSetCheck(hProp, event, hMenu)
set(hMenu, 'Checked', event.NewValue);


% ----------------------------------------------------------------------------%
% Function: MarginMenuCB
% Callbacks for Stability Margins submenu (hSrc = menu handle)
% ----------------------------------------------------------------------------%
function MarginMenuCB(hSrc, event, Editor)
if strcmp(get(hSrc, 'Checked'), 'on')
  Editor.MarginVisible = 'off';
else
  Editor.MarginVisible = 'on';
end
