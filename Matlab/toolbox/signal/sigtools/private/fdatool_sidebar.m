function hSB = fdatool_sidebar(hFDA)
%SIDEBAR Build the sidebar on FDATool

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.24.4.4 $  $Date: 2004/04/13 00:32:33 $

hFig = get(hFDA,'FigureHandle');

% Instantiate the object
hSB = siggui.sidebar;

render(hSB, hFig);

% Register the sidebar as a component of FDATool
addcomponent(hFDA,hSB);

% Add the Design Panel
install_design_panel(hSB);

% Add the Import Panel
install_import_panel(hSB);

install_pzeditor_panel(hSB);

% Add plugins for the sidebar
addplugins(hSB);

status(hFDA, 'Initializing Filter Design and Analysis Tool ...');

set(hSB,'CurrentPanel',1);

% ----------------------------------------------------------------
%   Install Panel functions
% ----------------------------------------------------------------

% ----------------------------------------------------------------
function install_design_panel(hSB)

icons        = load('panel_icons');

% Remove the following line once geck # 110439 is addressed. 
opts.icon    = color2background(icons.design); 
% opts.icon    = icons.design; % See G122899
opts.tooltip = 'Design Filter';
opts.csh_tag = 'fdatool_designfilter_tab';

% Register the Design Panel
registerpanel(hSB, @fdatool_design, 'design', opts);
% registerpanel(hSB,design_fcns,'design',opts);

% ----------------------------------------------------------------
function install_import_panel(hSB)

% Create the Import Panel and Register it
icons        = load('panel_icons');
opts.icon    = color2background(icons.import); 
% opts.icon    = icons.import; % See G122899
opts.tooltip = 'Import Filter from Workspace';
opts.csh_tag = 'fdatool_importfilter_tab';

% Register the Import Panel
registerpanel(hSB,@fdatool_import,'import',opts);

addimportmenu(hSB);

% ----------------------------------------------------------------
function install_pzeditor_panel(hSB)

% Create the Import Panel and Register it
icons        = load('panel_icons');
opts.icon    = color2background(icons.pzeditor);
opts.tooltip = 'Pole/Zero Editor';

% Register the Import Panel
registerpanel(hSB,@fdatool_pzeditor,'pzeditor',opts);

hEdit = findall(hSB.figurehandle, 'type', 'uimenu', 'tag', 'edit');

uimenu(hEdit, 'Label', 'Pole/Zero Editor', 'tag', 'pzeditor_tools_menu', ...
    'Callback', {@setpanel_cb, hSB, 'pzeditor'});

% ----------------------------------------------------------------
%   Utility functions
% ----------------------------------------------------------------

% ----------------------------------------------------------------
function addimportmenu(hSB)

hFig = get(hSB, 'FigureHandle');

hFM = findobj(hFig, 'type','uimenu','tag','file');
hEM = findobj(hFM, 'tag', 'export');

uimenu(hFM, 'Position', get(hEM, 'Position'), ...
    'Label', 'Import Filter from Workspace', ...
    'Separator', 'On', ...
    'tag', 'import', ...
    'Accelerator', 'i', ...
    'Callback', {@setpanel_cb, hSB, 'import'});
set(hEM, 'Separator', 'Off');

% ----------------------------------------------------------------
function setpanel_cb(hcbo, eventStruct, hSB, newpanel)

if nargin == 3, newpanel = get(hcbo, 'Tag'); end
if ischar(newpanel), newpanel = string2index(hSB, newpanel); end

set(hSB, 'CurrentPanel', newpanel);

% [EOF]
