function [hcmenus, hmenus] = addunitsmenu(hlbl, strcell, cb, appdatastr)
%ADDUNITSMENU Add context menus to X-axis or Y-axis labels.
%   [HCMENUS, HMENUS] = ADDUNITSMENU(HLBL,STRCELL,CBFUNCHANDLE,APPDATASTR) 
%   creates a context menu attached to an X or Y label whose handle is 
%   given by HLBL.  STRCELL is a cell array of strings which defines the menu
%   items added to the contextmenu.  The callbacks to these menu items are
%   specified by the function handle, CBFUNCHANDLE.  APPDATASTR is a application
%   data specific string which stores the handle to a listener object. 
%   HCMENUS is the handle to the contextmenu and HMENUS is an array of handles
%   of the menu items.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:52:28 $

error(nargchk(4,4,nargin));

% Create and install the context menus
hcmenus = createcsmenus(hlbl);

% Create the menu items
hmenus = createmenus(hcmenus,strcell,hlbl);

% Define a label listener 
hxlbl = handle(hlbl(1));
xlistener  = handle.listener(hxlbl, hxlbl.findprop('String'), ...
                             'PropertyPreSet', cb);
set(xlistener,'CallBackTarget',hxlbl);
                         
% Store the handle object in the figure's application data
haxes = get(hlbl(1), 'Parent');
setappdata(get(haxes,'Parent'),appdatastr,xlistener);


%-------------------------------------------------------------------
function hcmenus = createcsmenus(hlbl)
% Create the context menu.

hcmenus = uicontextmenu('Parent', get(get(hlbl, 'Parent'), 'Parent'));
set(hlbl,'uicontextmenu',hcmenus);


%-------------------------------------------------------------------
function hmenus = createmenus(hcmenus,strcell,hlbl)
% Create menu(s) items on the context menu and return
% a cell array of handles to these menus.

% Create a cell array of 'Off' strings for the checked 
% property of the uimenus
chkcell = cell(size(strcell));
[chkcell{:}] = deal('Off');

% Check the current label selection
lblstr = get(hlbl,'String');
lblstr = chkLblStr(lblstr);
indx = strmatch(lblstr,strcell);
if ~isempty(indx),
    chkcell{indx} = 'On';
end

% Render the menu items
for n = 1:length(strcell),    
    hmenus(n) = uimenu(hcmenus,...
        'Label',strcell{n},...
        'Checked',chkcell{n},...
        'Callback',{@chglblNchk,hlbl});
end


%-------------------------------------------------------------------
%                       Utility Functions
%-------------------------------------------------------------------
function chglblNchk(hcbo,eventData,hlbl)
% Change the strings on either an X or Y labels and check the
% current units (menu item).

%
% Update the label (X or Y)
%
menulbl = get(hcbo,'Label');

% Since uimenus cannot have latex characters, we need to change
% the axes label string when "Normalized Frequency" is selected
% from the context menu.
axeslblstr = chkLblStr(menulbl,'axis');
set(hlbl,'String',axeslblstr);

% Check the current unit menu
hcm = get(hcbo,'Parent');

% Get the handles and strings to all menus items
hmenus = findobj('Parent',hcm,'Type','uimenu'); 
set(hmenus,'Checked','Off');
menulbls = get(hmenus,'Label');

axeslblstr = chkLblStr(axeslblstr);
indx = strmatch(axeslblstr,menulbls,'exact');

% Check the currently selected units menu item.
set(hmenus(indx),'Checked','On');


%-------------------------------------------------------------------
function lblstr = chkLblStr(lblstr,axisflag)
% Return the proper version of the Normalized Frequency string
% for the X-axis label or menu item.

if strncmpi(lblstr,'Normalize',9),
    if nargin == 2,
        lblstr = 'Normalized Frequency  (\times\pi rad/sample)';
    else
        lblstr = 'Normalized Frequency';
    end
end

% [EOF]
