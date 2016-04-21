function this = SignalConstraintEditor(SigConstr,ParentFig)
% Build constraint editor

%   Author: Kamesh Subbarao 
%   Copyright 1986-2004 The MathWorks, Inc.
this = srogui.SignalConstraintEditor;

this.Constraint = SigConstr;
this.Parent = handle(ParentFig);

% Initialize graphics
initialize(this)

% Recorder
this.Recorder = ctrluis.recorder;

% Data Cursor settings
DM = datacursormode(ParentFig);
DM.SnapToDataVertex = 'off';
DM.EnableZStacking = true;
DM.ZStackMinimum = 10;

% Add listeners
this.Listeners.Fixed = ...
   handle.listener(this.Axes,'ObjectBeingDestroyed',{@localDelete this});

%--------------- Local Functions --------------

function localDelete(eventsrc,eventdata,this)
if ishandle(this.Parent)
   set(this.Parent,'WindowButtonMotion','')
end
delete(this)

