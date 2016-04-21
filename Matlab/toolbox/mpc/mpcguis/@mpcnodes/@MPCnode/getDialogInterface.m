function panel = getDialogInterface(this, manager)

% GETDIALOGINTERFACE  Define pointer to dialog panel
 
%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:37:06 $
Root = this.getRoot;

% Inform dialogs of current selection
Root.setDialogHandles;

if ~Root.ModelImported
    Msg = sprintf(['You must import a model, controller, or', ...
        ' design before selecting the "%s" node.'], this.Label);
    helpdlg(Msg,'MPC Help')
    panel = LocalAbnormalCompletion(this, manager);
    return
end

% Verify that structure signal
% specifications have not been altered after controller design has
% begun.

if Root.SpecsChanged
    % Specs have been changed.  Perform checks.
    [ErrMsg, TypesChanged, ControllerDesigned, Resetting] = ...
        LocalCheckSignals(this);
    if isempty(ErrMsg)
        % No error
        Root.SpecsChanged = false;   % Toggle flag
        if TypesChanged && ControllerDesigned
            if Resetting
                % User has requested overwrite of current settings
                Root.Reset = true;
                panel = LocalAbnormalCompletion(this, manager);
            else
                % Continue with existing settings
                panel = LocalNormalCompletion(this, manager);
            end
        else
            % Either types not changed or controller not designed yet
            panel = LocalNormalCompletion(this, manager);
        end
    else
        % Error in specs.  Return to root and display error message.
        panel = LocalAbnormalCompletion(this, manager);
        LocalErrorMessage(ErrMsg);
    end
else
    % Specs have not been changed, so no need to check them
    panel = LocalNormalCompletion(this, manager);
end

% ------------------------------------------------------------------------

function panel = LocalNormalCompletion(this, manager)
% Call the node's getDialogSchema method
Root = this.getRoot;
Root.InData = Root.InUDD.CellData;
Root.OutData = Root.OutUDD.CellData;
Root.getMPCModels.setModelSignalTypes;
this.Dialog = this.getDialogSchema(manager);
panel = this.Dialog;
if length(Root.getMPCSims.CurrentScenario) > 0
    EnabledState = 1;
else
    EnabledState = 0;
end
if isfield(Root.Handles,'SimulateMenu')  % Might not be created yet
    setJavaLogical(Root.Handles.SimulateMenu.getAction, 'setEnabled', ...
        EnabledState);
end

% ------------------------------------------------------------------------

function panel = LocalAbnormalCompletion(this, manager)

% Force a return to the root node.

Root = this.getRoot;
Root.TreeManager.Explorer.setSelected(Root.getTreeNodeInterface);
if ~Root.ModelImported
    Root.TreeManager.Explorer.collapseNode(Root.TreeNode);
end
panel = Root.Dialog;

% ------------------------------------------------------------------------

function LocalErrorMessage(Message)

% Displays an error message
set(0,'ShowHiddenHandles','on');
H = findobj('Name','MPC Error');
set(0,'ShowHiddenHandles','off');
if ~isempty(H)
    delete(H)
end
errordlg(Message, 'MPC Error');

% ------------------------------------------------------------------------

function [ErrorMsg, TypesChanged, ControllerDesigned, Resetting] = ...
    LocalCheckSignals(this)

% User has selected a node below the root.  Make sure that current MPC
% structure (signal type choices) are OK.

MPCControllers = this.getMPCControllers;
Root = this.getRoot;
Model = Root.getMPCModels.Models(1).Model;

% Load latest structure data from tables on root panel
NewIn = Root.InUDD.CellData;
NewOut = Root.OutUDD.CellData;

% Has a controller been designed?
ControllerDesigned = false;
C = MPCControllers.getChildren;
if isempty(C) 
    error('Unexpected state:  No controller nodes defined.')
    return
end
if ~isempty(C(1).Dialog)
    ControllerDesigned = true;
end

ErrorMsg = '';
TypesChanged = false;
Resetting = false;

% Check the structure.
[NumMV, NumMD, NumUD, NumMO, NumUO, NumIn, NumOut] = getMPCsizes(Root);
InGrps = {'MV', 'MD', 'UD'};
InIDs = {[], [], []};
InType = cell(1,2);
InType{1} = char(Root.Handles.InTypeCombo.getItemAt(0));
InType{2} = char(Root.Handles.InTypeCombo.getItemAt(1));
for i = 1:NumIn
    NewType = NewIn{i,2};
    if ~strcmp(Root.InData{i,2},NewType)
        TypesChanged = true;
    end
    if strcmp(NewType, InType{1})
        InIDs{1} = [InIDs{1}, i];
    elseif strcmp(NewType, InType{2})
        InIDs{2} = [InIDs{2}, i];
    else
        InIDs{3} = [InIDs{3}, i];
    end
end
OutGrps = {'MO', 'UO'};
OutIDs = {[], []};
OutType = char(Root.Handles.OutTypeCombo.getItemAt(0));
for i = 1:NumOut
    NewType = NewOut{i,2};
    if ~strcmp(Root.OutData{i,2}, NewType)
        TypesChanged = true;
    end
    if strcmp(NewType, OutType)
        OutIDs{1} = [OutIDs{1}, i];
    else
        OutIDs{2} = [OutIDs{2}, i];
    end
end

% Make sure there's at least one MV in proposed structure
Message = ['Must have at least one MANIPULATED input and one ', ...
    'MEASURED output.'];
if length(InIDs{1}) <= 0
    ErrorMsg = Message;
else
    InputGroup = struct('MV',InIDs{1});
end
if ~isempty(InIDs{2})
    InputGroup.MD = InIDs{2};
end
if ~isempty(InIDs{3})
    InputGroup.UD = InIDs{3};
end
% Make sure there's at least one MO
if length(OutIDs{1}) <= 0
    ErrorMsg = Message;
else
    OutputGroup = struct('MO',OutIDs{1});
end
if ~isempty(OutIDs{2})
    OutputGroup.UO = OutIDs{2};
end

if isempty(ErrorMsg)
    set(Model,'InputGroup',InputGroup,'OutputGroup',OutputGroup);
    if ControllerDesigned
        % A controller has been designed.  If structure has been changed,  
        % we must resolve the conflict.
        if TypesChanged
            Message = sprintf(['You have changed signal types.\n\n', ...
                'In order to use these changes, you must overwrite ', ...
                'all previously created controllers and scenarios.', ...
                '  Do you wish to overwrite them?']);
            Answer = questdlg(Message, 'MPC Confirmation', 'Overwrite', ...
                'Cancel changes', 'Cancel changes');
            if strcmp(Answer, 'Overwrite')
                % Accept the new definitions and flag that previous must
                % be erased.
                Resetting = true;
                DefineStructureTables(Root, Model, NewIn, NewOut);
            else
                % Restore previous values
                Root.InUDD.setCellData(Root.InData);
                Root.OutUDD.setCellData(Root.OutData);
            end
        end
    else
        % A controller hasn't been designed.  OK to save the modified
        % structure and return.
        if TypesChanged
            DefineStructureTables(Root, Model, NewIn, NewOut);
        end
    end
end
