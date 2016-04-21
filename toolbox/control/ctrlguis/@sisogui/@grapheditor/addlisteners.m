function addlisteners(Editor)
%ADDLISTENERS  Installs generic listeners for graphical editors.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.29.4.2 $ $Date: 2004/04/10 23:14:09 $

LoopData = Editor.LoopData;

% Targeted and event listeners
% RE: ViewChanged: needed for changes in limit modes/props
L = [handle.listener(Editor,findprop(Editor,'Visible'),...
      'PropertyPostSet',@LocalMakeVisible) ; ...
      handle.listener(Editor,findprop(Editor,'LabelColor'),...
      'PropertyPostSet',@setlabelcolor); ...
      handle.listener(Editor,findprop(Editor,'LineStyle'),...
      'PropertyPostSet',@update); ...
      handle.listener(Editor,findprop(Editor,'EditMode'),...
      'PropertyPostSet',@LocalModeChanged); ...
      handle.listener(Editor,findprop(Editor,'RefreshMode'),...
      'PropertyPostSet',@hgset_refresh);...
      handle.listener(Editor,findprop(Editor,'SingularLoop'),...
      'PropertyPostSet',@LocalSingularLoop);...
      handle.listener(LoopData,'LoopDataChanged',@LocalDataChanged) ; ...
      handle.listener(LoopData,'FirstImport',@activate) ; ...
      handle.listener(LoopData,'MoveGain',@LocalMoveGain) ; ...
      handle.listener(LoopData,'MovePZ',@LocalMovePZ);...
      handle.listener(Editor,'ObjectBeingDestroyed',@LocalCleanUp) ];
set(L,'CallbackTarget',Editor)
Editor.Listeners = L;    


%-------------------------Property listeners-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalMakeVisible %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMakeVisible(Editor,event)
% PostSet callback for Visible property
% Make axes visible
% RE: Must be done first to properly set label visibility (used by layout)
hgset_visible(Editor);

% Update host's layout 
% RE: This must be done before UPDATE so that axes dimensions are correct 
%     (influences tick picker and phase ticks, cf. sisotool(1)+view filter)
if ~isempty(Editor.root)
    Editor.root.layout;
end

% Update editor contents
if strcmp(Editor.EditMode,'off')
    % REVISIT: Workaround to geck rid unit circle, waiting for push/pop stack
    updateview(Editor)
else
    update(Editor)
end


%%%%%%%%%%%%%%%%%%%%
%%% LocalCleanUp %%%
%%%%%%%%%%%%%%%%%%%%
function LocalCleanUp(Editor,eventData)
% Clean up when editor is deleted
delete(Editor.Axes);


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDataChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDataChanged(Editor,event)
% Callback for 'LoopDataChanged' event
switch event.Data
case 'all'
    % Global update
    Editor.update;
case 'gainC'
    % Scoped update when C's gain is changed
    Editor.updategainC;
case 'gainF'
    % Scoped update when C's gain is changed
    Editor.updategainF;
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalMoveGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalMoveGain(Editor,event)
% Notifies editors of MOVEGAIN start and finish events
if strcmp(Editor.Visible,'on') & ~Editor.SingularLoop
    switch event.Data{1}   % edited component (C or F)
    case 'C'
        Editor.refreshgainC(event.Data{2:end});  % init/finish,
    case 'F'
        Editor.refreshgainF(event.Data{2:end});
    end
end
    

%%%%%%%%%%%%%%%%%%%
%%% LocalMovePZ %%%
%%%%%%%%%%%%%%%%%%%
function LocalMovePZ(Editor,event)
% Notifies editors of MOVEPZ:init and MOVEPZ:finish events
if strcmp(Editor.Visible,'on') & ~Editor.SingularLoop
    switch event.Data{1}   % edited component (C or F)
    case 'C'
        Editor.refreshpzC(event.Data{2:end});  % init/finish,pzgroup
    case 'F'
        Editor.refreshpzF(event.Data{2:end});
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalModeChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalModeChanged(Editor,event)
% Callback when switching edit mode
if strcmp(Editor.EditMode,'idle')
	% Returning to idle (for safety...)
	Editor.RefreshMode = 'normal';
	% Reset figure pointer
	set(Editor.EventManager.Frame,'Pointer','arrow');
else
    % Clear selected objects within Editor scope
    Editor.EventManager.clearselect(getaxes(Editor.Axes));
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSingularLoop %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSingularLoop(Editor,event)
% Callback when SingularLoop changes
if Editor.SingularLoop
   Editor.setmenu('off')
else
   Editor.setmenu('on')
end
