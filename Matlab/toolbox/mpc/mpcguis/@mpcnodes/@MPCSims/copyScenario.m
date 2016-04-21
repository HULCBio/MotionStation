function copyScenario(this, Sim)

%  copyScenario(this, Sim)
%
% Copy the scenario whose Label is "Sim"
% "this" is the MPCSims node.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2004/04/10 23:36:57 $

Old = this.getChildren.find('Label',Sim);
% Generate a name
Name = sprintf('%s_copy', Sim);
Num = 1;
Scenarios = this.getChildren;
while ~isempty(Scenarios.find('Label',Name))
    Name = sprintf('%s_copy%i', Sim, Num);
    Num = Num + 1;
end

% Valid name was assigned, so copy the node.
New = mpcnodes.MPCSim(Name);
this.addNode(New);
New.PlantName = Old.PlantName;
New.ControllerName = Old.ControllerName;
New.getDialogInterface(this.up.TreeManager);
New.Tend = Old.Tend;
New.updateTables = Old.updateTables;
New.HasUpdated = Old.HasUpdated;
New.Scenario = Old.Scenario;
New.Results = Old.Results;
New.ClosedLoop = Old.ClosedLoop;
New.ConstraintsEnforced = Old.ConstraintsEnforced;
New.Notes = Old.Notes;
New.rLookAhead = Old.rLookAhead;
New.vLookAhead = Old.vLookAhead;
LocalCopyTable(New.Handles.Setpoints, Old.Handles.Setpoints);
LocalCopyTable(New.Handles.MeasDist, Old.Handles.MeasDist);
LocalCopyTable(New.Handles.UnMeasDist, Old.Handles.UnMeasDist);
this.RefreshSimList;

% ========================================

function LocalCopyTable(New,Old)

% Copy UDD table characteristics

if isempty(Old)
    New = [];
else
    New.isEditable = Old.isEditable;
    New.isString = Old.isString;
    New.setCellData(Old.CellData);
end
