function initialize(Editor,Preferences)
%INITIALIZE  Initializes Bode Diagram Editor.

%   Author(s): P. Gahinet
%   Revised: K. Subbarao 12-6-2001
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $ $Date: 2002/04/10 05:04:22 $

SISOfig = Editor.root.Figure; % host figure
MenuAnchor = Editor.MenuAnchors;
LoopData = Editor.LoopData;

% Render editor
Editor.bodeaxes(Preferences,SISOfig);

% Set HelpTopicKey for PreFilter Bode  axes
PlotAxes = getaxes(Editor.Axes);
set(PlotAxes, 'HelpTopicKey', 'sisoprefilter');

% Add generic Bode listeners
Editor.addbodelisteners;

% Add listeners specific to @bodeditorF
L = [handle.listener(Editor,Editor.findprop('ClosedLoopVisible'),...
      'PropertyPostSet',@LocalSetCLVis);...
      handle.listener(LoopData,LoopData.findprop('Configuration'),...
      'PropertyPostSet',@LocalUpdateTitle)];...
set(L,'CallbackTarget',Editor)
Editor.Listeners = [Editor.Listeners ; L];

% Create shadows for Bode plot portions to be included in limit picking
% REVISIT: could be incorporated in Bode plot's as XlimIncludeData
for ct=4:-1:1
   BodeShadow(ct) = line(NaN,NaN,'Parent',PlotAxes(1+rem(ct-1,2)),...
      'LineStyle','none','HitTest','off','HandleVisibility','off');
end
HG = Editor.HG;
HG.BodeShadow = reshape(BodeShadow,[2 2]);
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
LocalAddClosedLoop(Editor,h);  % bodeditorF-specific item
set(h,'Separator','on')

% Design Constraints/Grid/Zoom
h = [Editor.addmenu(MenuAnchor, 'constraint'); ...
     Editor.addmenu(MenuAnchor, 'grid')];
set(h(1), 'Separator', 'on')
set(h(end), 'Checked', Editor.Axes.Grid);
Editor.addmenu(MenuAnchor, 'zoom');

% Properties
if usejava('MWT')
    h = Editor.addmenu(MenuAnchor,'property');
    set(h,'Separator','on')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAddClosedLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = LocalAddClosedLoop(Editor,h)
% Adds Closed Loop item to Show menu

hs = uimenu(h,'Label',sprintf('Closed Loop'), ...
	'Checked',Editor.ClosedLoopVisible,...
	'Callback',{@LocalShowClosedLoop Editor});
lsnr = handle.listener(Editor,findprop(Editor,'ClosedLoopVisible'),...
	'PropertyPostSet',{@LocalSetCheck hs});

set(h,'UserData',[get(h,'UserData');lsnr])  % Anchor listeners for persistency


%-------------------- Callback functions -------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowClosedLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowClosedLoop(hSrc,event,Editor)
% Callbacks for Closed Loop submenu (hSrc = menu handle)
if strcmp(get(hSrc,'Checked'),'on')
    Editor.ClosedLoopVisible = 'off';
else
    Editor.ClosedLoopVisible = 'on';
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCLVis %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCLVis(Editor,event)
if strcmp(Editor.ClosedLoopVisible,'on')
  % Redraw to show closed-loop response
  Editor.update;
else
  % Hide closed-loop plot
  % REVISIT: simplify
  HG = Editor.HG;
  if size(HG.BodePlot,2)>1 & all(ishandle(HG.BodePlot(:,2)))
    delete(HG.BodePlot(:,2))
    HG.BodePlot = HG.BodePlot(:,1);
    Editor.HG = HG;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateTitle %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateTitle(Editor,event)
Editor.Axes.Title = ...
   sprintf('%s Bode Editor (F)',Editor.LoopData.describe('F','compact'));
