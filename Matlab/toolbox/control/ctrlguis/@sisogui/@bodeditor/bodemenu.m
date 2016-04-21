function h = bodemenu(Editor,Anchor,MenuType)
%BODEMENU  Creates menus specific to the Bode editor.
% 
%   H = BODEMENU(EDITOR,ANCHOR,MENUTYPE) creates a menu item, related
%   submenus, and associated listeners.  The menu is attached to the 
%   parent object with handle ANCHOR.

%   Author(s): P. Gahinet, N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $ $Date: 2002/04/10 04:55:49 $

switch MenuType
    
case 'show'
    % Show menu
    h = uimenu(Anchor,'Label',sprintf('Show'));
    
    % Mag and phase submenus
    hs1 = uimenu(h,'Label',sprintf('Magnitude'), ...
        'Checked',Editor.MagVisible);
    hs2 = uimenu(h,'Label',sprintf('Phase'), ...
        'Checked',Editor.PhaseVisible);
    set([hs1;hs2],'Callback',{@LocalShowMagPhase Editor [hs1;hs2]})
    lsnr = [handle.listener(Editor,findprop(Editor,'MagVisible'),...
            'PropertyPostSet',{@LocalSetCheck hs1}) ; ...
            handle.listener(Editor,findprop(Editor,'PhaseVisible'),...
            'PropertyPostSet',{@LocalSetCheck hs2})];
    
end


set(h,'UserData',lsnr)  % Anchor listeners for persistency

%----------------------------- Listener callbacks ----------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowMagPhase %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalShowMagPhase(hSrc,event,Editor,hMagPhase)
% Callbacks for Mag/Phase submenus

idxSrc = find(hSrc==hMagPhase);

% Determine new states of mag/phase menus
isOn = strcmp(get(hMagPhase,'Checked'),'on');
isOn(idxSrc) = ~isOn(idxSrc);

if ~any(isOn)
    % Both deselected: abort toggle operation
    Status = sprintf('At least one of the magnitude or phase plots must be displayed.');
else
    % Set corresponding mode
    States = {'off','on'};
    if idxSrc==1
        Editor.MagVisible = States{1+isOn(1)};
    else
        Editor.PhaseVisible = States{1+isOn(2)};
    end
    Plots = {'magnitude','phase'};
    Status = {'hidden','visible'};
    Status = sprintf('The %s plot is now %s.',sprintf(Plots{idxSrc}),sprintf(Status{1+isOn(idxSrc)}));
end

% Make status persistent but don't record it
Editor.EventManager.newstatus(Status);
Editor.EventManager.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetCheck %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSetCheck(hProp,event,hMenu)
% Callbacks for property listeners
set(hMenu,'Checked',event.NewValue);
