function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:36:50 $

import com.mathworks.toolbox.slcontrol.OperatingConditionSpecificationPanels.*;

%% Add the settings pane to the frame
DialogPanel = OperatingConditionsSettingsPanel;

%% Get and store the two tabbed panels
this.OpCondSpecPanelUDD = DialogPanel.getOpCondSpecPanel;

%% Make the panel visible
DialogPanel.setVisible(1);

%% Configure the operation condition selection panel
this.OpCondSelectionPanelUDD = jOperatingConditionSpecificationPanels.OperatingConditionSelectionPanel(...
                                    DialogPanel.getOpCondSelectPanel,this); 

%% Configure the delete and import operating conditions buttons
DeleteOpCondButtonUDD = DialogPanel.getDeleteConditionButton;
set(DeleteOpCondButtonUDD,'ActionPerformedCallback',{@LocalDeleteOpCondCallback,this})
this.DeleteOpCondButtonUDD = DeleteOpCondButtonUDD;

ImportOpCondButtonUDD = DialogPanel.getImportConditionButton;
set(ImportOpCondButtonUDD,'ActionPerformedCallback',{@LocalImportOpCond,this})
this.ImportOpCondButtonUDD = ImportOpCondButtonUDD;
                                
%% Configure the input constaint table
this.configureInputConstraintTable(DialogPanel);
%% Configure the output constaint table
this.configureOutputConstraintTable(DialogPanel);
%% Configure the state constaint table
this.configureStateConstraintTable(DialogPanel);
%% Configure the compute operating conditions button
this.configureComputeOpCondButton(DialogPanel);

%% Configure the import initial value for operating spec button
h = handle(this.OpCondSpecPanelUDD.getImportButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImportOpSpec this};

%% Configure the import initial value for operating spec button
h = handle(this.OpCondSpecPanelUDD.getSyncButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalSyncOpSpec this};

%% Configure the callback for the hyperlinks in the display
StatusArea = this.OpCondSpecPanelUDD.getStatus;
editor = StatusArea.getEditor;
h = handle(editor, 'callbackproperties');
h.HyperlinkUpdateCallback = { @LocalEvaluateHyperlinkUpdate, this };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalEvaluateHyperlinkUpdate
function LocalEvaluateHyperlinkUpdate(hSrc, hData,this)
if strcmp(hData.getEventType.toString, 'ACTIVATED')
    Description = char(hData.getDescription);
    typeind = findstr(Description,':');
    switch Description(1:typeind(1)-1)
        case 'block'
            block = char(Description(typeind(1)+1:end));
            feval( 'hilite_system', block, 'find' )
            pause(1);
            feval( 'hilite_system', block, 'none' )
        case 'childnode'
            node = char(Description(typeind(1)+1:end));
            %% Get the children of the operating task
            children = this.getChildren;
            %% Find the matching node
            ind = find(strcmp(node,get(children,'Label')));
            if isempty(ind)
                errordlg(sprintf('The node %s does not exist in the current project.',node),...
                            'Simulink Control Design')
            else
                Frame = slctrlexplorer;
                Frame.setSelected(children(ind).getTreeNodeInterface);
            end            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSyncOpSpec
function LocalSyncOpSpec(es,ed,this)

%% Update the operating specification data    
try
    this.OpSpecData.update;
catch
    lsterr = lasterror.message;
    str = sprintf(['The operating point specifications could not be could ',...
        'not be synchronized with the model %s due to the following error:\n\n',...
        '%s'],this.Model,lsterr);
    errordlg(str,'Operating Points Synchronization Error')
end

%% Repopulate table data with the data from the operating point
this.InputSpecTableData = [];
configureInputConstraintTable(this,this.OpCondSpecPanelUDD)
this.OutputSpecTableData = [];
configureOutputConstraintTable(this,this.OpCondSpecPanelUDD)
this.StateSpecTableData = [];
configureStateConstraintTable(this,this.OpCondSpecPanelUDD)

