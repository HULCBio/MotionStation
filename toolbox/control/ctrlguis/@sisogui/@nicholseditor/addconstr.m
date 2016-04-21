function addconstr(Editor, Constr)
%ADDCONSTR  Add constraint to editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:05:56 $

% REVISIT: should call grapheditor::addconstr to perform generic init
LoopData = Editor.LoopData;
Axes = Editor.Axes;

% Generic init (includes generic interface editor/constraint)
initconstr(Editor,Constr)

% Initialize editor-specific properties
Constr.PhaseUnits = Axes.XUnits;
Constr.MagnitudeUnits = 'dB';

% Add related listeners 
L = handle.listener(Axes,Axes.findprop('XUnits'),...
   'PropertyPostSet', {@LocalSetUnits,Constr});
Constr.addlisteners(L);

% Activate (initializes graphics and targets constr. editor)
Constr.Activated = 1;

% Update limits
updateview(Editor)

% --------------------------- Local Functions ----------------------------------%

function LocalSetUnits(eventSrc,eventData,Constr)
% Syncs constraint props with related Editor props
Axes = eventData.AffectedObject;
Constr.PhaseUnits = Axes.XUnits;
% Update constraint display (and notify observers)
update(Constr)

