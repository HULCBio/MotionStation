function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:36:19 $

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
else
    if ~isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
        %% Do a try catch to make sure that each block exists in the model.
        %% If it does not remove it from the list.
        BlockDeletedFlag = false;
        for ct = length(this.IOData):-1:1
           try
               get_param(this.IOData(ct).Block,'Name');
           catch
               this.IOData(ct) = [];
               BlockDeletedFlag = true;
           end
        end
        % Update the model with the settings
        setlinio(this.Model,this.IOData);
        if BlockDeletedFlag
            %% Set the table data for the linearization ios
            table_data = this.getIOTableData;
            this.AnalysisIOTableModelUDD.data = table_data;

            %% Create a table model event to update the table
            evt = javax.swing.event.TableModelEvent(this.AnalysisIOTableModelUDD);
            this.AnalysisIOTableModelUDD.fireTableChanged(evt);
        end
    end
end

%% Get the linoptions for the project.
OpCondNode = getOpCondNode(this);
linoptions = OpCondNode.Options;

%% Use Model Perturbation disable for block linearization
if strcmp(linoptions.LinearizationAlgorithm,'numericalpert');
    this.Dialog.IOPanel.IOTable.setEnabled(0);
    this.Dialog.IOPanel.Instruct.setText(['Linearization annotations are not valid for ',...
        'perturbation based linearization.  Using top level inport and outports.']);
    this.Dialog.IOPanel.IOTable.setForeground(javax.swing.plaf.ColorUIResource(0.5,0.5,0.5));
else
    this.Dialog.IOPanel.IOTable.setEnabled(1);
    this.Dialog.IOPanel.Instruct.setText(['Select linearization I/Os by right clicking on ',...
        'the desired line in your Simulink model.'])
    this.Dialog.IOPanel.IOTable.setForeground(javax.swing.plaf.ColorUIResource(0,0,0))
end

panel = this.Dialog;
