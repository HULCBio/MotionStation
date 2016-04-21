function RefreshControllerList(this)

% Check for addition or deletion of an MPC controller node.  

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:35:55 $

% Input "this" is the MPCControllers node handle.

if isfield(this.Handles, 'UDDtable')
    UDDtable = this.Handles.UDDtable;
else
    % Possible that UDDtable hasn't been created.
    return
end
if isempty(UDDtable)
    return
end

% Need to make invisible, then reset to visible in order for changes to
% appear
setJavaLogical(UDDtable.Table,'setVisible',0);
Controllers = this.getChildren;
Count = length(Controllers);

List = cell(Count, 5);
ControllerList = cell(Count, 1);
for i=1:Count
    Controller = Controllers(i);
    List(i,:) = {Controller.Label, Controller.ModelName, ... 
        Controller.Ts, Controller.P, Controller.Updated};
    ControllerList{i,1} = Controller.Label;
end
this.Controllers = ControllerList;
% Set the selected controller
row = UDDtable.selectedRow;
if Count > 0
    if row > Count
        row = Count;
    elseif row < 1
        row = 1;
    end
else
    % Indicate no controller and disable object export
    row = 0;
    setJavaLogical(this.Handles.ExportMenu.getAction,'setEnabled',0);
    this.CurrentController = '';
end
if row > 0
    UDDtable.selectedRow = row;
end
UDDtable.setCellData(List);

setJavaLogical(UDDtable.Table,'setVisible',1);
UDDtable.setHeaderHeight(35);
this.RefreshControllerSummary;
