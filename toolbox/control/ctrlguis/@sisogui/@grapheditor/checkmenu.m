function checkmenu(Editor,MenuMode,hMenu)
%CHECKMENU  Updates menu state based on Editor mode.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:01:27 $

% RE: MENUMODE is the mode controlled by this menu (add/delete/zoom)

% Set menu checks
switch MenuMode
case 'add'
    % Manages state of Add menu and submenus
    SubMenus = get(hMenu,'Children');
    set(SubMenus,'Checked','off')  % reset
    if strcmp(Editor.EditMode,'addpz')
        % Check appropriate Add submenu
        Labels = strrep(get(SubMenus,'Label'),' ','');
        AddInfo = sprintf('%s%s',Editor.EditModeData.Group,Editor.EditModeData.Root);
        set(SubMenus(strcmp(AddInfo,Labels)),'Checked','on')
    end
    
case 'delete'
    % Delete menu
    if strcmp(Editor.EditMode,'deletepz')
        set(hMenu,'Checked','on')
    else
        set(hMenu,'Checked','off')
    end
    
case 'zoom'
    % Manages state of Zoom submenus
    SubMenus = get(hMenu,'Children');
    set(SubMenus,'Checked','off')  % reset
    if strcmp(Editor.EditMode,'zoom')
        % Check appropriate Zoom submenu
        Selection = find(strcmpi(Editor.EditModeData.Type,get(SubMenus,'Label')));
        set(SubMenus(Selection),'Checked','on')
    end
    
end

