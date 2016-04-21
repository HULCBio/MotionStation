function dlgStruct = busAssignmentddg(source, h)

% Copyright 2004 The MathWorks, Inc.

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

% Bottom group is the block parameters
% Input Group --------------------------
[items handles] = busCreatorddg_cb([],'getTreeItems',h.Handle,'');
bcInputsTree.Name       = 'Signals in the bus';
bcInputsTree.Type       = 'tree';
bcInputsTree.TreeItems  = items;
bcInputsTree.UserData   = handles;
bcInputsTree.RowSpan    = [1 4];
bcInputsTree.ColSpan    = [1 1];
bcInputsTree.MinimumSize = [200 200];
bcInputsTree.Tag        = 'bcInputsTree';
bcInputsTree.MatlabMethod = 'busCreatorddg_cb';
bcInputsTree.MatlabArgs = {'%dialog','doTreeSelection','%tag'};

bcFind.Name             = 'Find';
bcFind.Type             = 'pushbutton';
bcFind.RowSpan          = [1 1];
bcFind.ColSpan          = [2 2];
bcFind.Enabled          = 0;
bcFind.Tag              = 'bcFind';
bcFind.MatlabMethod     = 'busCreatorddg_cb';
bcFind.MatlabArgs       = {'%dialog','doFind'};

bcSelect.Name           = 'Select>>';
bcSelect.Type           = 'pushbutton';
bcSelect.RowSpan        = [2 2];
bcSelect.ColSpan        = [2 2];
bcSelect.Enabled        = 0;
bcSelect.Tag            = 'bcSelect';
bcSelect.MatlabMethod   = 'busCreatorddg_cb';
bcSelect.MatlabArgs     = {'%dialog','doSelect'};

bcRefresh.Name          = 'Refresh';
bcRefresh.Type          = 'pushbutton';
bcRefresh.RowSpan       = [3 3];
bcRefresh.ColSpan       = [2 2];
bcRefresh.Tag           = 'bcRefresh';
bcRefresh.MatlabMethod  = 'busCreatorddg_cb';
bcRefresh.MatlabArgs    = {'%dialog','doRefresh'};

inputGrp.Name           = '';
inputGrp.Type           = 'panel';
inputGrp.Items          = {bcInputsTree,bcFind,bcRefresh,bcSelect};
inputGrp.LayoutGrid     = [4 2];
inputGrp.RowStretch     = [0 0 0 1];
inputGrp.RowSpan        = [1 1];
inputGrp.ColSpan        = [1 1];

% Output Group -------------------------
bcOutputsList.Name      = 'Signals that are being assigned';
bcOutputsList.Type      = 'listbox';
bcOutputsList.MultiSelect = 0;
bcOutputsList.Entries   = strread(source.state.AssignedSignals,'%s','delimiter',',')';
bcOutputsList.UserData  = bcOutputsList.Entries;
bcOutputsList.RowSpan   = [1 4];
bcOutputsList.ColSpan   = [1 1];
bcOutputsList.MinimumSize = [200 200];
bcOutputsList.Tag       = 'bcOutputsList';
bcOutputsList.MatlabMethod = 'busCreatorddg_cb';
bcOutputsList.MatlabArgs = {'%dialog','doListSelection','%tag'};

bcUp.Name               = 'Up';
bcUp.Type               = 'pushbutton';
bcUp.RowSpan            = [1 1];
bcUp.ColSpan            = [2 2];
bcUp.Enabled            = 0;
bcUp.Tag                = 'bcUp';
bcUp.MatlabMethod       = 'busCreatorddg_cb';
bcUp.MatlabArgs         = {'%dialog','doUp'};

bcDown.Name             = 'Down';
bcDown.Type             = 'pushbutton';
bcDown.RowSpan          = [2 2];
bcDown.ColSpan          = [2 2];
bcDown.Enabled          = 0;
bcDown.Tag              = 'bcDown';
bcDown.MatlabMethod     = 'busCreatorddg_cb';
bcDown.MatlabArgs       = {'%dialog','doDown'};

bcRemove.Name           = 'Remove';
bcRemove.Type           = 'pushbutton';
bcRemove.RowSpan        = [3 3];
bcRemove.ColSpan        = [2 2];
bcRemove.Tag            = 'bcRemove';
bcRemove.MatlabMethod   = 'busCreatorddg_cb';
bcRemove.MatlabArgs     = {'%dialog','doRemove'};

outputGrp.Name          = '';
outputGrp.Type          = 'panel';
outputGrp.Items         = {bcUp,bcDown,bcRemove,bcOutputsList};
outputGrp.LayoutGrid    = [4 2];
outputGrp.RowStretch    = [0 0 0 1];
outputGrp.RowSpan       = [1 1];
outputGrp.ColSpan       = [2 2];

% Invisible widgets mapping to object properties
bcOutputs.Name           = 'AssignedSignals';
bcOutputs.Type           = 'edit';
bcOutputs.Value          = source.state.AssignedSignals;
bcOutputs.Visible        = 0;
bcOutputs.RowSpan        = [2 2];
bcOutputs.ColSpan        = [1 2];
bcOutputs.ObjectProperty = 'AssignedSignals';
bcOutputs.Tag            = bcOutputs.ObjectProperty;

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'group';
paramGrp.Items          = {inputGrp,outputGrp,bcOutputs};
paramGrp.LayoutGrid     = [2 2];
paramGrp.RowStretch     = [1 0];
paramGrp.ColStretch     = [1 1];
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];
dlgStruct.CloseCallback = 'busCreatorddg_cb';
dlgStruct.CloseArgs     = {'%dialog', 'doClose'};
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyCallback = 'busCreatorddg_cb';
dlgStruct.PreApplyArgs  = {'%dialog', 'doPreApply'};
% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

[isLib, isLocked] = source.isLibraryBlock(h);
if isLocked || source.isHierarchySimulating
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

