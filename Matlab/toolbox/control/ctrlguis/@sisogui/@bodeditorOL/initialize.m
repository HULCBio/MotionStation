function initialize(Editor,Preferences)
%INITIALIZE  Initializes Bode Diagram Editor.

%   Author(s): P. Gahinet
%   Revised:   N. Hickey
%              K. Subbarao 12-6-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.32 $ $Date: 2002/04/10 05:02:56 $

SISOfig = Editor.root.Figure; % host figure
MenuAnchor = Editor.MenuAnchors;

% Initialize preference-driven properties
Editor.ShowSystemPZ = Preferences.ShowSystemPZ;

% Create editor axes
Editor.bodeaxes(Preferences,SISOfig);
Editor.Axes.Title = 'Open-Loop Bode Editor (C)';

% Set HelpTopicKey for Open-Loop Bode axes
PlotAxes = getaxes(Editor.Axes);
set(PlotAxes, 'HelpTopicKey', 'sisobode');

% Add generic Bode listeners
Editor.addbodelisteners;

% Add @bodeditorOL-specific listeners
L = [handle.listener(Editor,Editor.findprop('MarginVisible'),...
      'PropertyPostSet',@LocalSetMarginVis);...
      handle.listener(Editor,Editor.findprop('ShowSystemPZ'),...
      'PropertyPostSet',@LocalSetPZVis)];
set(L,'CallbackTarget',Editor)
Editor.Listeners = [Editor.Listeners ; L];

% Create shadow for portion of Bode plot to be included in limit picking
% REVISIT: could be incorporated in Bode plot's as XlimIncludeData
for ct=2:-1:1
   BodeShadow(ct,1) = line(NaN,NaN,'Parent',PlotAxes(ct),'LineStyle','none',...
      'HitTest','off','HandleVisibility','off');
end

% Add @bodeditorOL-specific slots in HG structure
HG = Editor.HG;
HG.GainMargin = [];
HG.PhaseMargin = [];
HG.BodeShadow = BodeShadow;
Editor.HG = HG;

% Build right-click menu
U = Editor.Axes.UIContextMenu;
LocalCreateMenus(Editor,U,1);
set(get(U,'children'),'Enable','off')

% Replicate menus in main figure
LocalCreateMenus(Editor,MenuAnchor,0);


%-------------------------- Local Functions ------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateMenus %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateMenus(Editor,MenuAnchor,EditFlag)
% Builds right-click menus

% Edit pole/zero group
Editor.addmenu(MenuAnchor,'add');
Editor.addmenu(MenuAnchor,'delete');
if EditFlag
    Editor.addmenu(MenuAnchor,'edit');
end

% Show menu 
h = Editor.bodemenu(MenuAnchor,'show');
LocalAddMarginMenu(Editor,h);  % bodeditorOL-specific item
set(h,'Separator','on')

% Design Constraints/Grid/Zoom
h = [Editor.addmenu(MenuAnchor, 'constraint'); ...
     Editor.addmenu(MenuAnchor, 'grid')];
set(h(1), 'Separator', 'on');;
set(h(end), 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
    h = Editor.addmenu(MenuAnchor,'property');
    set(h,'Separator','on')
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetPZVis %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetPZVis(Editor,event)
% Toggle visibility of system poles and zeros
if ~strcmp(Editor.EditMode,'off') & strcmp(Editor.Visible,'on')
    HG = Editor.HG;
    if strcmp(event.NewValue,'off')
        set([HG.System.Magnitude;HG.System.Phase],'Visible','off')
    else
        set(HG.System.Magnitude,'Visible',Editor.MagVisible)
        set(HG.System.Phase,'Visible',Editor.PhaseVisible)
    end
end


%-------------------- Margin-related functions -------------------


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddMarginMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAddMarginMenu(Editor,h)
% Adds Stability Margins item to Show menu
hs = uimenu(h,'Label',sprintf('Stability Margins'), ...
    'Checked',Editor.MarginVisible,...
    'Callback',{@LocalToggleMarginMenu Editor});
L = handle.listener(Editor,findprop(Editor,'MarginVisible'),...
    'PropertyPostSet',{@LocalSetCheck hs});
set(h,'UserData',[get(h,'UserData');L])  % Anchor listeners for persistency


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalToggleMarginMenu %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleMarginMenu(hSrc,event,Editor)
% Callbacks for Stability Margins submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    Editor.MarginVisible = 'off';
else
    Editor.MarginVisible = 'on';
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetMarginVis %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetMarginVis(Editor,event)
% Callback when toggling MarginVisible state
% Update visibility of margin objects
if ~isempty(Editor.HG.GainMargin)
   MarginHandles = [struct2cell(Editor.HG.GainMargin) ; struct2cell(Editor.HG.PhaseMargin)];
   set([MarginHandles{:}],'Visible',Editor.MarginVisible)
end
% Update margin display
showmargin(Editor)
% Refresh limits
updateview(Editor)