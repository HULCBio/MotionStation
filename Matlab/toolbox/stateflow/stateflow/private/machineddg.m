function dlgstruct = machineddg(h, name)

% Copyright 2002-2003 The MathWorks, Inc.

% Model name
snName.Name = 'Simulink Model:';
snName.RowSpan = [1 1];
snName.ColSpan = [1 1];
snName.Type = 'text';
snName.Tag = strcat('sfMachinedlg_', snName.Name);

simulinkModel.Name = h.Name;
simulinkModel.RowSpan = [1 1];
simulinkModel.ColSpan = [2 2];
simulinkModel.Type = 'hyperlink';
simulinkModel.Tag = 'simulinkModelTag';
simulinkModel.MatlabMethod = 'sf';
simulinkModel.MatlabArgs = {'Private', 'dlg_goto_object', h.Id};



% Creation Date
cdLabel.Name = 'Creation Date:';
cdLabel.RowSpan = [2 2];
cdLabel.ColSpan = [1 1];
cdLabel.Type = 'text';
cdLabel.Tag = strcat('sfMachinedlg_', cdLabel.Name);

cdString.Name = h.Created;
cdString.RowSpan = [2 2];
cdString.ColSpan = [2 2];
cdString.Type = 'text';
cdString.Tag = strcat('sfMachinedlg_', cdString.Name);

% Kreator
creatorEdit.Name = 'Creator:';
creatorEdit.ObjectProperty = 'Creator';
creatorEdit.RowSpan = [3 3];
creatorEdit.ColSpan = [1 2];
creatorEdit.Type = 'edit';
creatorEdit.Tag = strcat('sfMachinedlg_', creatorEdit.Name);

% Modified
modEdit.Name = 'Modified:';
modEdit.ObjectProperty = 'Modified';
modEdit.RowSpan = [4 4];
modEdit.ColSpan = [1 2];
modEdit.Type = 'editarea';
modEdit.Tag = strcat('sfMachinedlg_', modEdit.Name);

% Version
verEdit.Name = 'Version:';
verEdit.ObjectProperty = 'Version';
verEdit.RowSpan = [5 5];
verEdit.ColSpan = [1 2];
verEdit.Type = 'editarea';
verEdit.Tag = strcat('sfMachinedlg_', verEdit.Name);

% C bit ops
boBox.Name = 'Use c-like bit operations in new charts';
boBox.ObjectProperty = 'EnableBitOps';
boBox.RowSpan = [6 6];
boBox.ColSpan = [1 2];
boBox.Type = 'checkbox';
boBox.Tag = strcat('sfMachinedlg_', boBox.Name);

% Description
dsEdit.Name = 'Description:';
dsEdit.ObjectProperty = 'Description';
dsEdit.RowSpan = [7 7];
dsEdit.ColSpan = [1 2];
dsEdit.Type = 'editarea';
dsEdit.Tag = strcat('sfMachinedlg_', dsEdit.Name);

% Document link
docLink.Name = 'Document Link:';
docLink.RowSpan = [8 8];
docLink.ColSpan = [1 1];
docLink.Type = 'hyperlink';
docLink.MatlabMethod = 'sf';
docLink.Tag = 'docLinkTag';
docLink.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};

docEdit.Name = '';
docEdit.ObjectProperty = 'Document';
docEdit.RowSpan = [8 8];
docEdit.ColSpan = [2 2];
docEdit.Type = 'edit';
docEdit.Tag = 'sfMachinedlg_docEdit';

title = 'Machine';
% if the developer feature is on append the id to the title
if sf('Feature','Developer')
  id = strcat('#', sf_scalar2str(h.Id));
  dlgstruct.DialogTitle = strcat(title, id);
else
  dlgstruct.DialogTitle = title;
end
dlgstruct.LayoutGrid = [8 2];
dlgstruct.RowStretch = [0 0 0 1 1 0 2 0];
dlgstruct.ColStretch = [0 1];
dlgstruct.CloseCallback = 'sf';
dlgstruct.CloseArgs = {'SetDynamicDialog', h.Id, []};
dlgstruct.Items = {snName, simulinkModel, cdLabel, cdString, creatorEdit, modEdit, verEdit, boBox, dsEdit, docLink, docEdit};
dlgstruct.DialogTag = strcat('sfMachinedlg_', dlgstruct.DialogTitle);
dlgstruct.HelpMethod = 'sfhelp';
dlgstruct.HelpArgs = {'MACHINE_DIALOG'};    
dlgstruct.DisableDialog = ~is_object_editable(h);


