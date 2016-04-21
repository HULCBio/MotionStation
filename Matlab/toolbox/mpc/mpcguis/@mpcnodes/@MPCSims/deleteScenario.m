function deleteScenario(this, Item)

% deleteScenario(this, Item)
%
% Delete the scenario specified by Label == Item
% "this" is the MPCSims node

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/10 23:36:58 $

UDDtable = this.Handles.UDDtable;
[rows, cols]=size(UDDtable.CellData);
if rows == 1
    Message = sprintf( ['You cannot delete your only scenario.', ...
        '\n\nIf you wish', ...
        ' to clear it and start over, first create a new scenario,', ...
        ' then delete this one.'] );
    uiwait(errordlg(Message, 'MPC error', 'modal'));
    return
end

Question = sprintf(['Do you really wish to delete scenario "%s"?'],Item);
ButtonName=questdlg(Question,'Delete Confirm', 'Yes', 'No', 'No');
if strcmp(ButtonName,'Yes')
    % Delete the selected scenario
    MPCSimNode = this.getChildren.find('Label',Item);
    this.removeNode(MPCSimNode);
    this.RefreshSimList;
    % Select "Scenarios" node to prevent user from interacting with
    % panel of deleted scenario.
    this.getRoot.TreeManager.Explorer.setSelected(this.getTreeNodeInterface);
end
