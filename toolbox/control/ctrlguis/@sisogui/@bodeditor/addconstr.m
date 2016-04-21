function addconstr(Editor, Constr)
%ADDCONSTR  Add Generic constraint to editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 04:56:54 $

% REVISIT: should call grapheditor::addconstr to perform generic init
LoopData = Editor.LoopData;
Axes = Editor.Axes;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Initialize editor-specific properties
Constr.MagnitudeUnits = Axes.YUnits{1};

% Add related listeners 
pu = [Axes.findprop('XUnits');Axes.findprop('YUnits')];
L = [handle.listener(LoopData,LoopData.findprop('Ts'),'PropertyPostSet',{@LocalUpdate,Constr});...
      handle.listener(Axes,pu,'PropertyPostSet', {@LocalSetUnits,Constr})];
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor)

% --------------------------- Local Functions ----------------------------------%

function LocalUpdate(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
set(Constr,eventSrc.Name,eventData.NewValue)
% Update constraint display (and notify observers)
update(Constr)


function LocalSetUnits(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
Axes = eventData.AffectedObject;
switch eventSrc.Name
case 'XUnits'
   Constr.FrequencyUnits = Axes.XUnits;
case 'YUnits'
   Constr.MagnitudeUnits = Axes.YUnits{1};
end
% Update constraint display (and notify observers)
update(Constr)

