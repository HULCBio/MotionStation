function createmenu(figNumber, figName, Handles)
%CREATEMENU Populate the main menubar items with the relevant submenu items.
% figNumber is the handle of the relevant editor/viewer main window
% figName is the type of editor/viewer
% Handles is a structure containing the handles to the menu items

%   N. Hickey 17-3-01
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/14 22:22:52 $

% Get the FIS structure
oldfis=get(figNumber,'UserData');
fis=oldfis{1};

editHndl = Handles.editHndl;
viewHndl = Handles.viewHndl;

% Edit menu, create the submenu item Undo which is common to all editors/viewers------
uimenu('Parent',   editHndl, ...
    'Label',       'Undo', ...
    'Enable',      'off', ...
    'Tag',         'undo', ...
    'Accelerator', 'Z', ...
    'Callback',    'popundo(gcf)');

% Edit menu, show the specific editor/viewer functions as submenus------------
switch figName
case 'fuzzy'
    menu_items = localfuzzyedit(editHndl);
case 'mfedit'
    menu_items = localmfedit(editHndl, fis);
case 'ruleedit'
    menu_items = localruleedit(editHndl, figNumber);
case 'anfisedit'
    menu_items = localanfisedit(editHndl, figNumber);
case 'ruleview'
    menu_items = localruleview(editHndl, figNumber);
case 'surfview'
    menu_items = localsurfaceview(editHndl, figNumber);
end

% Edit menu, show the relevant other editors/viewers as submenus--------------
for count = 1:length(menu_items.editors)
    submenu_item = menu_items.editors{count};
    
    switch submenu_item
    case 'fuzzy'
        % Edit submenu item FIS properties
        Label_Str = 'FIS Properties...';
        Tag_Str   = 'fuzzy';
        UserData  =  1;
    case 'mfedit'
        % Edit submenu item Membership functions
        Label_Str = 'Membership Functions...';
        Tag_Str   = 'mfedit';
        UserData  =  2;
    case 'ruleedit'
        % Edit submenu item Rules
        Label_Str = 'Rules...';
        Tag_Str   = 'ruleedit';
        UserData  =  3;
    end
    hs = uimenu('Parent', editHndl, ...
        'Label',       Label_Str, ...
        'Tag',         Tag_Str, ...
        'UserData',    UserData, ...
        'Accelerator', num2str(UserData), ...
        'Callback',   'fisgui #findgui');
    if count == 1
        set(hs, 'Separator','on');
    end
    
end

% Edit submenu item Anfis
if strcmp(fis.type,   'sugeno')
    % Only add it to the menu if FIS is a Sugeno type
    hs = uimenu('Parent', editHndl, ...
        'Label',       'Anfis...', ...
        'Tag',         'anfisedit', ...
        'UserData',     6, ...
        'Accelerator', '4', ...
        'Callback',    'fisgui #findgui');
end

% View menu, show the relevant viewers as submenus----------------------------
for count = 1:length(menu_items.views)
    submenu_item = menu_items.views{count};
    
    switch submenu_item
    case 'rules'
        % View submenu item Rules
            Label_Str = 'Rules';
            Tag_Str   = 'ruleview';
            UserData  = 4;
    case 'surfaces'
        % View submenu item Surface
            Label_Str = 'Surface';
            Tag_Str   = 'surfview';
            UserData  = 5;
    end
        hs = uimenu('Parent',viewHndl, ...
            'Label',       Label_Str, ...
            'Tag',         Tag_Str, ...
            'UserData',    UserData, ...
            'Accelerator', num2str(UserData+1), ...
            'Callback',   'fisgui #findgui');
end


%%%%%%%%%%%%%%%%%%%%%%
%%% localfuzzyedit %%%
%%%%%%%%%%%%%%%%%%%%%%
function menu_items = localfuzzyedit(editHndl)
% Make fuzzy editor specific changes to the menubar

h   = uimenu('Parent',editHndl,'Label','Add Variable...','Separator','on');
hs1 = uimenu('Parent',h,'Label','Input','Tag','input');
hs2 = uimenu('Parent',h,'Label','Output','Tag','output');
set([hs1; hs2], 'Callback', 'fuzzy #addvar')

% Edit menu submenu Remove variable
uimenu('Parent', editHndl, ...
    'Label',       'Remove Selected Variable', ...
    'Accelerator', 'X', ...
    'Tag',         'removevar', ...
    'Enable',      'off', ...
    'Callback',    'fuzzy #rmvar');

menu_items = struct('editors', {{'mfedit' 'ruleedit'}}, ...
                    'views',   {{'rules' 'surfaces'}});


%%%%%%%%%%%%%%%%%%%
%%% localmfedit %%%
%%%%%%%%%%%%%%%%%%%
function menu_items = localmfedit(editHndl, fis)
% Make membership function editor specific changes to the menubar

uimenu('Parent',editHndl,'Label','Add MFs...', ...
    'Separator', 'on', ...
    'Callback',  'mfedit #addmfs');
uimenu('Parent',editHndl,'Label','Add Custom MF...', ...
    'Tag',       'addcustommf', ...
    'Callback',  'mfedit #addcustommf');
uimenu('Parent',editHndl,'Label','Remove Selected MF', ...
    'Tag',       'removemf', ...
    'Enable',    'off', ...
    'Callback',  'mfedit #removemf');

% Check that the input field exists
if ~isfield(fis, 'input')
    remove_all_mf = 'off';
else
    if length(fis.input) >= 1
        remove_all_mf = 'on';
    else    
        remove_all_mf = 'off';
    end
