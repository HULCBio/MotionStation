function RefreshSimList(this)

% RefreshSimList(this)
%
% Compensate for change in number of scenario nodes or other factors
% affecting the scenario list display.
% "this" is the MPCSims node handle.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.3 $ $Date: 2003/09/14 13:57:14 $

if isfield(this.Handles, 'UDDtable')
    UDDtable = this.Handles.UDDtable;
else
    return
end
if isempty(UDDtable)
    return
end

% Need to make invisible, then reset to visible in order for changes to
% appear
setJavaLogical(UDDtable.Table,'setVisible',0);
Sims = this.getChildren;
Count = length(Sims);

List = cell(Count,6);
for i=1:Count
    Sim = Sims(i);
    MPCName = Sim.ControllerName;
    PlantName = Sim.PlantName;
    List(i,:) = {Sim.Label, MPCName, PlantName, java.lang.Boolean(Sim.ClosedLoop), ...
            java.lang.Boolean(Sim.ConstraintsEnforced), Sim.Tend};
end

% Set the selected scenario
row = UDDtable.selectedRow;
if Count > 0
    if row > Count
        row = Count;
    elseif row < 1
        row = 1;
    end
else
    % Set no-scenario state
    row = 0;
    setJavaLogical(this.up.Handles.SimulateMenu.getAction,'setEnabled',0);
    this.CurrentScenario = '';
end
if row > 0
    UDDtable.selectedRow = row;
end
UDDtable.setCellData(List);

setJavaLogical(UDDtable.Table,'setVisible',1);
this.RefreshSimSummary;