%% Set the dirty flag
this.setDirty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalImportOpSpec
function LocalImportOpSpec(es,ed,this)

%% Get the valid projects to import from the session
openprojects = this.up.up.getChildren;

names = get(openprojects,'Model');
indvalid = find(strcmp(names,this.Model));
pvalid = openprojects(indvalid);

%% Create the dialog and show it
dlg = jDialogs.OpcondImport(this,pvalid);
%% Set the list selection to be single
lsm = javax.swing.DefaultListSelectionModel;
lsm.setSelectionMode(0)
dlg.Handles.Table.setSelectionModel(lsm);
dlg.importfcn = {@ImportOperSpecData,this,dlg};
FRAME = slctrlexplorer;
dlg.Frame.setLocationRelativeTo(FRAME);
dlg.show

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ImportOperSpecData - Callback to import an operating point to the GUI
function ImportOperSpecData(this,dlg)

ModelIdx = get(dlg.Handles.Table,'SelectedRows') + 1; %java to matlab indexing

if ~isempty(ModelIdx)
    dlg.Frame.dispose;

    %% Get the name and operating point object
    name = dlg.VarNames{ModelIdx};
    var = dlg.VarData{ModelIdx};

    if isa(var,'opcond.OperatingPoint')
        [x,u] = getxu(var);
        this.OpSpecData.setxu(x,u);
    else
        this.OpSpecData.setxu(var);
    end

    %% Repopulate table data with the data from the operating point
    this.InputSpecTableData = [];
    configureInputConstraintTable(this,this.OpCondSpecPanelUDD)
    this.StateSpecTableData = [];
    configureStateConstraintTable(this,this.OpCondSpecPanelUDD)
    
    %% Set the dirty flag
    this.setDirty
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalImportOpCond - Callback to import an operating point
function LocalImportOpCond(es,ed,this)

%% Get the valid projects to import from
openprojects = this.up.up.getChildren;
ind = find(openprojects == this.up);
openprojects(ind) = [];

names = get(openprojects,'Model');
indvalid = find(strcmp(names,this.Model));
pvalid = openprojects(indvalid);

%% Create the dialog and show it
dlg = jDialogs.OpcondImport(this,pvalid);
dlg.importfcn = {@ImportOperPointData,this,dlg};
FRAME = slctrlexplorer;
dlg.Frame.setLocationRelativeTo(FRAME);
dlg.show

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ImportOperPointData - Callback to import an operating point to the GUI
function ImportOperPointData(this,dlg)

ModelIdx = get(dlg.Handles.Table,'SelectedRows') + 1; %java to matlab indexing

if ~isempty(ModelIdx)
    dlg.Frame.dispose;
    %% Get the name and operating point object
    name = dlg.VarNames{ModelIdx};
    var = dlg.VarData{ModelIdx};

    if isa(var,'opcond.OperatingPoint')
        op = var;
    elseif isa(var,'double')
        op = this.OpSpecData.CreateOpPoint;
        op.setxu(var);
    else
        op = this.OpSpecData.CreateOpPoint;
        op.setxu(var);
    end

    %% Create the new node
    node = OperatingConditions.OperConditionValuePanel(op,name);

    %% Add the new node to the operating point task
    this.addNode(node);
    
    %% Set the dirty flag
    this.setDirty
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDeleteOpCondCallback - Callback to delete an operating condition.
function LocalDeleteOpCondCallback(es,ed,this)

%% Get the children of the operating conditions
Children = this.getChildren;

%% Get the selected indecies
rows = this.OpCondSelectionPanelUDD.JavaPanel.OpCondTable.getSelectedRows+1;

%% Delete the appropriate nodes
if (rows == 0)
    errordlg('Please select an operating point to delete.','Simulink Control Design')
elseif (any(find(rows == 1)))
    errordlg('The Default Operating Point node cannot be deleted.','Simulink Control Design')
else
    for ct = length(rows):-1:1
        this.removeNode(Children(rows(ct)));   
    end
    %% Set the dirty flag
    this.setDirty
end
