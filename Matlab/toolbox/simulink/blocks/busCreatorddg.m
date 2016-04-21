function dlgStruct = busCreatorddg(source, h)

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
bcInherit.Type          = 'combobox';
bcInherit.Entries       = {'Inherit bus signal names from input ports',...
	    'Require input signal names to match signals below'};
bcInherit.RowSpan       = [1 1];
bcInherit.ColSpan       = [1 1];
bcInherit.Tag           = 'bcInherit';
bcInherit.MatlabMethod  = 'busCreatorddg_cb';
bcInherit.MatlabArgs    = {'%dialog','doInherit'};

numIn = busCreatorddg_cb([],'getNumIn',h.Handle,source.state.Inputs);
bcNumIn.Name            = 'Number of inputs:';
bcNumIn.Type            = 'edit';
bcNumIn.RowSpan         = [2 2];
bcNumIn.ColSpan         = [1 1];
bcNumIn.Value           = numIn;
bcNumIn.Tag             = 'bcNumIn';
bcNumIn.MatlabMethod    = 'busCreatorddg_cb';
bcNumIn.MatlabArgs      = {'%dialog','doInputs',source.state.Inputs};

[items handles] = busCreatorddg_cb([],'getTreeItems',h.Handle,source.state.Inputs);
bcSignalsTree.Name      = 'Signals in bus';
bcSignalsTree.Type      = 'tree';
bcSignalsTree.Graphical = true;
bcSignalsTree.TreeItems = items;
bcSignalsTree.UserData  = handles;
bcSignalsTree.RowSpan   = [1 5];
bcSignalsTree.ColSpan   = [1 1];
bcSignalsTree.Tag       = 'bcSignalsTree';
bcSignalsTree.MatlabMethod = 'busCreatorddg_cb';
bcSignalsTree.MatlabArgs = {'%dialog','doTreeSelection','%tag'};

entries = busCreatorddg_cb([],'getListEntries',h.Handle,source.state.Inputs);
bcSignalsList.Name      = 'Signals in bus';
bcSignalsList.Type      = 'listbox';
%bcSignalsList.Graphical = true;
bcSignalsList.MultiSelect = 0;
bcSignalsList.Entries   = entries;
bcSignalsList.UserData  = entries;
bcSignalsList.RowSpan   = [1 5];
bcSignalsList.ColSpan   = [1 1];
bcSignalsList.MinimumSize = [200 200];
bcSignalsList.Tag       = 'bcSignalsList';
bcSignalsList.MatlabMethod = 'busCreatorddg_cb';
bcSignalsList.MatlabArgs = {'%dialog','doListSelection','%tag'};

bcFind.Name             = 'Find';
bcFind.Type             = 'pushbutton';
bcFind.RowSpan          = [1 1];
bcFind.ColSpan          = [2 2];
bcFind.Tag              = 'bcFind';
bcFind.MatlabMethod     = 'busCreatorddg_cb';
bcFind.MatlabArgs       = {'%dialog','doFind'};

bcUp.Name               = 'Up';
bcUp.Type               = 'pushbutton';
bcUp.RowSpan            = [2 2];
bcUp.ColSpan            = [2 2];
bcUp.Tag                = 'bcUp';
bcUp.MatlabMethod       = 'busCreatorddg_cb';
bcUp.MatlabArgs         = {'%dialog','doUp'};

bcDown.Name             = 'Down';
bcDown.Type             = 'pushbutton';
bcDown.RowSpan          = [3 3];
bcDown.ColSpan          = [2 2];
bcDown.Tag              = 'bcDown';
bcDown.MatlabMethod     = 'busCreatorddg_cb';
bcDown.MatlabArgs       = {'%dialog','doDown'};

bcRefresh.Name          = 'Refresh';
bcRefresh.Type          = 'pushbutton';
bcRefresh.RowSpan       = [4 4];
bcRefresh.ColSpan       = [2 2];
bcRefresh.Tag           = 'bcRefresh';
bcRefresh.MatlabMethod  = 'busCreatorddg_cb';
bcRefresh.MatlabArgs    = {'%dialog','doRefresh'};

bcRename.Name           = 'Rename selected signal:';
bcRename.Type           = 'edit';
bcRename.RowSpan        = [6 6];
bcRename.ColSpan        = [1 1];
bcRename.Tag            = 'bcRename';
bcRename.MatlabMethod   = 'busCreatorddg_cb';
bcRename.MatlabArgs     = {'%dialog','doRename',source.state.Inputs};

