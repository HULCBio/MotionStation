function hfvt = fvtoolwaddnreplace(Hd)
%FVTOOLWADDNREPLACE   Utility to enable FVTool with an Add/Replace property.
%   FVTOOLWADDNREPLACE(Hd) Adds a property to FVTool for enabling the
%   'Add Filter' and 'Replace Filter' features and return an FVTool object
%   handle.  These properties are to be used with FVTool's API methods:
%   addfilter and setfilter.
%   
%   See also LNKFVTOOL2MASK

%   Author(s): J. Schickler, P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:50 $

error(nargchk(1,1,nargin));

hfvt = fvtool(Hd);

if isempty(findtype('signalAddReplace')),
    schema.EnumType('signalAddReplace', {'Add', 'Replace'});
end
p = schema.prop(hfvt, 'LinkMode', 'signalAddReplace');
set(hfvt, 'LinkMode', 'Replace');

load fatoolicons;

% Find the toolbar of FVTool and add two buttons.
htoolbar = findobj(hfvt, 'type', 'uitoolbar');
htoolbar = htoolbar(end);
link.h.button = uitoggletool('Parent', htoolbar, ...
    'ClickedCallback', {@fullview_mode_cb, hfvt}, ...
    'Separator', 'on', ...
    'State', 'On', 'TooltipString', 'Set Link mode to add', ...
    'CData', icons.replace, 'tag', 'mode');

% Create the menu to toggle the update_mode
link.h.menu = addmenu(hfvt, [1 4], 'Link','','link','on');
link.h.menu(2) = addmenu(hfvt, [1 4 1], xlate('Replace current filter'), ...
    {@fullview_mode_cb, hfvt}, 'replace', 'off', 'j');
link.h.menu(3) = addmenu(hfvt, [1 4 2], xlate('Add new filter'), ...
    {@fullview_mode_cb, hfvt}, 'add','off','k');

set(link.h.menu(2), 'Checked', 'On');

link.listener = handle.listener(hfvt, p, 'PropertyPostSet', @linkmode_listener);
set(link.listener, 'CallbackTarget', hfvt);
setappdata(hfvt, 'fullviewlink', link);

linkmode_listener(hfvt);

% ----------------------------------------------------------------------
function fullview_mode_cb(hcbo, eventStruct, hfvt)
% Callback to the menu items

if isa(handle(hcbo), 'hg.uimenu'),
    
    % Update the mode of the link with the tag of the menu item
    set(hfvt, 'LinkMode', get(hcbo, 'tag'));
else
    if strcmpi(get(hcbo, 'State'), 'On'),
        set(hfvt, 'LinkMode', 'Add');
    else
        set(hfvt, 'LinkMode', 'Replace');
    end
end

% ----------------------------------------------------------------------
function linkmode_listener(hfvt, eventData)

load fatoolicons;

if strcmpi(hfvt.linkmode, 'replace'),
    str   = 'Set Link mode to add';
    icon  = icons.replace;
    state = 'off';
    hfvt.setfilter(hfvt.Filter{end});
else
    str   = 'Set Link mode to replace';
    icon  = icons.add;
    state = 'on';
end

% Update the check marks of the Menu
link = getappdata(hfvt, 'fullviewlink');
set(link.h.menu, 'Checked', 'Off');
set(findobj(link.h.menu,'tag',lower(hfvt.linkmode)), 'Checked', 'On');
set(link.h.button,'State', state, 'CData', icon, 'Tooltip', str);

set(hfvt, 'Children', get(hfvt, 'Children'));

% [EOF]
