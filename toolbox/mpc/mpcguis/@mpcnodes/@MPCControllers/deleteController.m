function deleteController(this, Controller)

% deleteController(this, Controller)
%
% Delete controller having Label == Controller

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2004/04/10 23:35:59 $

UDDtable = this.Handles.UDDtable;
[rows, cols]=size(UDDtable.CellData);
if rows == 1
    Message = sprintf( ['You cannot delete your only controller.', ...
        '\n\nIf you wish', ...
        ' to clear it and start over, first create a new controller,', ...
        ' then delete this one.'] );
    uiwait(errordlg(Message, 'MPC error', 'modal'));
    return
end

Question = sprintf(['Do you really want to delete controller "%s"?'], ...
    Controller);
ButtonName=questdlg(Question,'MPC Toolbox Question','Yes', 'No', 'No');
if strcmp(ButtonName,'Yes')
    % Delete the selected controller
    MPCControllerNode = this.getChildren.find('Label', Controller);
    this.removeNode(MPCControllerNode);
    this.RefreshControllerList;
    % Modify any scenarios that were referencing this controller
    Scenarios = this.getMPCSims.getChildren;
    UsedIn = Scenarios.find('ControllerName',Controller);
    NewName = this.Controllers{1};
    if ~isempty(UsedIn)
        for i = 1:length(UsedIn)
            UsedIn(i).ControllerName = NewName;
        end
        Message = sprintf(['Controller "%s" was being used in at least', ...
            ' one simulation scenario.\n\nAll references to "%s"', ...
            ' have been replaced by "%s"'], Controller, Controller, ...
            NewName);
        warndlg(Message,'Controller Deletion');        
    end
    % Select "Controllers" node to prevent user from interacting with
    % panel of deleted controller.
    this.getRoot.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);
end
