function dlgStruct = busSelectorddg(source, h)

% Copyright 2003-2004 The MathWorks, Inc.

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
bcInputsTree.Graphical  = true;
bcInputsTree.TreeItems  = items;
bcInputsTree.TreeMultiSelect = 1;
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
entries = busCreatorddg_cb([],'validate',h.Handle,strread(source.state.OutputSignals,'%s','delimiter',',')');
bcOutputsList.Name      = 'Selected signals';
bcOutputsList.Type      = 'listbox';
bcOutputsList.MultiSelect = 0;
bcOutputsList.Entries   = entries;
bcOutputsList.UserData  = bcOutputsList.Entries;
bcOutputsList.RowSpan   = [1 4];
bcOutputsList.ColSpan   = [1 1];
bcOutputsList.MinimumSize = [200 200];
bcOutputsList.Tag       = 'bcOutputsList';
bcOutputsList.MatlabMethod = 'busCreatorddg_cb';
bcOutputsList.MatlabArgs = {'%dialog','doListSelection','%tag'};

bcOutput.Name           = 'Muxed output';
bcOutput.Type           = 'checkbox';
bcOutput.RowSpan        = [5 5];
bcOutput.ColSpan        = [1 2];
bcOutput.ObjectProperty = 'MuxedOutput';
bcOutput.Tag            = bcOutput.ObjectProperty;
% required for synchronization --------
bcOutput.MatlabMethod   = 'slDialogUtil';
bcOutput.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag'};

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
outputGrp.Items         = {bcUp,bcDown,bcRemove,bcOutputsList,bcOutput};
outputGrp.LayoutGrid    = [5 2];
outputGrp.RowStretch    = [0 0 0 1 0];
outputGrp.RowSpan       = [1 1];
outputGrp.ColSpan       = [2 2];

% Invisible widgets mapping to object properties
bcOutputs.Name           = 'OutputSignals';
bcOutputs.Type           = 'edit';
bcOutputs.Value          = source.state.OutputSignals;
bcOutputs.Visible        = 0;
bcOutputs.RowSpan        = [2 2];
bcOutputs.ColSpan        = [1 2];
bcOutputs.ObjectProperty = 'OutputSignals';
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