% Some neccessary schema logic
if (~isempty(str2num(source.state.Inputs)))   % Inherit bus signal names...
    bcInherit.Value       = 0;
    bcRename.Enabled      = 0;
    bcUp.Visible          = 0;
    bcDown.Visible        = 0;
    bcRefresh.Visible     = 1;
    bcSignalsList.Visible = 0;
    bcSignalsTree.Visible = 1;
else                                % Require input signal names match...
    bcInherit.Value       = 1;
    bcRename.Enabled      = 1;
    bcUp.Visible          = 1;
    bcDown.Visible        = 1;
    bcRefresh.Visible     = 0;
    bcSignalsList.Visible = 1;
    bcSignalsTree.Visible = 0;
end

bcSigPnl.Type           = 'panel';
bcSigPnl.Items          = {bcSignalsTree,bcSignalsList,bcFind,bcUp,bcDown,bcRefresh,bcRename};
bcSigPnl.LayoutGrid     = [6 2];
bcSigPnl.RowStretch     = [0 0 0 0 1 0];
bcSigPnl.ColStretch     = [1 0];
bcSigPnl.RowSpan        = [3 3];
bcSigPnl.ColSpan        = [1 1];

bcSpecify.Name          = 'Specify properties via bus object';
bcSpecify.Type          = 'checkbox';
bcSpecify.RowSpan       = [1 1];
bcSpecify.ColSpan       = [1 2];
bcSpecify.Mode          = 1;
bcSpecify.DialogRefresh = 1;
bcSpecify.ObjectProperty = 'UseBusObject';
bcSpecify.Tag           = bcSpecify.ObjectProperty;
% required for synchronization --------
bcSpecify.MatlabMethod  = 'slDialogUtil';
bcSpecify.MatlabArgs    = {source,'sync','%dialog','checkbox','%tag'};

bcObject.Name           = 'Bus object:';
bcObject.Type           = 'edit';
bcObject.RowSpan        = [2 2];
bcObject.ColSpan        = [1 1];
bcObject.ObjectProperty = 'BusObject';
bcObject.Tag            = bcObject.ObjectProperty;
% required for synchronization --------
bcObject.MatlabMethod   = 'slDialogUtil';
bcObject.MatlabArgs     = {source,'sync','%dialog','edit','%tag'};

bcObjEdit.Name          = 'Edit';
bcObjEdit.Type          = 'pushbutton';
bcObjEdit.RowSpan       = [2 2];
bcObjEdit.ColSpan       = [2 2];
bcObjEdit.Tag           = 'BusObjectEdit';
bcObjEdit.MatlabMethod  = 'busCreatorddg_cb';
bcObjEdit.MatlabArgs    = {'%dialog','doBusObjEdit'};

bcOutput.Name           = 'Output as nonvirtual bus';
bcOutput.Type           = 'checkbox';
bcOutput.RowSpan        = [3 3];
bcOutput.ColSpan        = [1 2];
bcOutput.ObjectProperty = 'NonVirtualBus';
bcOutput.Tag            = bcOutput.ObjectProperty;
% required for synchronization --------
bcOutput.MatlabMethod   = 'slDialogUtil';
bcOutput.MatlabArgs     = {source,'sync','%dialog','checkbox','%tag'};

if (strcmp(h.UseBusObject, 'on'))
    bcObject.Enabled    = 1;
    bcObjEdit.Enabled   = 1;
    bcOutput.Enabled    = 1;
else
    bcObject.Enabled    = 0;
    bcObjEdit.Enabled   = 0;
    bcOutput.Enabled    = 0;
end

bcObjPnl.Type           = 'panel';
bcObjPnl.Items          = {bcSpecify, bcObject, bcObjEdit, bcOutput};
bcObjPnl.LayoutGrid     = [3 2];
bcObjPnl.ColStretch     = [1 0];
bcObjPnl.RowSpan        = [4 4];
bcObjPnl.ColSpan        = [1 1];

% Invisible widgets mapping to object properties
bcInputs.Name           = 'Inputs';
bcInputs.Type           = 'edit';
bcInputs.Value          = source.state.Inputs;
bcInputs.Visible        = 0;
bcInputs.RowSpan        = [5 5];
bcInputs.ColSpan        = [1 2];
bcInputs.ObjectProperty = 'Inputs';
bcInputs.Tag            = bcInputs.ObjectProperty;
% ----------------------------------------------

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'group';
paramGrp.Items          = {bcInherit,bcNumIn,bcSigPnl,bcObjPnl,bcInputs};
paramGrp.LayoutGrid     = [5 1];
paramGrp.RowStretch     = [0 0 1 0 0];
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