end

uimenu('Parent',editHndl,'Label','Remove All MFs', ...
    'Tag',     'removeallmf', ...
    'Enable',   remove_all_mf, ...
    'Callback','mfedit #removeallmfs');

menu_items = struct('editors', {{'fuzzy' 'ruleedit'}}, ...
                    'views',   {{'rules' 'surfaces'}});


%%%%%%%%%%%%%%%%%%%%%
%%% localruleedit %%%
%%%%%%%%%%%%%%%%%%%%%
function menu_items = localruleedit(editHndl, figNumber)
% Make rule editor specific changes to the menubar

% Create the extra item Options on the main menubar
optHndl=uimenu('Parent',figNumber,'Label','Options','Tag','optionsmenu');

% Create the Language submenu item, and its submenus
langHndl=uimenu('Parent',optHndl,'Label','Language','Tag','language');
hs1 = uimenu('Parent',langHndl,'Label','English','Checked','on');
hs2 = uimenu('Parent',langHndl,'Label','Deutsch');
hs3 = uimenu('Parent',langHndl,'Label','Francais');
set([hs1; hs2; hs3], 'Tag','lang', 'Callback', 'ruleedit #langselect')

% Create the Format submenu item, and its submenus
langHndl=uimenu('Parent',optHndl,'Label','Format','Tag','ruleformat');
hs1 = uimenu('Parent',langHndl,'Label','Verbose', 'Checked','on');
hs2 = uimenu('Parent',langHndl,'Label','Symbolic');
hs3 = uimenu('Parent',langHndl,'Label','Indexed');
set([hs1; hs2; hs3], 'Tag','rulefrmt', 'Callback', 'ruleedit #formatselect');

menu_items = struct('editors', {{'fuzzy' 'mfedit'}}, ...
    'views',   {{'rules' 'surfaces'}});

%%%%%%%%%%%%%%%%%%%%%%
%%% localanfisedit %%%
%%%%%%%%%%%%%%%%%%%%%%
function menu_items = localanfisedit(editHndl, figNumber)
% There are no anfisedit specific changes to menubar
% Just set the menu items to be displayed

menu_items = struct('editors', {{'fuzzy' 'mfedit' 'ruleedit'}}, ...
    'views',   {{'rules' 'surfaces'}});


%%%%%%%%%%%%%%%%%%%%%
%%% localruleview %%%
%%%%%%%%%%%%%%%%%%%%%
function menu_items = localruleview(editHndl, figNumber)
% Make view rules window specific changes to the menubar

% Create the extra item Options on the main menubar
optHndl=uimenu('Parent',figNumber, 'Label', 'Options', 'Tag','optionsmenu');

% Create the Options submenu item Format, and its subitems
formatHndl=uimenu('Parent',optHndl,'Label','Format','Tag','dispformat');
hs1 = uimenu('Parent',formatHndl,'Label','Verbose', 'Tag','verbose','Checked','on');
hs2 = uimenu('Parent',formatHndl,'Label','Symbolic','Tag','symbolic');
hs3 = uimenu('Parent',formatHndl,'Label','Indexed', 'Tag','indexed');
set([hs1; hs2; hs3], 'Callback', 'ruleview #dispformat')

menu_items = struct('editors', {{'fuzzy' 'mfedit' 'ruleedit'}}, ...
                    'views',   {{'surfaces'}});


%%%%%%%%%%%%%%%%%%%%%%%%
%%% localsurfaceview %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function menu_items = localsurfaceview(editHndl, figNumber)
% Make view surface window specific changes to the menubar

% Create the extra item Options on the surface viewer main menubar
optHndl  = uimenu('Parent',figNumber,'Label','Options','Tag','optionsmenu');

% Create the Plot submenu item, and its subitems
plotHndl = uimenu('Parent',optHndl,  'Label','Plot',   'Tag','plottype');
hs1 = uimenu('Parent',plotHndl,'Label','Surface','Checked','on');
hs2 = uimenu('Parent',plotHndl,'Label','Lit Surface');
hs3 = uimenu('Parent',plotHndl,'Label','Mesh');
hs4 = uimenu('Parent',plotHndl,'Label','X Mesh');
hs5 = uimenu('Parent',plotHndl,'Label','Y Mesh');
hs6 = uimenu('Parent',plotHndl,'Label','Contour');
hs7 = uimenu('Parent',plotHndl,'Label','Pseudo-Color');
hs8 = uimenu('Parent',plotHndl,'Label','Quiver');
set([hs1;hs2;hs3;hs4;hs5;hs6;hs7;hs8], 'Callback','surfview #plotselect')

% Create the Color Map submenu item, and its subitems
mapHndl = uimenu(optHndl,'Label','Color Map','Tag','colormap');
hs1 = uimenu('Parent',mapHndl,'Label','Default','Checked','on');
hs2 = uimenu('Parent',mapHndl,'Label','Blue');
hs3 = uimenu('Parent',mapHndl,'Label','Hot');
hs4 = uimenu('Parent',mapHndl,'Label','HSV');
set([hs1;hs2;hs3;hs4], 'Callback', 'surfview #colormap');

uimenu(optHndl,'Label','Always evaluate', ...
    'Separator', 'on', ...
    'Checked',   'on', ...
    'Tag',       'alwayseval', ...
    'Callback',  'surfview #evaltoggle');

menu_items = struct('editors', {{'fuzzy' 'mfedit' 'ruleedit'}}, ...
                    'views',   {{'rules'}});