function desktopmenufcn(dtmenu, cmd)

% Copyright 2003-2004 The MathWorks, Inc.

error(nargchk(1,2,nargin))

if ischar(dtmenu)
    cmd = dtmenu;
    dtmenu = gcbo;
end

% But gcbo does not return the correct menu object sometimes when menu's
% CreateFcn is called.  
%
% In the following edge case , this menu item will be enabled
% in the native figure menubar if that figure is created
% without menubar, then javaFigures mode is turned on, and then
% menubar is turned on. In that case, it will be disabled by its
% Callback code in 'desktopmenupopulate' below when clicked.
if ~strcmpi(get(dtmenu, 'type'), 'uimenu')
    return;
end

fig = get(dtmenu,'Parent');

% possibly related to the above check on dtmenu, it can happen that 
% this callback has a partially defined figure which manifests as a 
% bogus DockControls property value. This happens even without Java
% figures turned on
if ~ischar(get(fig,'DockControls'))
  return;
end

switch lower(cmd)       
    case 'desktopmenupopulate'
        if isempty(get(fig, 'JavaFrame'))
            delete(allchild(dtmenu));
            set(dtmenu,'Visible','off')
        elseif ishandle(dtmenu)
            % Java Figures is on and DockControls is on. 
            % This is a Java Figure. So, populate the desktop menu.
            h = allchild(dtmenu);
            if isempty(h)
                h = uimenu(dtmenu);
            end
            
            name = get(fig, 'name');
            t = '';
            if strcmp(get(fig,'numbertitle'),'on')
                t = sprintf('Figure %.8g',fig);
                if ~isempty(name)
                    t = [t, ': '];
                end
            end
            title = [t, name];
            
            if (strcmp(get(fig, 'windowstyle'), 'docked'))
                set(h, 'label', sprintf('Undock %s', title), 'callback', ...
                    {@figureDockingHandler, fig, 'off'});
            else
                set(h, 'label', sprintf('Dock %s', title), 'callback', ...
                    {@figureDockingHandler, fig, 'on'});
            end
            
            if (~isDesktopMainFrameAvailable || ...
                    strcmp(get(fig, 'DockControls'), 'off'))
            % The desktop frame and DockControls property must be on for the 
            % figure to support docking.
                set(h, 'Enable', 'off');
            else
                set(h, 'Enable', 'on');
            end
        end
end


function figureDockingHandler(src, evd, figh, isDock)
if isDock
    set(figh, 'windowstyle', 'docked');
else
    set(figh, 'windowstyle', 'normal');
end
    

function DtAvailable = isDesktopMainFrameAvailable
% This method will error out if java is not supported.
error(javachk('jvm'));

dt = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
DtAvailable = dt.hasMainFrame;
    
