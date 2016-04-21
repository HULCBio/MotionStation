function copyController(this, Controller)

% Copy controller whose Label == Controller
% "this" is MPCControllers node

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:35:58 $

Old = this.getChildren.find('Label', Controller);
% Generate a name
Name = sprintf('%s_copy', Controller);
Num = 1;
Controllers = this.getChildren;
while ~isempty(Controllers.find('Label',Name))
    Name = sprintf('%s_copy%i', Controller, Num);
    Num = Num + 1;
end
% Valid name was assigned, so copy the node.
New = mpcnodes.MPCController(Name);
this.addNode(New);
New.ModelName = Old.ModelName;
New.Model = Old.Model;
New.IOdata = Old.IOdata;
New.getDialogInterface(this.up.TreeManager);
New.Ts = Old.Ts;
New.P = Old.P;
New.M = Old.M;
New.Blocking = Old.Blocking;
New.BlockMoves = Old.BlockMoves;
New.BlockAllocation = Old.BlockAllocation;
New.CustomAllocation = Old.CustomAllocation;
New.Notes = Old.Notes;
New.updateTables = Old.updateTables;
New.HasUpdated = Old.HasUpdated;
New.MPCobject = Old.MPCobject;
New.SofteningWindowLocation = Old.SofteningWindowLocation;
if Old.DefaultEstimator
    for i=1:3
        UDD = New.Handles.eHandles(i).UDD;
        UDD.CellData = Old.Handles.eHandles(i).UDD.CellData;
    end
    New.DefaultEstimator = true;
else
    New.EstimData = Old.EstimData;
    GainUDD = New.Handles.GainUDD;
    GainUDD.Value = Old.Handles.GainUDD.Value;
    for i=1:3
        UDD = New.Handles.eHandles(i).UDD;
        UDD.CellData = Old.Handles.eHandles(i).UDD.CellData;
    end
end
ULimits = New.Handles.ULimits;
ULimits.CellData = Old.Handles.ULimits.CellData;
YLimits = New.Handles.YLimits;
YLimits.CellData = Old.Handles.YLimits.CellData;
Uwts = New.Handles.Uwts;
Uwts.CellData = Old.Handles.Uwts.CellData;
Ywts = New.Handles.Ywts;
Ywts.CellData = Old.Handles.Ywts.CellData;
Usoft = New.Handles.Usoft;
Usoft.CellData = Old.Handles.Usoft.CellData;
Ysoft = New.Handles.Ysoft;
Ysoft.CellData = Old.Handles.Ysoft.CellData;
TrackingUDD = New.Handles.TrackingUDD.Value;
TrackingUDD.Value = Old.Handles.TrackingUDD.Value;
HardnessUDD = New.Handles.HardnessUDD.Value;
HardnessUDD.Value = Old.Handles.HardnessUDD.Value;

this.RefreshControllerList;
