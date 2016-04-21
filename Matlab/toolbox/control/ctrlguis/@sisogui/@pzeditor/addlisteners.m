function addlisteners(Editor)
%ADDLISTENERS  Installs listeners for compensator editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $ $Date: 2002/04/10 04:55:31 $

% Listeners to editor properties
p = [Editor.findprop('PZGroup') ; Editor.findprop('Format')];
Listeners = [handle.listener(Editor,Editor.findprop('Visible'),...
        'PropertyPostSet',@LocalSetVisible)  ; ...
        handle.listener(Editor,Editor.findprop('FrequencyUnits'),...
        'PropertyPostSet',@LocalUpdateUnits) ; ...
        handle.listener(Editor,Editor.findprop('EditedObject'),...
        'PropertyPostSet',@settarget)  ; ...
        handle.listener(Editor,p,'PropertyPostSet',@update)];

% Listeners to @loopdata
%   1) FirstImport event: side effects of first import
%   2) LoopDataChanged event: side effects of change in loop data
%   3) LoopData destroyed: destroys editor window
LoopData = Editor.LoopData;
Listeners = [Listeners ; ...
        handle.listener(LoopData,'FirstImport',@activate) ;...
        handle.listener(LoopData,'LoopDataChanged',@LocalSync) ; ...
        handle.listener(Editor,'ObjectBeingDestroyed',@LocalDestroy)];

% Set callback target
set(Listeners,'CallbackTarget',Editor);
Editor.Listeners = Listeners;


%-------------------------Listeners-------------------------

%%%%%%%%%%%%%%%%%%%%
%%% LocalDestroy %%%
%%%%%%%%%%%%%%%%%%%%
function LocalDestroy(Editor,event)
% Close editor
if ~isempty(Editor.HG) & ishandle(Editor.HG.Figure)
    delete(Editor.HG.Figure);
end


%%%%%%%%%%%%%%%%%
%%% LocalSync %%%
%%%%%%%%%%%%%%%%%
function LocalSync(Editor,event)
% Resync internal PZ data with main database (triggers editor update)
if strcmp(Editor.Visible,'on')
	Editor.importdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateUnits %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateUnits(Editor,event)
% Updates editor when units change (only when active+visible)
if ~strcmp(Editor.EditMode,'off') & strcmp(Editor.Visible,'on')
	Editor.update;
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSetVisible %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetVisible(Editor,event)
% Toggle visibility
NewVis = event.NewValue;
% Set figure visibility
set(Editor.HG.Figure,'Visible',NewVis)
if strcmp(NewVis,'off')
    % Blow away target to ensure proper update when editor made visible again
    Editor.EditedObject = [];
end


